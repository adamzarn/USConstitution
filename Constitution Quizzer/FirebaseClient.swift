//
//  FirebaseClient.swift
//  USConstitution
//
//  Created by Adam Zarn on 12/27/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import UIKit
import Firebase

class FirebaseClient: NSObject {
    
    let ref = FIRDatabase.database().reference()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func getQuestions(level: String, completion: @escaping (_ quizzes: [Quiz]?, _ error: NSString?) -> ()) {
        self.ref.child(level).observeSingleEvent(of: .value, with: { snapshot in
            if let quizzes = snapshot.value {
                var quizQuestions: [Quiz] = []
                for (_, value) in quizzes as! NSDictionary {
                    let quiz = value as! NSDictionary
                    let question = quiz["Question"] as! String
                    let correctAnswer = quiz["correctAnswer"] as! String
                    let answers = quiz["Answers"] as! NSDictionary
                    var answersArray: [String] = []
                    for (_, value) in answers {
                        let answer = value as! String
                        answersArray.append(answer)
                    }
                    let quizQuestion = Quiz(question: question, correctAnswer: correctAnswer, answers: answersArray)
                    quizQuestions.append(quizQuestion)
                }
                completion(quizQuestions, nil)
            } else {
                completion(nil, "Could not retrieve Data")
            }
        })
    }
    
    func addNewUser(uid: String, displayName: String, email: String, level: String) {
        
        let userRef = self.ref.child("Users/\(uid)")
        userRef.child("displayName").setValue(displayName)
        userRef.child("email").setValue(email)
        userRef.child("level").setValue(level)
        
        let displayNameRef = self.ref.child("DisplayNames/\(uid)")
        displayNameRef.setValue(displayName)
        
    }
    
    func doesDisplayNameExist(_ newDisplayName: String, completion: @escaping (_ exists: Bool?, _ error: NSString?) -> ()) {
        let displayNameRef = self.ref.child("DisplayNames")
        displayNameRef.queryOrderedByValue().queryEqual(toValue: "\(newDisplayName)").observeSingleEvent(of: .value, with: { snapshot in
            if (snapshot.value is NSNull ) {
                completion(false, nil)
            } else {
                completion(true, nil)
            }
        })
    }
    
