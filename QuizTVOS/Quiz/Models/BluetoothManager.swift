//
//  BluetoothManager.swift
//  BulletinBoardTVOS
//
//  Created by mrandall on 12/26/15.
//  Copyright © 2015 mrandall. All rights reserved.
//

import Foundation
import CoreBluetooth
import Bond

//MARK: - Service and Characteris CBUUID

private struct Service {
    
    static let quizPlayer = CBUUID(string: "EC4EC8FA-DD02-458F-BF7E-D65943E50F86")
    struct quizPlayerCharateristic {
        static let playerId = CBUUID(string: "76FAE4EA-9D0F-49E2-885A-0D45FE7C0073")
        static let answer = CBUUID(string: "8E6942B4-2D41-4742-9096-AED89416215B")
    }
}

private struct ManagerSelectors {
    static let stopScanningTimer: Selector = "stopScanning"
}

//MARK: - BluetoothManager

final class BluetoothManager: NSObject {
    
    static let shared: BluetoothManager = {
        return BluetoothManager()
    }()
    
    //MARK: - CBCentralManager
    
    private lazy var centralManager: CBCentralManager = {
        return CBCentralManager(delegate: self, queue: nil, options: nil)
    }()
    
    //MARK: - Quiz Player
    
    //Connected QuizPlayer Peripherals
    private var quizPlayers: [CBPeripheral] = [] {
        
        didSet {
            quizPlayersObservable.value = quizPlayersObservable.value.filter {
                return quizPlayers.contains($0.peripheral)
            }
        }
        
    }
    let quizPlayersObservable = Observable<[QuizPlayer]>([])
    
    //MARK: - Scanning State
    
    private let scanningTimerDuration: NSTimeInterval = 10.0
    
    //Is manager scanning or powering up to scan
    let isScanningObservable = Observable<Bool>(false)
    
    //Timer to stop scanning
    private var stopScannerTimer: NSTimer? {
        didSet {
            oldValue?.invalidate()
        }
    }
    
    //MARK: - Init
    
    override init() {
        super.init()
    }
    
    //MARK: - Scanning
    
    func startScanning() {
        
        isScanningObservable.value = true
        
        guard centralManager.state == .PoweredOn else {
            return
        }
        
        guard stopScannerTimer == nil || stopScannerTimer?.valid == false else {
            return
        }
        
        print("BluetoothManager - start scanning")
        
        centralManager.scanForPeripheralsWithServices([Service.quizPlayer], options: nil)
        
        //stop scanning timer
        stopScannerTimer = NSTimer(
            timeInterval: scanningTimerDuration,
            target: self,
            selector: ManagerSelectors.stopScanningTimer,
            userInfo: nil,
            repeats: false)
        NSRunLoop.currentRunLoop().addTimer(stopScannerTimer!, forMode: NSRunLoopCommonModes)
    }
    
    func stopScanning() {
        
        isScanningObservable.value = false
        
        centralManager.stopScan()
        print("BluetoothManager - stop scanning")
    }
}

//MARK: - CBCentralManagerDelegate

extension BluetoothManager: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        
        guard central.state != .Unsupported else {
            print("BluetoothManager - Bluetooth is not supported")
            return
        }
        
        if central.state == .PoweredOn {
            if isScanningObservable.value == true {
                startScanning()
            }
        }
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        
        if quizPlayers.contains(peripheral) == false {
            quizPlayers.append(peripheral)
            print("Bluetooth - didDiscoverPeripheral - \(peripheral)")
            centralManager.connectPeripheral(peripheral, options: nil)
        }
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        
        peripheral.delegate = self
        peripheral.discoverServices([Service.quizPlayer])
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("Bluetooth - didFailToConnectPeripheral - \(error)")
        quizPlayers = quizPlayers.filter { $0 != peripheral }
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("Bluetooth - didDisconnectPeripheral - \(error)")
        quizPlayers = quizPlayers.filter { $0 != peripheral }
    }
}

//MARK: - CBPeripheralDelegate

extension BluetoothManager: CBPeripheralDelegate {
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        
        guard error == nil else {
            return
        }
        
        print("Bluetooth - didDiscoverServices - \(peripheral.services)")
        
        peripheral.services?.forEach { service in
        
            if service.UUID == Service.quizPlayer {
                
                peripheral.discoverCharacteristics([
                    Service.quizPlayerCharateristic.playerId,
                    Service.quizPlayerCharateristic.answer
                    ], forService: service)
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        
        print("Bluetooth - didDiscoverCharacteristicsForService - \(service)")

        if service.UUID == Service.quizPlayer {
            
            service.characteristics?.forEach { characteristic in
                
                print("--- \(characteristic)")
                
                if characteristic.UUID == Service.quizPlayerCharateristic.playerId {
                    peripheral.readValueForCharacteristic(characteristic)
                }
                
                if characteristic.UUID == Service.quizPlayerCharateristic.answer {
                    peripheral.setNotifyValue(true, forCharacteristic: characteristic)
                    peripheral.readValueForCharacteristic(characteristic)
                }
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
        print("Bluetooth - didUpdateValueForCharacteristic - \(characteristic)")
        
        if
            let value = characteristic.value,
            let stringValue = NSString(data: value, encoding: NSUTF8StringEncoding) as? String
        {
            
            if characteristic.service.UUID == Service.quizPlayer {
            
                //fetch or create QuizPlayer
                var quizPlayer: QuizPlayer
                if let existing = quizPlayersObservable.value.filter({ $0.peripheral == peripheral }).first {
                    quizPlayer = existing
                } else {
                    quizPlayer = QuizPlayer(peripheral: peripheral)
                    quizPlayersObservable.value = quizPlayersObservable.value + [quizPlayer]
                }
                
                if characteristic.UUID == Service.quizPlayerCharateristic.playerId {
                    quizPlayer.id = stringValue
                }
                
                if characteristic.UUID == Service.quizPlayerCharateristic.answer {
                    quizPlayer.currentAnswer = stringValue
                }
            }
            
            quizPlayersObservable.value = quizPlayersObservable.value
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
        guard error == nil else {
            print("Bluetooth - didUpdateNotificationStateForCharacteristic - \(error?.localizedDescription)")
            return
        }
        
    }
}