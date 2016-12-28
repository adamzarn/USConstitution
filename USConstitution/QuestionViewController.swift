//
//  QuestionViewController.swift
//  USConstitution
//
//  Created by Adam Zarn on 12/27/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import UIKit

class QuestionViewController: UIViewController {
    
    @IBOutlet weak var questionLabel: UILabel!
    
    @IBOutlet weak var answerButton1: UIButton!
    @IBOutlet weak var answerButton2: UIButton!
    @IBOutlet weak var answerButton3: UIButton!
    @IBOutlet weak var answerButton4: UIButton!
    
    var timeBar: UIButton!
    var elapsedTimeBar: UIButton!
    
    var questionTimer: Timer!
    var quizzes: [Quiz]!
    
    let screenRect = UIScreen.main.bounds
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timeBar = UIButton(frame: CGRect(x: 10, y: screenRect.height/2, width: screenRect.width-20, height: 40))
        timeBar.layer.cornerRadius = 20
        timeBar.backgroundColor = .blue
        self.view.addSubview(timeBar)
        
        elapsedTimeBar = UIButton(frame: CGRect(x: screenRect.width - 10, y: screenRect.height/2, width: 0, height: 40))
        elapsedTimeBar.backgroundColor = .white
        self.view.addSubview(elapsedTimeBar)
        self.view.bringSubview(toFront: elapsedTimeBar)
        
        FirebaseClient.sharedInstance.getQuestions(level: "CitizenQuestions", completion: { (quizzes, error) -> () in
            if let quizzes = quizzes {
                self.quizzes = quizzes
                for quiz in quizzes {
                    print(quiz.question)
                    print(quiz.correctAnswer)
                    print(quiz.answers)
                    print("")
                }
            } else {
                print(error!)
            }
        })
        
        //questionTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateTimeLeft), userInfo: nil, repeats: true)
        
    }
    
    func setUpView() {
        
    }
    
    func updateTimeLeft() {
        let growthLength = (screenRect.width - 20)/2000
        let newWidth = elapsedTimeBar.frame.size.width + growthLength
        if newWidth <= screenRect.width - 20 {
            elapsedTimeBar.frame = CGRect(x: screenRect.width - 10 - newWidth, y: screenRect.height/2, width: newWidth, height: 40)
        } else {
            questionTimer.invalidate()
        }
    }
    
}