    func getUserData(uid: String, completion: @escaping (_ user: User?, _ error: NSString?) -> ()) {
        self.ref.child("Users").child(uid).observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.exists() {
                let userDict = snapshot.value as! NSDictionary
                let displayName = userDict["displayName"] as! String
                let email = userDict["email"] as! String
                let level = userDict["level"] as! String
                let user = User(displayName: displayName, email: email, level: level)
                completion(user, nil)
            } else {
                completion(nil, "No Display Name Exists")
            }
        })
    }
    
    func postResult(uid: String, result: Result, level: String, userLevel: String, score: Double, maxScore: Double, completion: @escaping (_ message: String?, _ error: NSString?) -> ()) {
        
        let userLevelRef = self.ref.child("Users/\(uid)/level")
        
        var scoreNeeded = 0.7*maxScore
        switch level {
            case "patriot":
                scoreNeeded = 0.8*maxScore
            case "foundingFather":
                scoreNeeded = 0.85*maxScore
            default:
                scoreNeeded = 0.7*maxScore
        }
        
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        let stringScoreNeeded = formatter.string(from: NSNumber(value: scoreNeeded))!
        
        var message: String!
        if score >= scoreNeeded {
            if userLevel == "New" && level == "citizen" {
                message = "Congratulations, you are now a Citizen! \n The Patriot Quiz has been unlocked!"
                userLevelRef.setValue("Citizen")
                self.appDelegate.userLevel = "Citizen"
            } else if userLevel == "Citizen" && level == "patriot" {
                message = "Congratulations, you are now a Patriot! \n The Founding Father Quiz has been unlocked!"
                userLevelRef.setValue("Patriot")
                self.appDelegate.userLevel = "Patriot"
            } else if userLevel == "Patriot" && level == "foundingFather" {
                message = "Congratulations, you are now a Founding Father! \n Keep playing to climb up the leaderboard!"
                userLevelRef.setValue("Founding Father")
                self.appDelegate.userLevel = "Founding Father"
            } else {
                message = "Great job!"
            }
        } else {
            
            var levelAttempted = 1
            var levelAchieved = 0
            
            switch level {
                case "patriot":
                    levelAttempted = 2
                case "foundingFather":
                    levelAttempted = 3
                default:
                    levelAttempted = 1
            }
            
            switch userLevel {
                case "Citizen":
                    levelAchieved = 1
                case "Patriot":
                    levelAchieved = 2
                case "Founding Father":
                    levelAchieved = 3
                default:
                    levelAchieved = 0
            }
            
            if levelAchieved < levelAttempted {
                message = "Better luck next time. \n You need \(stringScoreNeeded) points to unlock the next quiz."
            } else if levelAchieved >= levelAttempted {
                message = "Not your best showing. \n Keep working at it though!"
            }
        }
        
        self.ref.child("Users/\(uid)/\(level)Results").observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.exists() {
                self.updateDatabase(score: score, result: result, scoresAllowed: 20, data: snapshot.value as! NSDictionary, path: "Users/\(uid)/\(level)Results", type: "MyScores")
            } else {
                let userScoreRef = self.ref.child("Users/\(uid)/\(level)Results").childByAutoId()
                userScoreRef.setValue(result.toAnyObject())
            }
        })
        
        self.ref.child("TopScores/\(level)").observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.exists() {
                self.updateDatabase(score: score, result: result, scoresAllowed: 20, data: snapshot.value as! NSDictionary, path: "TopScores/\(level)", type: "TopScores")
                completion(message, nil)
            } else {
                let topScoreRef = self.ref.child("TopScores/\(level)").childByAutoId()
                topScoreRef.setValue(result.toAnyObject())
                completion(message, nil)
            }
        })
        
    }
    
    func updateDatabase(score: Double, result: Result, scoresAllowed: Int, data: NSDictionary, path: String, type: String) {
        var min = 10000.0

        var potentialKeyToRemove = ""
        for (key, value) in data {
            let value = value as! NSDictionary
            let existingScore = value["score"] as! Double
            let displayName = value["displayName"] as! String
            
            if type == "TopScores" {
                if result.displayName == displayName {
                    if score > existingScore {
                        let scoreRef = self.ref.child(path).child(key as! String)
                        scoreRef.setValue(result.toAnyObject())
                        return
                    } else {
                        return
                    }
                }
            }
            
            if existingScore < min {
                min = existingScore
                potentialKeyToRemove = key as! String
            }
            
        }
        
        if score > min && data.count == scoresAllowed {
            let scoreRef = self.ref.child(path).childByAutoId()
            scoreRef.setValue(result.toAnyObject())
            let refToDelete = self.ref.child("\(path)/\(potentialKeyToRemove)")
            refToDelete.setValue(nil)
        }
        
        if data.count < scoresAllowed {
            let scoreRef = self.ref.child(path).childByAutoId()
            scoreRef.setValue(result.toAnyObject())
        }
    }
    
    func getScores(path: String, completion: @escaping (_ scores: [Result]?, _ error: NSString?) -> ()) {
        self.ref.child(path).queryOrdered(byChild: "score").observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.exists() {
                let results = snapshot.value as! NSDictionary
                var scores: [Result] = []
                for (_, value) in results {
                    let result = value as! NSDictionary
                    let score = result.value(forKey: "score")!
                    let correctAnswers = result["correctAnswers"] as! String
                    let incorrectAnswers = result["incorrectAnswers"] as! String
                    let timestamp = result["timestamp"] as! String
                    let displayName = result["displayName"] as! String
                    let newScore = Result(score: score as! Double, correctAnswers: correctAnswers, incorrectAnswers: incorrectAnswers, timestamp: timestamp, displayName: displayName)
                    scores.append(newScore)
                }
                completion(scores, nil)
            } else {
                completion([], nil)
            }
        })
    }

    
    func logout(vc: UIViewController) {
        do {
            try FIRAuth.auth()?.signOut()
            let loginVC = vc.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            vc.present(loginVC, animated: false, completion: nil)
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError)")
        }
    }

    
    static let sharedInstance = FirebaseClient()
    private override init() {
        super.init()
    }

}
