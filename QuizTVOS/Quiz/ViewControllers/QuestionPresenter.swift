//
//  QuestionPresenter.swift
//  QuizTVOS
//
//  Created by mrandall on 12/26/15.
//  Copyright © 2015 mrandall. All rights reserved.
//

import Foundation
import Bond

final class QuestionPresenter {
    
    private lazy var bluetoothManager: BluetoothManager = {
        return BluetoothManager.shared
    }()
    
    var quizPlayersObservable = Observable<[QuizPlayer]>([])
    
    var searchingForPlayers = Observable<Bool>(false)
    
    init() {
        bind()
    }
    
    private func bind() {
        
        bluetoothManager.quizPlayersObservable.observe {
            self.quizPlayersObservable.value = $0
        }
        
        bluetoothManager.isScanningObservable.observe {
            self.searchingForPlayers.value = $0
        }
    }
    
    //MARK: - Find Players
    
    func addPlayers() {
        searchingForPlayers.next(true)
        bluetoothManager.startScanning()
    }
    
    //MARK: - Start Question
    
    func startQuestion() {
        quizPlayersObservable.value.forEach {
            $0.currentAnswer = nil
        }
        quizPlayersObservable.value = quizPlayersObservable.value
    }
    
}