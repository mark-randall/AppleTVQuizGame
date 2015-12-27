//
//  BluetoothManager.swift
//  BulletinBoardiOS
//
//  Created by mrandall on 12/26/15.
//  Copyright © 2015 mrandall. All rights reserved.
//

import Foundation
import CoreBluetooth

private struct Services {
    
    static let quizPlayer = CBUUID(string: "EC4EC8FA-DD02-458F-BF7E-D65943E50F86")
    struct quizPlayerCharateristics {
        static let playerId = CBUUID(string: "76FAE4EA-9D0F-49E2-885A-0D45FE7C0073")
        static let answer = CBUUID(string: "8E6942B4-2D41-4742-9096-AED89416215B")
    }
}

final class BluetoothManager: NSObject {
    
    //MARK: - Singleton
    
    static let shared: BluetoothManager = {
        return BluetoothManager()
    }()
    
    //MARK: - Data
    
    private lazy var peripheralManager: CBPeripheralManager = { [unowned self] in
        let manager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
        return manager
    }()
    
    private lazy var quizPlayerService: CBMutableService = { [unowned self] in
        let service = CBMutableService(type: Services.quizPlayer, primary: true)
        service.characteristics = [self.quizPlayerIdCharacteristic, self.quizPlayerAnswerCharacteristic]
        return service
    }()
    
    private lazy var quizPlayerIdCharacteristic: CBMutableCharacteristic = {
        
        return CBMutableCharacteristic(
            type: Services.quizPlayerCharateristics.playerId,
            properties: [.Read],
            value: "123".dataUsingEncoding(NSUTF8StringEncoding),
            permissions: [.Readable])
        
    }()
    
    private lazy var quizPlayerAnswerCharacteristic: CBMutableCharacteristic = {
        
        return CBMutableCharacteristic(
            type: Services.quizPlayerCharateristics.answer,
            properties: [.Read, .Notify, .Write],
            value: nil,
            permissions: [.Readable, .Writeable])
    }()
    
    //MARK: - Start / Stop
    
    func start() {
        peripheralManager.state
    }
    
    func stop() {
        
    }
    
    //MARK: - Advertising
    
    private func startAdvertising() {
        peripheralManager.startAdvertising([
            CBAdvertisementDataServiceUUIDsKey: [self.quizPlayerService.UUID]
            ])
    }
    
    private func stopAdvertising() {
        peripheralManager.stopAdvertising()
    }
    
    //MARK: - Answer Question
    
    func answerQuestion(answerString: String) {
        peripheralManager.updateValue(answerString.dataUsingEncoding(NSUTF8StringEncoding)!, forCharacteristic: quizPlayerAnswerCharacteristic, onSubscribedCentrals: nil)
    }
}

//MARK: - CBPeripheralManagerDelegate

extension BluetoothManager: CBPeripheralManagerDelegate {
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        
        guard peripheral.state != .Unsupported else {
            print("BluetoothManager - Bluetooth is not supported")
            return
        }
        
        if peripheral.state == .PoweredOn {
            peripheral.addService(quizPlayerService)
            startAdvertising()
        }
        
    }

    func peripheralManager(peripheral: CBPeripheralManager, didReceiveReadRequest request: CBATTRequest) {
        
        if request.characteristic.UUID == Services.quizPlayerCharateristics.playerId {
            
            guard request.offset <= quizPlayerIdCharacteristic.value?.length else {
                peripheral.respondToRequest(request, withResult: .InvalidOffset)
                return
            }
            
            let range = NSMakeRange(request.offset, (quizPlayerIdCharacteristic.value?.length ?? 0) - request.offset)
            request.value = quizPlayerIdCharacteristic.value?.subdataWithRange(range)
            peripheral.respondToRequest(request, withResult: .Success)
        }
        
        if request.characteristic.UUID == Services.quizPlayerCharateristics.answer {
            
            guard request.offset <= quizPlayerAnswerCharacteristic.value?.length else {
                peripheral.respondToRequest(request, withResult: .InvalidOffset)
                return
            }
            
            let range = NSMakeRange(request.offset, (quizPlayerAnswerCharacteristic.value?.length ?? 0) - request.offset)
            request.value = quizPlayerAnswerCharacteristic.value?.subdataWithRange(range)
            peripheral.respondToRequest(request, withResult: .Success)
        }
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, central: CBCentral, didSubscribeToCharacteristic characteristic: CBCharacteristic) {
    }
}