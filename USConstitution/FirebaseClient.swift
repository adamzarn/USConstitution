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
        self.ref.observeSingleEvent(of: .value, with: { snapshot in
            if let quizzes = (snapshot.value! as! NSDictionary)[level] {
                var quizQuestions: [Quiz] = []
                for (_, value) in quizzes as! NSDictionary {
                    let quiz = value as! NSDictionary
                    let question = quiz["question"] as! String
                    let correctAnswer = quiz["correctAnswer"] as! String
                    let answers = quiz["answers"] as! NSDictionary
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
    
    static let sharedInstance = FirebaseClient()
    private override init() {
        super.init()
    }

}
