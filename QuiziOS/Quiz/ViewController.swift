//
//  ViewController.swift
//  BulletinBoardiOS
//
//  Created by mrandall on 12/24/15.
//  Copyright © 2015 mrandall. All rights reserved.
//

import UIKit
import CloudKit

class ViewController: UIViewController {

    @IBOutlet private weak var answerTextfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        BluetoothManager.shared.start()
    }
    
    @IBAction private func submitButtonTapped(sender: AnyObject?) {
        BluetoothManager.shared.answerQuestion(answerTextfield.text ?? "")
    }
}

