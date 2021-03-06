//
//  QuestionViewController.swift
//  USConstitution
//
//  Created by Adam Zarn on 12/27/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import UIKit

class QuestionViewController: UIViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var backgroundImage: UIImageView!
    var questionLabel: UILabel!
    let green = UIColor(red: 61.0/255.0, green: 175.0/255.0, blue: 109.0/255.0, alpha: 0.7)
    
    var answerButton1: UIButton!
    var answerButton2: UIButton!
    var answerButton3: UIButton!
    var answerButton4: UIButton!
    
    var aiv: UIActivityIndicatorView!
    var saveAiv: UIActivityIndicatorView!
    var loadingLabel: UILabel!
    
    var timeBar: UIButton!
    var pointsLabel: UILabel!
    
    var scoreLabel: UILabel!
    var totalScoreLabel: UILabel!
    var correctAnswersLabel: UILabel!
    var totalCorrectAnswersLabel: UILabel!
    var incorrectAnswersLabel: UILabel!
    var totalIncorrectAnswersLabel: UILabel!
    var questionsRemainingLabel: UILabel!
    var totalQuestionsRemainingLabel: UILabel!
    var resultLabel: UILabel!
    var blankLabel: UILabel!
    
    var labels: [UILabel]!
    
    var buttons: [UIButton]!
    
    var points: Double!
    var score: Double!
    var correct: Int!
    var incorrect: Int!
    var level: String!
    
    var answersArray: [String]!
    var currentQuiz: Quiz!
    var questionTimer: Timer!
    var quizzes: [Quiz]!
    var usedQuizzes: [Quiz]!
    
    var homeButton: UIButton!
    var scoresButton: UIButton!
    
    var startQuizButton: UIButton!
    var endQuizButton: UIButton!
    
    var maxScore: Double!
    
    let screenRect = UIScreen.main.bounds
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundImage = UIImageView(frame: CGRect(x: -20, y: -20, width: screenRect.width + 40, height: screenRect.height + 40))
        backgroundImage.image = UIImage(named: "ConstitutionBackground2")
        backgroundImage.alpha = 0.7
        self.view.addSubview(backgroundImage)
        
        //Constants
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        let buttonHeight = (screenRect.height/2-40-statusBarHeight)/6
        
        //Question Label
        questionLabel = UILabel(frame: CGRect(x:10,y:statusBarHeight,width:screenRect.width-20,height:2*buttonHeight))
        questionLabel.numberOfLines = 0
        questionLabel.textAlignment = .center
        questionLabel.isHidden = true
        self.view.addSubview(questionLabel)
        
        //Result Label
        resultLabel = UILabel(frame: CGRect(x:10,y:statusBarHeight,width:screenRect.width-20,height:screenRect.height/2 - 115 - statusBarHeight))
        resultLabel.numberOfLines = 0
        resultLabel.textAlignment = .center
        resultLabel.font = UIFont.systemFont(ofSize: 24)
        resultLabel.isHidden = true
        self.view.addSubview(resultLabel)
        
        //Answer Buttons
        
        answerButton1 = UIButton()
        answerButton2 = UIButton()
        answerButton3 = UIButton()
        answerButton4 = UIButton()
        
        buttons = [answerButton1,answerButton2,answerButton3,answerButton4]
        
        var i = 2
        for button in buttons {
            button.isHidden = true
            button.isEnabled = false
            button.frame = CGRect(x:10,y:statusBarHeight+CGFloat(i)*buttonHeight,width:screenRect.width-20,height:buttonHeight-5)
            button.addTarget(self, action: #selector(QuestionViewController.answerSelected(_:)), for: .touchUpInside)
            button.setTitleColor(.black, for: .normal)
            button.layer.borderColor = UIColor.black.cgColor
            button.layer.borderWidth = 1
            button.layer.cornerRadius = 5
            button.backgroundColor = UIColor.white.withAlphaComponent(0.7)
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.titleLabel?.minimumScaleFactor = 0.25
            self.view.addSubview(button)
            i += 1
        }
        
        //Loading
        aiv = UIActivityIndicatorView(frame: CGRect(x:screenRect.width/2-40,y:screenRect.height/2-40,width:80,height:80))
        aiv.color = .lightGray
        self.view.addSubview(aiv)
        
        loadingLabel = UILabel(frame: CGRect(x: 10, y: screenRect.height/2+20,width:screenRect.width-20,height:30))
        loadingLabel.text = "Loading Quiz..."
        loadingLabel.textAlignment = .center
        self.view.addSubview(loadingLabel)
    
        //Timer and Points
        timeBar = UIButton(frame: CGRect(x: 10, y: screenRect.height/2 - 20, width: screenRect.width-20, height: 40))
        timeBar.layer.cornerRadius = 20
        timeBar.backgroundColor = UIColor.blue.withAlphaComponent(0.7)
        timeBar.isHidden = true
        timeBar.isEnabled = false
        self.view.addSubview(timeBar)
        
        pointsLabel = UILabel(frame: CGRect(x: screenRect.width - 100, y: screenRect.height/2 - 20, width: 80, height: 40))
        pointsLabel.textColor = .white
        points = 20.0
        pointsLabel.text = String(points)
        pointsLabel.textAlignment = .right
        pointsLabel.isHidden = true
        self.view.addSubview(pointsLabel)
        self.view.bringSubview(toFront: pointsLabel)
        
        let bottomOfAnswerButton4 = answerButton4.frame.origin.y + answerButton4.frame.height
        let topOfTimeBar = timeBar.frame.origin.y
        let space = topOfTimeBar - bottomOfAnswerButton4
        
        //Score and Total Score, correct, incorrect, and questions remaining
        score = 0.0
        scoreLabel = UILabel(frame: CGRect(x: 10, y: screenRect.height/2 + 20 + space, width: screenRect.width - 20, height: 40))
        let scoreText = NSMutableAttributedString(string: "Score")
        scoreText.addAttribute(NSUnderlineStyleAttributeName , value: NSUnderlineStyle.styleSingle.rawValue, range: NSMakeRange(0, 5))
        scoreLabel.attributedText = scoreText
        scoreLabel.font = UIFont.systemFont(ofSize: 28)
        
        totalScoreLabel = UILabel(frame: CGRect(x: 10, y: screenRect.height/2 + 50 + space, width: screenRect.width - 20, height: 40))
        totalScoreLabel.text = "0.0"
        totalScoreLabel.font = UIFont.systemFont(ofSize: 28)
        
        let width = (screenRect.width - 40)/3
        
        correct = 0
        correctAnswersLabel = UILabel(frame: CGRect(x: 10, y: screenRect.height/2 + 110 + space, width: width, height: 20))
        let correctText = NSMutableAttributedString(string: "Correct")
        correctText.addAttribute(NSUnderlineStyleAttributeName , value: NSUnderlineStyle.styleSingle.rawValue, range: NSMakeRange(0, 7))
        correctAnswersLabel.attributedText = correctText
        
        totalCorrectAnswersLabel = UILabel(frame: CGRect(x: 10, y: screenRect.height/2 + 130 + space, width: width, height: 20))
        totalCorrectAnswersLabel.text = "0"
        
        incorrect = 0
        incorrectAnswersLabel = UILabel(frame: CGRect(x: 20 + width, y: screenRect.height/2 + 110 + space, width: width, height: 20))
        let incorrectText = NSMutableAttributedString(string: "Incorrect")
        incorrectText.addAttribute(NSUnderlineStyleAttributeName , value: NSUnderlineStyle.styleSingle.rawValue, range: NSMakeRange(0, 9))
        incorrectAnswersLabel.attributedText = incorrectText
        
        totalIncorrectAnswersLabel = UILabel(frame: CGRect(x: 20 + width, y: screenRect.height/2 + 130 + space, width: width, height: 20))
        totalIncorrectAnswersLabel.text = "0"
        
        questionsRemainingLabel = UILabel(frame: CGRect(x: 30 + 2*width, y: screenRect.height/2 + 110 + space, width: width, height: 20))
        let leftText = NSMutableAttributedString(string: "Left")
        leftText.addAttribute(NSUnderlineStyleAttributeName , value: NSUnderlineStyle.styleSingle.rawValue, range: NSMakeRange(0, 4))
        questionsRemainingLabel.attributedText = leftText
        
        totalQuestionsRemainingLabel = UILabel(frame: CGRect(x: 30 + 2*width, y: screenRect.height/2 + 130 + space, width: width, height: 20))
        totalQuestionsRemainingLabel.text = "20"
        
        blankLabel = UILabel(frame: CGRect(x: 10, y: screenRect.height/2 + 110 + space, width: screenRect.width-20, height: 40))
        blankLabel.layer.borderColor = UIColor.black.cgColor
        blankLabel.layer.borderWidth = 1
        blankLabel.layer.cornerRadius = 5
        
        labels = [scoreLabel,totalScoreLabel,correctAnswersLabel,totalCorrectAnswersLabel,incorrectAnswersLabel,totalIncorrectAnswersLabel,questionsRemainingLabel,totalQuestionsRemainingLabel,blankLabel]
        
        for label in labels {
            label.isHidden = true
            label.textAlignment = .center
            label.adjustsFontSizeToFitWidth = true
            self.view.addSubview(label)
        }
        
        //Start Quiz Button
        startQuizButton = UIButton(frame: CGRect(x:30,y:screenRect.height/2-50,width:screenRect.width-60, height: 100))
        startQuizButton.setTitle("Start Quiz", for: .normal)
        startQuizButton.titleLabel?.font = startQuizButton.titleLabel?.font.withSize(40.0)
        startQuizButton.backgroundColor = UIColor.blue.withAlphaComponent(0.7)
        startQuizButton.titleLabel?.textAlignment = .center
        startQuizButton.layer.cornerRadius = 50
        startQuizButton.addTarget(self, action: #selector(QuestionViewController.nextButtonPressed(_:)), for: .touchUpInside)
        startQuizButton.isHidden = true
        
        endQuizButton = UIButton(frame: CGRect(x:10,y:screenRect.height-50,width:screenRect.width-20, height: 40))
        endQuizButton.setTitle("Cancel", for: .normal)
        endQuizButton.titleLabel?.font = endQuizButton.titleLabel?.font.withSize(17.0)
        endQuizButton.backgroundColor = UIColor.red.withAlphaComponent(0.7)
        endQuizButton.titleLabel?.textAlignment = .center
        endQuizButton.layer.cornerRadius = 5
        endQuizButton.addTarget(self, action: #selector(QuestionViewController.endQuizButtonPressed(_:)), for: .touchUpInside)
        self.view.addSubview(endQuizButton)
        
        saveAiv = UIActivityIndicatorView(frame: CGRect(x: 10, y: 10, width: 20, height: 20))
        saveAiv.color = .white
        saveAiv.isHidden = true
        startQuizButton.addSubview(saveAiv)
        self.view.addSubview(startQuizButton)
        
        //Home and Scores Buttons
        homeButton = UIButton(frame: CGRect(x:10,y:screenRect.height-50,width:screenRect.width/2-15, height: 40))
        homeButton.backgroundColor = UIColor.red.withAlphaComponent(0.7)
        homeButton.setTitle("Home", for: .normal)
        homeButton.titleLabel?.textAlignment = .center
        homeButton.layer.cornerRadius = 5
        homeButton.addTarget(self, action: #selector(QuestionViewController.homeButtonPressed(_:)), for: .touchUpInside)
        homeButton.isHidden = true
        homeButton.isEnabled = false
        self.view.addSubview(homeButton)
        
        scoresButton = UIButton(frame: CGRect(x:screenRect.width/2+5,y:screenRect.height-50,width:screenRect.width/2-15, height: 40))
        scoresButton.backgroundColor = UIColor.blue.withAlphaComponent(0.7)
        scoresButton.setTitle("Scores", for: .normal)
        scoresButton.titleLabel?.textAlignment = .center
        scoresButton.layer.cornerRadius = 5
        scoresButton.addTarget(self, action: #selector(QuestionViewController.scoresButtonPressed(_:)), for: .touchUpInside)
        scoresButton.isHidden = true
        scoresButton.isEnabled = false
        self.view.addSubview(scoresButton)
        
        //Get Questions
        
        if appDelegate.level == "citizen" {
            self.level = "CitizenQuestions"
            if let quizzes = appDelegate.CitizenQuestions {
                self.quizzes = quizzes
            }
        } else if appDelegate.level == "patriot" {
            self.level = "PatriotQuestions"
            if let quizzes = appDelegate.PatriotQuestions {
                self.quizzes = quizzes
            }
        } else {
            self.level = "FoundingFatherQuestions"
            if let quizzes = appDelegate.FoundingFatherQuestions {
                self.quizzes = quizzes
            }
        }
        
        if quizzes != nil {
            
            randomlySelectQuestions(number: 20)
            loadingLabel.isHidden = true
            startQuizButton.isHidden = false
            startQuizButton.isEnabled = true
            totalQuestionsRemainingLabel.text = String(quizzes.count)
            maxScore = 20.0 * Double(quizzes.count)
        
        } else {
            
            aiv.startAnimating()
            loadingLabel.isHidden = false
            
            if GlobalFunctions.shared.hasConnectivity() {
            
                FirebaseClient.sharedInstance.getQuestions(level: level, completion: { (quizzes, error) -> () in
                    if let quizzes = quizzes {
                        self.quizzes = quizzes
                        if self.level == "CitizenQuestions" {
                            self.appDelegate.CitizenQuestions = quizzes
                        } else if self.level == "PatriotQuestions" {
                            self.appDelegate.PatriotQuestions = quizzes
                        } else {
                            self.appDelegate.FoundingFatherQuestions = quizzes
                        }
                        
                        //Now that all questions are saved, randomly select certain amount
                        self.randomlySelectQuestions(number: 20)
                        
                        self.aiv.stopAnimating()
                        self.aiv.isHidden = true
                        self.loadingLabel.isHidden = true
                        self.startQuizButton.isHidden = false
                        self.startQuizButton.isEnabled = true
                        self.totalQuestionsRemainingLabel.text = String(self.quizzes.count)
                        self.maxScore = 20.0 * Double(self.quizzes.count)
                    } else {
                        print(error!)
                    }
                })
                
            }
        
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        usedQuizzes = []
        
        if !GlobalFunctions.shared.hasConnectivity() {
        
            self.aiv.stopAnimating()
            self.aiv.isHidden = true
            self.loadingLabel.isHidden = true
            let alert = UIAlertController(title: "No Internet Connectivity", message: "Unable to retrieve questions. Establish an Internet Connection and try again.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { (_) in
                let slvc = self.storyboard?.instantiateViewController(withIdentifier: "SelectLevelViewController") as! SelectLevelViewController
                self.present(slvc, animated: false, completion: nil)
            })
            self.present(alert, animated: false, completion: nil)
            
        }
        
    }

    func randomlySelectQuestions(number: Int) {
        var i = 0
        while quizzes.count > number {
            let numberOfQuestionsRemaining = quizzes.count
            let randomNumber = arc4random_uniform(UInt32(numberOfQuestionsRemaining))
            quizzes.remove(at: Int(randomNumber))
            i = i + 1
        }
    }
    
    func setUpView() {
        answerButton4.isHidden = false
        let index = arc4random_uniform(UInt32(quizzes.count))
        var i = 0
        if quizzes.count > 0 {
            points = 20
            timeBar.frame = CGRect(x: 10, y: screenRect.height/2 - 20, width: screenRect.width-20, height: 40)
            for quiz in quizzes {
                if Int(index) == i {
                    
                    currentQuiz = quiz
                    answersArray = []
                    var answers = quiz.answers
                    for i in 0...3 {
                        if answers[i] == "" {
                            answers.remove(at: i)
                            break
                        }
                    }
                    var j = answers.count

                    while j > 0 {
                        let rand = arc4random_uniform(UInt32(j))
                        answersArray.append(answers[Int(rand)])
                        answers.remove(at: Int(rand))
                        j -= 1
                    }
                    
                    questionLabel.text = quiz.question
                    answerButton1.setTitle(answersArray[0], for: .normal)
                    answerButton2.setTitle(answersArray[1], for: .normal)
                    answerButton3.setTitle(answersArray[2], for: .normal)
                    if answersArray.count == 4 {
                        answerButton4.setTitle(answersArray[3], for: .normal)
                    } else {
                        answerButton4.setTitle("", for: .normal)
                        answerButton4.isHidden = true
                    }

                    usedQuizzes.append(quiz)
                    quizzes.remove(at: i)
                    questionTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTimeLeft), userInfo: nil, repeats: true)
                    
                    break
                }
                i += 1
            }
            
        } else {
            
            for button in buttons {
                button.isEnabled = false
            }

            saveAiv.startAnimating()
            saveAiv.isHidden = false
            
            let result = Result(score: score, correctAnswers: totalCorrectAnswersLabel.text!, incorrectAnswers: totalIncorrectAnswersLabel.text!, timestamp: getCurrentDateAndTime(), displayName: appDelegate.displayName)
            
            if GlobalFunctions.shared.hasConnectivity() {
            
                FirebaseClient.sharedInstance.postResult(uid: self.appDelegate.uid, result: result, level: self.appDelegate.level, userLevel: self.appDelegate.userLevel, score: score, maxScore: maxScore, completion: { (message, error) -> () in
                    if let message = message {
                        self.saveAiv.isHidden = true
                        self.saveAiv.stopAnimating()
                        self.setUpResultsScreen(message: message)
                    } else {
                        print("failure")
                    }
                })
            
            } else {
    
                saveAiv.stopAnimating()
                saveAiv.isHidden = true
                
                let alert = UIAlertController(title: "No Internet Connectivity", message: "Unable to post your score. Establish an Internet Connection and try again.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default) { (_) in
                    self.startQuizButton.isEnabled = true
                    self.startQuizButton.backgroundColor = self.startQuizButton.backgroundColor?.withAlphaComponent(0.7)
                })
                self.present(alert, animated: false, completion: nil)
                
            }
        
        }
    }

    func setUpResultsScreen(message: String) {
        
        questionLabel.isHidden = true
        for button in buttons {
            button.isHidden = true
            button.isEnabled = false
        }
        
        blankLabel.isHidden = true
        
        timeBar.isHidden = true
        pointsLabel.isHidden = true
        
        startQuizButton.isHidden = true
        startQuizButton.isEnabled = false
        endQuizButton.isHidden = true
        endQuizButton.isEnabled = false
        
        toggleButton(button: homeButton)
        toggleButton(button: scoresButton)
        
        scoreLabel.frame = CGRect(x: 10, y: screenRect.height/2 - 115, width: screenRect.width - 20, height: 50)
        scoreLabel.font = scoreLabel.font.withSize(50.0)
        totalScoreLabel.frame = CGRect(x: 10, y: screenRect.height/2 - 55, width: screenRect.width - 20, height: 50)
        totalScoreLabel.font = totalScoreLabel.font.withSize(50.0)
        
        resultLabel.isHidden = false
        
        resultLabel.text = message
        
        let width = (screenRect.width - 30)/2
        
        correctAnswersLabel.frame = CGRect(x: 10, y: screenRect.height/2 + 105, width: width, height: 20)
        totalCorrectAnswersLabel.frame = CGRect(x: 10, y: screenRect.height/2 + 130, width: width, height: 20)
        incorrectAnswersLabel.frame = CGRect(x: 20 + width, y: screenRect.height/2 + 105, width: width, height: 20)
        totalIncorrectAnswersLabel.frame = CGRect(x: 20 + width, y: screenRect.height/2 + 130, width: width, height: 20)
        questionsRemainingLabel.isHidden = true
        totalQuestionsRemainingLabel.isHidden = true
        
    }
    
    func getCurrentDateAndTime() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd HH:mm:ss:SSS"
        let stringDate = formatter.string(from: date)
        return stringDate
    }
    
    func updateTimeLeft() {
        let growthLength = (screenRect.width - 20)/200
        let newWidth = timeBar.frame.size.width - growthLength
        if newWidth >= 0 {
            timeBar.frame = CGRect(x: 10, y: screenRect.height/2-20, width: newWidth, height: 40)
            pointsLabel.frame = CGRect(x: newWidth - 80, y: screenRect.height/2-20, width: 80, height: 40)
            points = points - 0.1
            pointsLabel.text = String(format:"%.1f", points)
            if newWidth < (screenRect.width - 20)/10 {
                pointsLabel.isHidden = true
            } else {
                pointsLabel.isHidden = false
            }
        } else {
            questionTimer.invalidate()
            incorrectAnswerActions()
            for button in buttons {
                button.isEnabled = false
            }
            if quizzes.count == 0 {
                startQuizButton.setTitle("Save Quiz", for: .normal)
            }
        }
    }
    
    func nextButtonPressed(_ sender: Any) {
    
        if startQuizButton.titleLabel?.text == "Start Quiz" {
            startQuizButton.frame = CGRect(x:screenRect.width/2+5,y:screenRect.height-50,width:screenRect.width/2-15, height: 40)
            endQuizButton.frame = CGRect(x:10,y:screenRect.height-50,width:screenRect.width/2-15, height: 40)
            startQuizButton.layer.cornerRadius = 5
            startQuizButton.titleLabel?.font = startQuizButton.titleLabel?.font.withSize(17.0)
            timeBar.isHidden = false
            questionLabel.isHidden = false
            pointsLabel.isHidden = false
            for label in labels {
                label.isHidden = false
            }
            for button in buttons {
                button.isHidden = false
                button.isEnabled = true
            }
            startQuizButton.setTitle("Next Question", for: .normal)
            endQuizButton.setTitle("End Quiz", for: .normal)
            toggleButtonEnabled(button: startQuizButton)
        } else {
            toggleButtonEnabled(button: startQuizButton)
            for button in buttons {
                button.backgroundColor = UIColor.white.withAlphaComponent(0.7)
                button.layer.borderColor = UIColor.black.cgColor
                button.setTitleColor(.black, for: .normal)
                button.isEnabled = true
            }
        }
        
        setUpView()
        
    }
    
    func toggleButtonEnabled(button: UIButton) {
        button.isEnabled = !button.isEnabled
        if button.isEnabled {
            startQuizButton.backgroundColor = startQuizButton.backgroundColor?.withAlphaComponent(0.7)
        } else {
            startQuizButton.backgroundColor = startQuizButton.backgroundColor?.withAlphaComponent(0.3)
        }
    }
    
    func toggleButton(button: UIButton) {
        button.isHidden = !button.isHidden
        button.isEnabled = !button.isEnabled
    }
    
    func correctAnswerActions() {
        totalQuestionsRemainingLabel.text = String(quizzes.count)
        toggleButtonEnabled(button: startQuizButton)
        let scoreDouble = Double(pointsLabel.text!)
        score = score + scoreDouble!
        correct = correct + 1
        totalScoreLabel.text = String(format:"%.1f", score)
        totalCorrectAnswersLabel.text = String(correct)
        
    }
    
    func incorrectAnswerActions() {
        totalQuestionsRemainingLabel.text = String(quizzes.count)
        toggleButtonEnabled(button: startQuizButton)
        incorrect = incorrect + 1
        totalIncorrectAnswersLabel.text = String(incorrect)
        for button in buttons {
            if button.titleLabel?.text == currentQuiz.correctAnswer {
                button.backgroundColor = green
                button.layer.borderColor = green.cgColor
                button.setTitleColor(.white, for: .normal)
            }
        }
        pointsLabel.text = "0.0"
    }
    
    func answerSelected(_ sender: AnyObject) {
        for button in buttons {
            button.isEnabled = false
        }
        let selection = sender as! UIButton
        if (sender as! UIButton).titleLabel?.text == currentQuiz.correctAnswer {
            correctAnswerActions()
            selection.backgroundColor = green
            selection.setTitleColor(.white, for: .normal)
            selection.layer.borderColor = green.cgColor
        } else {
            incorrectAnswerActions()
            selection.backgroundColor = UIColor.red.withAlphaComponent(0.7)
            selection.layer.borderColor = UIColor.red.cgColor
            selection.setTitleColor(.white, for: .normal)
        }
        if quizzes.count == 0 {
            startQuizButton.setTitle("Save Quiz", for: .normal)
            endQuizButton.setTitle("Discard Quiz", for: .normal)
            for button in buttons {
                button.isEnabled = false
            }
        }
        questionTimer.invalidate()
    }
    
    func homeButtonPressed(_ sender: AnyObject) {
        appDelegate.level = "None"
        let slvc = storyboard?.instantiateViewController(withIdentifier: "SelectLevelViewController") as! SelectLevelViewController
        self.present(slvc, animated: false, completion: nil)
    }
    
    func endQuizButtonPressed(_ sender: AnyObject) {
        
        if sender.titleLabel??.text == "Cancel" {
            self.appDelegate.level = "None"
            let slvc = self.storyboard?.instantiateViewController(withIdentifier: "SelectLevelViewController") as! SelectLevelViewController
            self.present(slvc, animated: false, completion: nil)
        } else {
            let alert = UIAlertController(title: endQuizButton.titleLabel?.text!, message: "This quiz will not be saved. Are you sure you want to continue?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {(alert: UIAlertAction!) in
                self.appDelegate.level = "None"
                let slvc = self.storyboard?.instantiateViewController(withIdentifier: "SelectLevelViewController") as! SelectLevelViewController
                self.present(slvc, animated: false, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
            
            self.present(alert, animated: false, completion: nil)
        }
    
    }

    func scoresButtonPressed(_ sender: AnyObject) {
        appDelegate.level = "None"
        let svc = storyboard?.instantiateViewController(withIdentifier: "ScoresViewController") as! ScoresViewController
        svc.levelIndex = ["CitizenQuestions", "PatriotQuestions", "FoundingFatherQuestions"].index(of: level)!
        self.present(svc, animated: false, completion: nil)
    }
    
}
