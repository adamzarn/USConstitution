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
    var forgotPasswordButton: UIButton!
    var createProfileButton: UIButton!
    var backgroundImage: UIImageView!
    var aiv: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        titleLabel = UILabel(frame: CGRect(x:20, y: screenRect.height/2 - 200, width: screenRect.width - 40, height: 100))
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont(name: "Canterbury", size: 100)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.text = "Constitution"
        
        subtitleLabel = UILabel(frame: CGRect(x: 20, y: screenRect.height/2 - 120, width: screenRect.width - 40, height: 20))
        subtitleLabel.textAlignment = .center
        subtitleLabel.text = "Quizzer"
        
        emailTextField = CustomTextField(frame: CGRect(x: 20, y: screenRect.height/2 - 40, width: screenRect.width - 40, height: 40))
        emailTextField.layer.borderColor = UIColor.black.cgColor
        emailTextField.layer.borderWidth = 1
        emailTextField.layer.cornerRadius = 5
        emailTextField.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        passwordTextField = CustomTextField(frame: CGRect(x: 20, y: screenRect.height/2 + 10, width: screenRect.width-40, height: 40))
        passwordTextField.layer.borderColor = UIColor.black.cgColor
        passwordTextField.layer.borderWidth = 1
        passwordTextField.layer.cornerRadius = 5
        emailTextField.placeholder = "Email"
        passwordTextField.placeholder = "Password"
        passwordTextField.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        emailTextField.autocapitalizationType = .none
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocorrectionType = .no
        passwordTextField.autocorrectionType = .no
        passwordTextField.isSecureTextEntry = true
        
        if let email = defaults.value(forKey: "lastEmail") {
            emailTextField.text = email as? String
        }
        if let password = defaults.value(forKey: "lastPassword") {
            passwordTextField.text = password as? String
        }
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        loginButton = UIButton(frame: CGRect(x: 20, y: screenRect.height/2 + 60, width: screenRect.width-40, height: 40))
        loginButton.setTitle("Login",for:.normal)
        loginButton.setTitleColor(.black, for: .normal)
        loginButton.layer.borderWidth = 1
        loginButton.layer.cornerRadius = 5
        loginButton.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        loginButton.addTarget(self, action: #selector(LoginViewController.loginButtonPressed(_:)), for: .touchUpInside)
        
        
        let attributes: [String: Any] = [
            NSFontAttributeName: UIFont.systemFont(ofSize: 17.0),
            NSUnderlineStyleAttributeName : NSUnderlineStyle.styleSingle.rawValue
        ]
        
        let attributedTitle = NSMutableAttributedString(string: "Forgot Password?", attributes: attributes)
        let size = attributedTitle.size()
        forgotPasswordButton = UIButton(frame: CGRect(x: (screenRect.width/2) - size.width/2, y: screenRect.height/2 + 110, width: size.width, height: 40))
        forgotPasswordButton.setAttributedTitle(attributedTitle, for: .normal)
        forgotPasswordButton.setTitleColor(.black, for: .normal)
        forgotPasswordButton.addTarget(self, action: #selector(LoginViewController.forgotPasswordButtonPressed(_:)), for: .touchUpInside)
        
        aiv = UIActivityIndicatorView(frame: CGRect(x: screenRect.width/2-20, y: screenRect.height/2 + 150, width: 40, height: 40))
        aiv.color = .black
        aiv.isHidden = true
        
        createProfileButton = UIButton(frame: CGRect(x: 20, y: screenRect.height - 60, width: screenRect.width-40, height: 40))
        createProfileButton.setTitle("Create Profile",for:.normal)
        createProfileButton.setTitleColor(.black, for: .normal)
        createProfileButton.layer.borderWidth = 1
        createProfileButton.layer.cornerRadius = 5
        createProfileButton.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        createProfileButton.addTarget(self, action: #selector(LoginViewController.createProfileButtonPressed(_:)), for: .touchUpInside)
        
        backgroundImage = UIImageView(frame: CGRect(x: -20, y: -20, width: screenRect.width + 40, height: screenRect.height + 40))
        backgroundImage.image = UIImage(named: "ConstitutionBackground1")
        
        self.view.addSubview(backgroundImage)
        self.view.addSubview(titleLabel)
        self.view.addSubview(subtitleLabel)
        self.view.addSubview(emailTextField)
        self.view.addSubview(passwordTextField)
        self.view.addSubview(loginButton)
        self.view.addSubview(forgotPasswordButton)
        self.view.addSubview(aiv)
        self.view.addSubview(createProfileButton)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if appDelegate.firstTimeTitle {
            let rotationTransform = CATransform3DTranslate(CATransform3DIdentity, 0, -(screenRect.height/2 - 200), 0)
            titleLabel.layer.transform = rotationTransform
            subtitleLabel.layer.transform = rotationTransform
        
            UIView.animate(withDuration: 1.0, animations: { () -> Void in
            self.titleLabel.layer.transform = CATransform3DIdentity
            self.subtitleLabel.layer.transform = CATransform3DIdentity
            })
            appDelegate.firstTimeTitle = false
        }
        
    }
    
    func loginButtonPressed(_ sender: AnyObject) {
        aiv.startAnimating()
        aiv.isHidden = false
        
        if emailTextField.text == "" || passwordTextField.text == "" {
            self.aiv.isHidden = true
            self.aiv.stopAnimating()
            let alert = UIAlertController(title: "Error", message: "You must provide an email and password to login.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: false, completion: nil)
            return
        }
        
        FIRAuth.auth()?.signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
            if let user = user {
                self.defaults.set(self.emailTextField.text! as String, forKey: "lastEmail")
                self.defaults.set(self.passwordTextField.text! as String, forKey: "lastPassword")
                self.setUpUser(uid: user.uid)
            } else {
                self.aiv.isHidden = true
                self.aiv.stopAnimating()
                let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: false, completion: nil)
            }
        }
    }
    
    func forgotPasswordButtonPressed(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Send Reset Email", message: "Would you like a password reset email to be sent to the address below?", preferredStyle: .alert)
        
        let submitAction = UIAlertAction(title: "Yes", style: .default) { (_) in
            if let field = alert.textFields?[0] {
                
                let secondAlert = UIAlertController(title: "", message: "", preferredStyle: .alert)
                secondAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                
                if field.text != "" {
                    FIRAuth.auth()?.sendPasswordReset(withEmail: field.text!) { error in
                        if let errorMessage = error?.localizedDescription {
                            secondAlert.title = "Email Not Sent"
                            secondAlert.message = errorMessage
                            self.present(secondAlert, animated: false, completion: nil)
                        } else {
                            secondAlert.title = "Email Sent"
                            secondAlert.message = "Come back here when you've reset your password."
                            self.present(secondAlert, animated: false, completion: nil)
                        }
                    }
                } else {
                    secondAlert.title = "No Email"
                    secondAlert.message = "You must provide an email address."
                    self.present(secondAlert, animated: false, completion: nil)
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Email"
            textField.text = self.emailTextField.text
        }
        
        alert.addAction(submitAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
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
        textField.resignFirstResponder()
        return true
    }
    
    func createProfileButtonPressed(_ sender: AnyObject) {
        let cpvc = self.storyboard?.instantiateViewController(withIdentifier: "CreateProfileViewController") as! CreateProfileViewController
        self.present(cpvc, animated: false, completion: nil)
    }
    
}
