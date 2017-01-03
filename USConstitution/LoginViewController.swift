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
    var subtitleLabel: UILabel!
    var emailTextField: CustomTextField!
    var passwordTextField: CustomTextField!
    var loginButton: UIButton!
    var createProfileButton: UIButton!
    var aiv: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        titleLabel = UILabel(frame: CGRect(x:20, y: screenRect.height/2 - 200, width: screenRect.width - 40, height: 100))
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont(name: "US Declaration", size: 100)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.text = "Constitution"
        
        subtitleLabel = UILabel(frame: CGRect(x:20, y: screenRect.height/2 - 100, width: screenRect.width - 40, height: 20))
        subtitleLabel.textAlignment = .center
        subtitleLabel.text = "Quizzer"
        
        emailTextField = CustomTextField(frame: CGRect(x: 20, y: screenRect.height/2 - 40, width: screenRect.width - 40, height: 30))
        emailTextField.layer.borderColor = UIColor.lightGray.cgColor
        emailTextField.layer.borderWidth = 1
        emailTextField.layer.cornerRadius = 5
        passwordTextField = CustomTextField(frame: CGRect(x: 20, y: screenRect.height/2, width: screenRect.width-40, height: 30))
        passwordTextField.layer.borderColor = UIColor.lightGray.cgColor
        passwordTextField.layer.borderWidth = 1
        passwordTextField.layer.cornerRadius = 5
        emailTextField.placeholder = "Email"
        passwordTextField.placeholder = "Password"
        emailTextField.autocapitalizationType = .none
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
        
        aiv = UIActivityIndicatorView(frame: CGRect(x: screenRect.width/2-50, y: screenRect.height/2 + 60, width: 100, height: 100))
        aiv.color = .lightGray
        aiv.isHidden = true
        
        createProfileButton = UIButton(frame: CGRect(x: 20, y: screenRect.height - 50, width: screenRect.width-40, height: 30))
        createProfileButton.setTitle("Create Profile",for:.normal)
        createProfileButton.setTitleColor(.blue, for: .normal)
        createProfileButton.layer.borderWidth = 1
        createProfileButton.layer.cornerRadius = 5
        createProfileButton.addTarget(self, action: #selector(LoginViewController.createProfileButtonPressed(_:)), for: .touchUpInside)
        
        self.view.addSubview(titleLabel)
        self.view.addSubview(subtitleLabel)
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
                self.setUpUser(uid: user.uid)
            } else {
                self.aiv.isHidden = true
                self.aiv.stopAnimating()
                print("login unsuccessful")
                print(error?.localizedDescription as Any)
            }
        }
    }
    
    func setUpUser(uid: String) {
        FirebaseClient.sharedInstance.getUserData(uid: uid, completion: { (user, error) -> () in
            if let user = user {
                self.appDelegate.uid = uid
                self.appDelegate.displayName = user.displayName
                self.appDelegate.userLevel = user.level
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
