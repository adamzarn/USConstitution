//
//  Quiz.swift
//  USConstitution
//
//  Created by Adam Zarn on 12/27/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import Foundation

struct Quiz {
    let question: String
    let correctAnswer: String
    let answers: [String]
    
    init(question: String, correctAnswer: String, answers: [String]) {
        self.question = question
        self.correctAnswer = correctAnswer
        self.answers = answers
    }
    
}

struct Result {
    let score: String
    let correctAnswers: String
    let incorrectAnswers: String
    let timestamp: String
    let displayName: String
    
    init(score: String, correctAnswers: String, incorrectAnswers: String, timestamp: String, displayName: String) {
        self.score = score
        self.correctAnswers = correctAnswers
        self.incorrectAnswers = incorrectAnswers
        self.timestamp = timestamp
        self.displayName = displayName
    }
    
    func toAnyObject() -> AnyObject {
        return ["score": score, "correctAnswers": correctAnswers, "incorrectAnswers": incorrectAnswers, "timestamp": timestamp, "displayName": displayName] as AnyObject
    }
    
}
