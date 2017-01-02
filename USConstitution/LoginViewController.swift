//
//  LoginViewController.swift
//  USConstitution
//
//  Created by Adam Zarn on 12/31/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let screenRect = UIScreen.main.bounds
    let defaults = UserDefaults.standard
    
    var titleLabel: UILabel!
    var emailTextField: UITextField!
    var passwordTextField: UITextField!
    var loginButton: UIButton!
    var createProfileButton: UIButton!
    var aiv: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        titleLabel = UILabel(frame: CGRect(x:20, y: screenRect.height/2 - 200, width: screenRect.width - 40, height: 100))
        titleLabel.textAlignment = .center
        titleLabel.font = titleLabel.font.withSize(100)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.text = "US Constitution"
        
        emailTextField = UITextField(frame: CGRect(x: 20, y: screenRect.height/2 - 40, width: screenRect.width - 40, height: 30))
        passwordTextField = UITextField(frame: CGRect(x: 20, y: screenRect.height/2, width: screenRect.width-40, height: 30))
        emailTextField.placeholder = "Email"
        passwordTextField.placeholder = "Password"
        passwordTextField.isSecureTextEntry = true
        
        if let email = defaults.value(forKey: "lastEmail") {
            emailTextField.text = email as? String
        }
        if let password = defaults.value(forKey: "lastPassword") {
            passwordTextField.text = password as? String
        }
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        loginButton = UIButton(frame: CGRect(x: 20, y: screenRect.height/2 + 40, width: screenRect.width-40, height: 30))
        loginButton.setTitle("Login",for:.normal)
        loginButton.setTitleColor(.blue, for: .normal)
        loginButton.layer.borderWidth = 1
        loginButton.layer.cornerRadius = 5
        loginButton.addTarget(self, action: #selector(LoginViewController.loginButtonPressed(_:)), for: .touchUpInside)
        
        aiv = UIActivityIndicatorView(frame: CGRect(x: screenRect.width/2-50, y: screenRect.height/2 + 80, width: 100, height: 100))
        aiv.color = .lightGray
        aiv.isHidden = true
        
        createProfileButton = UIButton(frame: CGRect(x: 20, y: screenRect.height - 50, width: screenRect.width-40, height: 30))
        createProfileButton.setTitle("Create Profile",for:.normal)
        createProfileButton.setTitleColor(.blue, for: .normal)
        createProfileButton.layer.borderWidth = 1
        createProfileButton.layer.cornerRadius = 5
        createProfileButton.addTarget(self, action: #selector(LoginViewController.createProfileButtonPressed(_:)), for: .touchUpInside)
        
        self.view.addSubview(titleLabel)
        self.view.addSubview(emailTextField)
        self.view.addSubview(passwordTextField)
        self.view.addSubview(loginButton)
        self.view.addSubview(aiv)
        self.view.addSubview(createProfileButton)

    }
    
    func loginButtonPressed(_ sender: AnyObject) {
        aiv.startAnimating()
        aiv.isHidden = false
        FIRAuth.auth()?.signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
            if let user = user {
                self.defaults.set(self.emailTextField.text! as String, forKey: "lastEmail")
                self.defaults.set(self.passwordTextField.text! as String, forKey: "lastPassword")
                self.setDisplayName(uid: user.uid)
            } else {
                self.aiv.isHidden = true
                self.aiv.stopAnimating()
                print("login unsuccessful")
                print(error?.localizedDescription as Any)
            }
        }
    }
    
    func setDisplayName(uid: String) {
        FirebaseClient.sharedInstance.getDisplayName(uid: uid, completion: { (displayName, error) -> () in
            if let displayName = displayName {
                self.appDelegate.uid = uid
                self.appDelegate.displayName = displayName
                let slvc = self.storyboard?.instantiateViewController(withIdentifier: "SelectLevelViewController") as! SelectLevelViewController
                self.present(slvc, animated: false, completion: nil)
            } else {
                print("something went wrong")
            }
            self.aiv.isHidden = true
            self.aiv.stopAnimating()
        })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    func createProfileButtonPressed(_ sender: AnyObject) {
        let cpvc = self.storyboard?.instantiateViewController(withIdentifier: "CreateProfileViewController") as! CreateProfileViewController
        self.present(cpvc, animated: false, completion: nil)
    }
    
}
