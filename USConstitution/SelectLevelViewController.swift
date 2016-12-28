//
//  SelectLevelViewController.swift
//  USConstitution
//
//  Created by Adam Zarn on 12/27/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import UIKit

enum Level {
    case citizen
    case patriot
    case foundingFather
}

class SelectLevelViewController: UIViewController {
    
    let screenRect = UIScreen.main.bounds

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let statusBarHeight = Int(UIApplication.shared.statusBarFrame.height)
        
        let pad = 20
        
        let buttonWidth = Int(screenRect.width)-(pad*2)
        let usableHeight = Int(screenRect.height)-statusBarHeight
        let buttonHeight = usableHeight/3 - pad - (pad/3)
        
        let citizenButton = UIButton(frame: CGRect(x: pad, y: pad + statusBarHeight, width: buttonWidth, height: buttonHeight))
        let patriotButton = UIButton(frame: CGRect(x: pad, y: pad + statusBarHeight + (buttonHeight + pad), width: buttonWidth, height: buttonHeight))
        let foundingFatherButton = UIButton(frame: CGRect(x: pad, y: pad + statusBarHeight + 2*(buttonHeight + pad), width: buttonWidth, height: buttonHeight))
        citizenButton.addTarget(self, action: #selector(SelectLevelViewController.levelButtonPressed(_:)), for: .touchUpInside)
        patriotButton.addTarget(self, action: #selector(SelectLevelViewController.levelButtonPressed(_:)), for: .touchUpInside)
        foundingFatherButton.addTarget(self, action: #selector(SelectLevelViewController.levelButtonPressed(_:)), for: .touchUpInside)
        
        let buttons = [citizenButton, patriotButton, foundingFatherButton]
        let colors = [UIColor(red:244.0/255.0,green:141.0/255.0,blue:62.0/255.0,alpha:1.0), UIColor(red:252.0/255.0,green:186.0/255.0,blue:99.0/255.0,alpha:1.0), UIColor(red:255.0/255.0,green:238.0/255.0,blue:174.0/255.0,alpha:1.0)]
        let titles = ["Citizen", "Patriot", "Founding Father"]
        
        var i = 0
        while i < 3 {
            let btn = buttons[i]
            btn.backgroundColor = colors[i]
            btn.layer.cornerRadius = 5
            //btn.titleLabel?.minimumScaleFactor = 0.01
            //btn.titleLabel?.adjustsFontSizeToFitWidth = true
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 50)
            btn.setTitle(titles[i], for: .normal)
            btn.titleLabel?.textColor = .white
            self.view.addSubview(btn)
            i += 1
        }
    }
    
    func levelButtonPressed(_ sender: AnyObject) {
        if sender.titleLabel??.text == "Citizen" {
            let qvc = storyboard?.instantiateViewController(withIdentifier: "QuestionViewController") as! QuestionViewController
            self.present(qvc, animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

