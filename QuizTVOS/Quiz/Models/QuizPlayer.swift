//
//  QuizPlayer.swift
//  BulletinBoardTVOS
//
//  Created by mrandall on 12/26/15.
//  Copyright © 2015 mrandall. All rights reserved.
//

import UIKit
import CoreBluetooth

//QuizPlayer model backed by CBPeripheral for QuizPlayer Service
final class QuizPlayer: Equatable {

    let peripheral: CBPeripheral
    
    var id: String?
    var playerName: String = "Unknown"
    var currentAnswer: String?
    var playerColor: UIColor = UIColor.grayColor()
    
    /// Init with backing CBPeripheral
    ///
    /// - Parameter peripheral: CBPeripheral
    init(peripheral: CBPeripheral) {
        self.peripheral = peripheral
    }
}

//MARK: - Equatable

func ==(lhs: QuizPlayer, rhs: QuizPlayer) -> Bool {
    return lhs.peripheral.identifier == rhs.peripheral.identifier
}
