//
//  ScoreCell.swift
//  Constitution Quizzer
//
//  Created by Adam Zarn on 9/12/17.
//  Copyright © 2017 Adam Zarn. All rights reserved.
//

import UIKit

class ScoreCell: UITableViewCell {
    
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    
    func setUpCell(row: Int, score: String, date: String, user: String) {
        
        rankLabel.text = "\(row + 1).";
        scoreLabel.text = score;
        dateLabel.text = date;
        userLabel.text = user;
        
    }
    
    
}
