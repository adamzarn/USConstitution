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
                    let correctAnswer = quiz["CorrectAnswer"] as! String
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
    
    func addNewUser(uid: String, displayName: String, email: String, password: String) {
        
        let userRef = self.ref.child("Users/\(uid)")
        userRef.child("displayName").setValue(displayName)
        userRef.child("email").setValue(email)
        userRef.child("password").setValue(password)
        
        let displayNameRef = self.ref.child("DisplayNames/\(uid)")
        displayNameRef.setValue(displayName)
        
    }
    
    func getAllDisplayNames(completion: @escaping (_ displayNames: [String]?, _ error: NSString?) -> ()) {
        self.ref.child("DisplayNames").observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.exists() {
                let displayNames = (snapshot.value as! NSDictionary).allValues as! [String]
                completion(displayNames, nil)
            } else {
                completion([], nil)
            }
        })
    }
    
    func getDisplayName(uid: String, completion: @escaping (_ displayName: String?, _ error: NSString?) -> ()) {
        self.ref.child("DisplayNames").child(uid).observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.exists() {
                let displayName = snapshot.value as! String
                completion(displayName, nil)
            } else {
                completion(nil, "No Display Name Exists")
            }
        })
    }
    
    func postResult(uid: String, result: Result, level: String, completion: @escaping (_ success: Bool?, _ error: NSString?) -> ()) {
        let scoreRef = self.ref.child("Users/\(uid)/\(level)Results").childByAutoId()
        scoreRef.setValue(result.toAnyObject())
        
        let topScoreRef = self.ref.child("TopScores/\(level)").childByAutoId()
        topScoreRef.setValue(result.toAnyObject())
        
        completion(true, nil)
    }
    
    func getScores(path: String, completion: @escaping (_ scores: [Result]?, _ error: NSString?) -> ()) {
        self.ref.child(path).observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.exists() {
                let results = snapshot.value as! NSDictionary
                var scores: [Result] = []
                for (_, value) in results {
                    let result = value as! NSDictionary
                    let score = result["score"] as! String
                    let correctAnswers = result["correctAnswers"] as! String
                    let incorrectAnswers = result["incorrectAnswers"] as! String
                    let timestamp = result["timestamp"] as! String
                    let displayName = result["displayName"] as! String
                    let newScore = Result(score: score, correctAnswers: correctAnswers, incorrectAnswers: incorrectAnswers, timestamp: timestamp, displayName: displayName)
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
            print("successfully signed out")
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError)")
        }
    }

    
    static let sharedInstance = FirebaseClient()
    private override init() {
        super.init()
    }

}
