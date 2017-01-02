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
    
    var welcomeLabel: UILabel!
    var logoutButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let statusBarHeight = Int(UIApplication.shared.statusBarFrame.height)
        
        let pad = 20
        let offset = 150
        
        let buttonWidth = Int(screenRect.width)-(pad*2)
        let usableHeight = Int(screenRect.height)-statusBarHeight - offset
        let buttonHeight = usableHeight/3 - pad - (pad/3)
        
        logoutButton = UIButton(frame: CGRect(x: pad, y: 40, width: Int(screenRect.width/4), height: 30))
        logoutButton.setTitle("Logout", for: .normal)
        logoutButton.setTitleColor(.blue, for: .normal)
        logoutButton.layer.borderWidth = 1
        logoutButton.layer.borderColor = UIColor.blue.cgColor
        logoutButton.layer.cornerRadius = 5
        logoutButton.addTarget(self, action: #selector(self.logoutButtonPressed(_:)), for: .touchUpInside)
        self.view.addSubview(logoutButton)
        
        welcomeLabel = UILabel(frame: CGRect(x: pad, y: 40, width: buttonWidth, height: 100))
        welcomeLabel.textAlignment = .center
        welcomeLabel.font = welcomeLabel.font.withSize(100)
        welcomeLabel.adjustsFontSizeToFitWidth = true
        welcomeLabel.text = "Welcome \(appDelegate.displayName!)!"
        self.view.addSubview(welcomeLabel)
        
        let citizenButton = UIButton(frame: CGRect(x: pad, y: pad + offset + statusBarHeight, width: buttonWidth, height: buttonHeight))
        let patriotButton = UIButton(frame: CGRect(x: pad, y: pad + offset + statusBarHeight + (buttonHeight + pad), width: buttonWidth, height: buttonHeight))
        let foundingFatherButton = UIButton(frame: CGRect(x: pad, y: pad + offset + statusBarHeight + 2*(buttonHeight + pad), width: buttonWidth, height: buttonHeight))
        
        let buttons = [citizenButton, patriotButton, foundingFatherButton]
        let colors = [UIColor.blue, UIColor.blue, UIColor.blue]
        let titles = ["Citizen", "Patriot", "Founding Father"]
        
        var i = 0
        while i < 3 {
            let btn = buttons[i]
            btn.backgroundColor = colors[i]
            btn.layer.cornerRadius = 5
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 30)
            btn.setTitle(titles[i], for: .normal)
            btn.titleLabel?.textColor = .white
            self.view.addSubview(btn)
            btn.addTarget(self, action: #selector(self.levelButtonPressed(_:)), for: .touchUpInside)
            i += 1
        }
        
        patriotButton.isEnabled = defaults.bool(forKey: "patriotUnlocked")
        foundingFatherButton.isEnabled = defaults.bool(forKey: "foundingFatherUnlocked")
        if !patriotButton.isEnabled {
            patriotButton.backgroundColor = patriotButton.backgroundColor?.withAlphaComponent(0.3)
        }
        if !foundingFatherButton.isEnabled {
            foundingFatherButton.backgroundColor = foundingFatherButton.backgroundColor?.withAlphaComponent(0.3)
        }
        

    }
    
    func levelButtonPressed(_ sender: AnyObject) {
        let qvc = storyboard?.instantiateViewController(withIdentifier: "QuestionViewController") as! QuestionViewController
        self.present(qvc, animated: false, completion: nil)
        if sender.titleLabel??.text == "Citizen" {
            appDelegate.level = "citizen"
        } else if sender.titleLabel??.text == "Patriot" {
            appDelegate.level = "patriot"
        } else {
            appDelegate.level = "foundingFather"
        }
    }
    
    func logoutButtonPressed(_ sender: Any) {
        FirebaseClient.sharedInstance.logout(vc: self)
    }

}

