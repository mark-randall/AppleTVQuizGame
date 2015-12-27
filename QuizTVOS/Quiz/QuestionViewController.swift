//
//  QuestionViewController.swift
//  QuizTVOS
//
//  Created by mrandall on 12/24/15.
//  Copyright © 2015 mrandall. All rights reserved.
//

import UIKit
import Bond

final class QuestionViewController: UIViewController {

    //MARK: - Presenter
    
    lazy var presenter: QuestionPresenter = {
        return QuestionPresenter()
    }()
    
    //MARK: - Subviews
    
    @IBOutlet private weak var playerStackView: UIStackView!
    @IBOutlet private weak var addPlayerButton: UIButton!
    @IBOutlet private weak var startQuestionButton: UIButton!
    @IBOutlet private weak var searchingForPlayersView: UIView!
    
    //MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //MARK: Bind Data
    
    private func bind() {
        
        presenter.quizPlayersObservable.observe { players in
            
            //reset stackview
            while let subview = self.playerStackView.arrangedSubviews.last {
                subview.removeFromSuperview()
            }
            
            //add new stackview arrangedViews
            players.forEach {
                self.playerStackView.addArrangedSubview(QuizPlayerView(quizPlayer: $0))
            }
            
            //display question button if we have no players
            self.startQuestionButton.enabled = players.count > 0
        }
        
        presenter.searchingForPlayers.observe {
            
            //disable add button if already searching
            self.addPlayerButton.enabled = !$0
            self.searchingForPlayersView.hidden = !$0
        }
    }
    
    //MARK: - Actions
    
    @IBAction func startQuestionButtonTapped(sender: AnyObject?) {
        presenter.startQuestion()
    }
    
    @IBAction func addPlayerButtonTapped(sender: AnyObject?) {
        presenter.addPlayers()
    }
}

