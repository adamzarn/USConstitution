//
//  SelectLevelViewController.swift
//  USConstitution
//
//  Created by Adam Zarn on 12/27/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import UIKit
import Firebase

class SelectLevelViewController: UIViewController {
    
    let screenRect = UIScreen.main.bounds
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let defaults = UserDefaults.standard
    
    var citizenButton: UIButton!
    var patriotButton: UIButton!
    var foundingFatherButton: UIButton!
    
    var welcomeLabel: UILabel!
    var statusLabel: UILabel!
    var logoutButton: UIButton!
    var scoresButton: UIButton!
    
    var citizenSubtitle: UILabel!
    var patriotSubtitle: UILabel!
    var foundingFatherSubtitle: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let statusBarHeight = Int(UIApplication.shared.statusBarFrame.height)
        let displayName = appDelegate.displayName!
        let userLevel = appDelegate.userLevel!
        
        let pad = 10
        let offset = 200
        
        scoresButton = UIButton(frame: CGRect(x:10,y:screenRect.height-50,width:screenRect.width-20, height: 40))
        scoresButton.setTitle("Scores", for: .normal)
        scoresButton.backgroundColor = .red
        scoresButton.layer.borderWidth = 1
        scoresButton.layer.borderColor = UIColor.red.cgColor
        scoresButton.layer.cornerRadius = 5
        scoresButton.addTarget(self, action: #selector(self.scoresButtonPressed(_:)), for: .touchUpInside)
        self.view.addSubview(scoresButton)
        
        let buttonWidth = Int(screenRect.width)-(pad*2)
        let usableHeight = Int(screenRect.height) - statusBarHeight - offset - Int(scoresButton.frame.height) - pad
        let buttonHeight = usableHeight/3 - pad - (pad/3)
        
        logoutButton = UIButton(frame: CGRect(x: pad, y: 40, width: Int(screenRect.width/5), height: 30))
        logoutButton.setTitle("Logout", for: .normal)
        logoutButton.setTitleColor(.blue, for: .normal)
        logoutButton.layer.borderWidth = 1
        logoutButton.layer.borderColor = UIColor.blue.cgColor
        logoutButton.layer.cornerRadius = 5
        logoutButton.addTarget(self, action: #selector(self.logoutButtonPressed(_:)), for: .touchUpInside)
        self.view.addSubview(logoutButton)
        
        welcomeLabel = UILabel(frame: CGRect(x: pad, y: 80, width: buttonWidth, height: (pad + offset + statusBarHeight - 90)/2))
        welcomeLabel.textAlignment = .center
        welcomeLabel.font = UIFont.systemFont(ofSize: 40)
        welcomeLabel.text = "Welcome \(displayName)!"
        welcomeLabel.adjustsFontSizeToFitWidth = true
        self.view.addSubview(welcomeLabel)
        
        statusLabel = UILabel(frame: CGRect(x: pad, y: 80 + (pad + offset + statusBarHeight - 90)/2, width: buttonWidth, height: 20))
        statusLabel.textAlignment = .center
        statusLabel.font = UIFont.systemFont(ofSize: 17)
        statusLabel.text = "Your Status: \(userLevel)"
        self.view.addSubview(statusLabel)
        
        citizenButton = UIButton(frame: CGRect(x: pad, y: pad + offset + statusBarHeight, width: buttonWidth, height: buttonHeight))
        patriotButton = UIButton(frame: CGRect(x: pad, y: pad + offset + statusBarHeight + (buttonHeight + pad), width: buttonWidth, height: buttonHeight))
        foundingFatherButton = UIButton(frame: CGRect(x: pad, y: pad + offset + statusBarHeight + 2*(buttonHeight + pad), width: buttonWidth, height: buttonHeight))
        
        let buttons = [citizenButton, patriotButton, foundingFatherButton]
        let colors = [UIColor.blue, UIColor.blue, UIColor.blue]
        let titles = ["Citizen Quiz", "Patriot Quiz", "Founding Father Quiz"]
        
        var i = 0
        while i < 3 {
            let btn = buttons[i]!
            let shift = CGFloat(buttonHeight/5)
            btn.contentVerticalAlignment = .top
            btn.titleEdgeInsets = UIEdgeInsets(top: shift, left: 0, bottom: 0, right: 0)
            btn.backgroundColor = colors[i]
            btn.layer.cornerRadius = 5
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 30)
            btn.setTitle(titles[i], for: .normal)
            btn.titleLabel?.textColor = .white
            self.view.addSubview(btn)
            btn.addTarget(self, action: #selector(self.levelButtonPressed(_:)), for: .touchUpInside)
            i += 1
        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        let userLevel = appDelegate.userLevel!
        
        var buttons = [citizenButton,patriotButton,foundingFatherButton]
        var subtitles = [citizenSubtitle,patriotSubtitle,foundingFatherSubtitle]
        
        var i = 0
        while i < subtitles.count {
            buttons[i]?.contentVerticalAlignment = .top
            let y = (buttons[i]?.titleLabel?.frame.origin.y)! + (buttons[i]?.titleLabel?.frame.height)!
            subtitles[i] = UILabel(frame: CGRect(x: 0, y: y, width: (buttons[i]?.frame.width)!, height: 20))
            subtitles[i]?.text = "Test"
            subtitles[i]?.textAlignment = .center
            subtitles[i]?.textColor = .white
            buttons[i]?.addSubview(subtitles[i]!)
            print("subtitle \(i) added")
            i += 1
        }
        
        if userLevel == "New" {
            subtitles[0]?.text = "Become a Citizen!"
            subtitles[1]?.text = "Locked"
            subtitles[2]?.text = "Locked"
            patriotButton.isEnabled = false
            patriotButton.backgroundColor = patriotButton.backgroundColor?.withAlphaComponent(0.3)
            foundingFatherButton.isEnabled = false
            foundingFatherButton.backgroundColor = foundingFatherButton.backgroundColor?.withAlphaComponent(0.3)
        } else if userLevel == "Citizen" {
            subtitles[0]?.text = "Achieved"
            subtitles[1]?.text = "Become a Patriot!"
            subtitles[2]?.text = "Locked"
            patriotButton.isEnabled = true
            patriotButton.backgroundColor = patriotButton.backgroundColor?.withAlphaComponent(1.0)
            foundingFatherButton.isEnabled = false
            foundingFatherButton.backgroundColor = foundingFatherButton.backgroundColor?.withAlphaComponent(0.3)
        } else if userLevel == "Patriot" {
            subtitles[0]?.text = "Achieved"
            subtitles[1]?.text = "Achieved"
            subtitles[2]?.text = "Become a Founding Father!"
            patriotButton.isEnabled = true
            patriotButton.backgroundColor = patriotButton.backgroundColor?.withAlphaComponent(1.0)
            foundingFatherButton.isEnabled = true
            foundingFatherButton.backgroundColor = foundingFatherButton.backgroundColor?.withAlphaComponent(1.0)
        } else {
            subtitles[0]?.text = "Achieved"
            subtitles[1]?.text = "Achieved"
            subtitles[2]?.text = "Achieved"
            patriotButton.isEnabled = true
            patriotButton.backgroundColor = patriotButton.backgroundColor?.withAlphaComponent(1.0)
            foundingFatherButton.isEnabled = true
            foundingFatherButton.backgroundColor = foundingFatherButton.backgroundColor?.withAlphaComponent(1.0)
        }
    
    }
    
    func levelButtonPressed(_ sender: AnyObject) {
        if sender.titleLabel??.text == "Citizen Quiz" {
            appDelegate.level = "citizen"
        } else if sender.titleLabel??.text == "Patriot Quiz" {
            appDelegate.level = "patriot"
        } else {
            appDelegate.level = "foundingFather"
        }
        let qvc = storyboard?.instantiateViewController(withIdentifier: "QuestionViewController") as! QuestionViewController
        self.present(qvc, animated: false, completion: nil)
    }
    
    func logoutButtonPressed(_ sender: Any) {
        FirebaseClient.sharedInstance.logout(vc: self)
    }
    
    func scoresButtonPressed(_ sender: AnyObject) {
        appDelegate.level = "None"
        let svc = storyboard?.instantiateViewController(withIdentifier: "ScoresViewController") as! ScoresViewController
        self.present(svc, animated: false, completion: nil)
    }

}

