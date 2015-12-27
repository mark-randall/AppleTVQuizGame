//
//  BluetoothKit
//
//  Copyright (c) 2015 Rasmus Taulborg Hummelmose - https://github.com/rasmusth
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import CoreBluetooth

public func ==(lhs: BKAvailability, rhs: BKAvailability) -> Bool {
    switch (lhs, rhs) {
        case (.Available, .Available): return true
        case (.Unavailable(cause: .Any), .Unavailable): return true
        case (.Unavailable, .Unavailable(cause: .Any)): return true
        case (.Unavailable(let lhsCause), .Unavailable(let rhsCause)): return lhsCause == rhsCause
        default: return false
    }
}

/**
    Bluetooth LE availability.
    - Available: Bluetooth LE is available.
    - Unavailable: Bluetooth LE is unavailable.

    The unavailable case can be accompanied by a cause.
*/
public enum BKAvailability: Equatable {
    
    case Available
    case Unavailable(cause: BKUnavailabilityCause)
    
    internal init(centralManagerState: CBCentralManagerState) {
        switch centralManagerState {
            case .PoweredOn: self = .Available
            default: self = .Unavailable(cause: BKUnavailabilityCause(centralManagerState: centralManagerState))
        }
    }

    internal init(peripheralManagerState: CBPeripheralManagerState) {
        switch peripheralManagerState {
            case .PoweredOn: self = .Available
            default: self = .Unavailable(cause: BKUnavailabilityCause(peripheralManagerState: peripheralManagerState))
        }
    }
    
}

/**
    Bluetooth LE unavailability cause.
    - Any: When initialized with nil.
    - Resetting: Bluetooth is resetting.
    - Unsupported: Bluetooth LE is not supported on the device.
    - Unauthorized: The app isn't allowed to use Bluetooth.
    - PoweredOff: Bluetooth is turned off.
*/
public enum BKUnavailabilityCause: NilLiteralConvertible {
    
    case Any
    case Resetting
    case Unsupported
    case Unauthorized
    case PoweredOff
    
    public init(nilLiteral: Void) {
        self = Any
    }
    
    internal init(centralManagerState: CBCentralManagerState) {
        switch centralManagerState {
            case .PoweredOff: self = PoweredOff
            case .Resetting: self = Resetting
            case .Unauthorized: self = Unauthorized
            case .Unsupported: self = Unsupported
            default: self = nil
        }
    }
    
    internal init(peripheralManagerState: CBPeripheralManagerState) {
        switch peripheralManagerState {
            case .PoweredOff: self = PoweredOff
            case .Resetting: self = Resetting
            case .Unauthorized: self = Unauthorized
            case .Unsupported: self = Unsupported
            default: self = nil
        }
    }
    
}

/**
    Classes that can be observed for Bluetooth LE availability implement this protocol.
*/
public protocol BKAvailabilityObservable: class {
    var availabilityObservers: [BKWeakAvailabilityObserver] { get set }
    func addAvailabilityObserver(availabilityObserver: BKAvailabilityObserver)
    func removeAvailabilityObserver(availabilityObserver: BKAvailabilityObserver)
}

/**
    Class used to hold a weak reference to an observer of Bluetooth LE availability.
*/
public class BKWeakAvailabilityObserver {
    weak var availabilityObserver : BKAvailabilityObserver?
    init (availabilityObserver: BKAvailabilityObserver) {
        self.availabilityObserver = availabilityObserver
    }
}

public extension BKAvailabilityObservable {
    
    /**
        Add a new availability observer. The observer will be weakly stored. If the observer is already subscribed the call will be ignored.
        - parameter availabilityObserver: The availability observer to add.
    */
    func addAvailabilityObserver(availabilityObserver: BKAvailabilityObserver) {
        if !availabilityObservers.contains({ $0.availabilityObserver === availabilityObserver }) {
            availabilityObservers.append(BKWeakAvailabilityObserver(availabilityObserver: availabilityObserver))
        }
    }
    
    /**
        Remove an availability observer. If the observer isn't subscribed the call will be ignored.
        - parameter availabilityObserver: The availability observer to remove.
    */
    func removeAvailabilityObserver(availabilityObserver: BKAvailabilityObserver) {
        if availabilityObservers.contains({ $0.availabilityObserver === availabilityObserver }) {
            availabilityObservers.removeAtIndex(availabilityObservers.indexOf({ $0 === availabilityObserver })!)
        }
    }
    
}

/**
    Observers of Bluetooth LE availability should implement this protocol.
*/
public protocol BKAvailabilityObserver: class {
    
    /**
        Informs the observer about a change in Bluetooth LE availability.
        - parameter availabilityObservable: The object that registered the availability change.
        - parameter availability: The new availability value.
    */
    func availabilityObserver(availabilityObservable: BKAvailabilityObservable, availabilityDidChange availability: BKAvailability)
    
    /**
        Informs the observer that the cause of Bluetooth LE unavailability changed.
        - parameter availabilityObservable: The object that registered the cause change.
        - parameter unavailabilityCause: The new cause of unavailability.
    */
    func availabilityObserver(availabilityObservable: BKAvailabilityObservable, unavailabilityCauseDidChange unavailabilityCause: BKUnavailabilityCause)
}
