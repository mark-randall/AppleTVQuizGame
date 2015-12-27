//
//  QuizPlayerView.swift
//  BulletinBoardTVOS
//
//  Created by mrandall on 12/26/15.
//  Copyright © 2015 mrandall. All rights reserved.
//

import UIKit

class QuizPlayerView: UIView {

    //MARK: - Data
    
    private var quizPlayer: QuizPlayer?
    
    //MARK: - Subviews
    
    @IBOutlet private weak var answerLabel: UILabel!
    
    //MARK: - View Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    convenience init(quizPlayer: QuizPlayer) {
        self.init(frame: CGRectZero)
        self.quizPlayer = quizPlayer
        commonInit()
    }
    
    override func prepareForInterfaceBuilder() {
        commonInit()
    }
    
    func commonInit() {
        
        if let quizPlayer = self.quizPlayer {
            backgroundColor = quizPlayer.currentAnswer == nil ? UIColor.redColor() : UIColor.greenColor()

        }
        
    }
}
