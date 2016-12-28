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
