//
//  CreateProfileViewController.swift
//  USConstitution
//
//  Created by Adam Zarn on 12/31/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import UIKit
import Firebase

class CreateProfileViewController: UIViewController, UITextFieldDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let screenRect = UIScreen.main.bounds
    
    var createProfileLabel: UILabel!
    var displayNameTextField: CustomTextField!
    var emailTextField: CustomTextField!
    var passwordTextField: CustomTextField!
    var verifyPasswordTextField: CustomTextField!
    var aiv: UIActivityIndicatorView!
    var backgroundImage: UIImageView!
    var submitButton: UIButton!
    var cancelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createProfileLabel = UILabel(frame: CGRect(x: 20, y: 40, width: screenRect.width-40, height: 40))
        displayNameTextField = CustomTextField(frame: CGRect(x: 20, y: 90, width: screenRect.width-40, height: 40))
        emailTextField = CustomTextField(frame: CGRect(x: 20, y: 140, width: screenRect.width-40, height: 40))
        passwordTextField = CustomTextField(frame: CGRect(x: 20, y: 190, width: screenRect.width-40, height: 40))
        verifyPasswordTextField = CustomTextField(frame: CGRect(x: 20, y: 240, width: screenRect.width-40, height: 40))
        
        passwordTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        
        createProfileLabel.text = "Create Profile"
        createProfileLabel.font = UIFont(name: "Canterbury", size: 30.0)
        createProfileLabel.textAlignment = .center
        displayNameTextField.placeholder = "Display Name"
        emailTextField.placeholder = "Email"
        emailTextField.keyboardType = .emailAddress
        passwordTextField.placeholder = "Password"
        verifyPasswordTextField.placeholder = "Verify Password"
        
        verifyPasswordTextField.isEnabled = false
        passwordTextField.isSecureTextEntry = true
        verifyPasswordTextField.isSecureTextEntry = true
        
        backgroundImage = UIImageView(frame: CGRect(x: -20, y: -20, width: screenRect.width + 40, height: screenRect.height + 40))
        backgroundImage.image = UIImage(named: "ConstitutionBackground2")
        backgroundImage.alpha = 0.7
        
        self.view.addSubview(backgroundImage)
        
        let textFields = [displayNameTextField,emailTextField,passwordTextField,verifyPasswordTextField]
        
        for tf in textFields {
            tf!.autocapitalizationType = .none
            tf!.autocorrectionType = .no
            tf!.layer.borderWidth = 1
            tf!.layer.borderColor = UIColor.black.cgColor
            tf!.layer.cornerRadius = 5
            tf!.backgroundColor = UIColor.white.withAlphaComponent(0.7)
            self.view.addSubview(tf!)
            tf!.delegate = self
        }
        
        aiv = UIActivityIndicatorView(frame: CGRect(x: screenRect.width/2-20, y: 290, width: 40, height: 40))
        aiv.color = .black
        aiv.isHidden = true
        
        submitButton = UIButton(frame: CGRect(x: 20, y: screenRect.height - 110, width: screenRect.width - 40, height: 40))
        submitButton.setTitle("Submit",for:.normal)
        submitButton.setTitleColor(.black,for:.normal)
        submitButton.layer.borderWidth = 1
        submitButton.layer.cornerRadius = 5
        submitButton.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        submitButton.addTarget(self, action: #selector(CreateProfileViewController.submitButtonPressed(_:)), for: .touchUpInside)
        
        cancelButton = UIButton(frame: CGRect(x: 20, y: screenRect.height - 60, width: screenRect.width - 40, height: 40))
        cancelButton.setTitle("Cancel",for:.normal)
        cancelButton.setTitleColor(.black,for:.normal)
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.cornerRadius = 5
        cancelButton.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        cancelButton.addTarget(self, action: #selector(CreateProfileViewController.cancelButtonPressed(_:)), for: .touchUpInside)

        self.view.addSubview(createProfileLabel)
        self.view.addSubview(aiv)
        self.view.addSubview(submitButton)
        self.view.addSubview(cancelButton)
        
    }
    
    func submitButtonPressed(_ sender: Any) {
        aiv.isHidden = false
        aiv.startAnimating()
        displayNameAvailabilityCheck(displayName: displayNameTextField.text!)
    }
    
    func displayNameAvailabilityCheck(displayName: String) {
        
        if GlobalFunctions.shared.hasConnectivity() {
        
            FirebaseClient.sharedInstance.doesDisplayNameExist(displayName, completion: { (exists, error) -> () in
                if let exists = exists {
                    if exists {
                        self.aiv.isHidden = true
                        self.aiv.stopAnimating()
                        self.displayNameTextField.becomeFirstResponder()
                        let alert = UIAlertController(title: "Display Name Unavailable", message: "Please choose another display name.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: false, completion: nil)
                    } else {
                        self.verifyPassword()
                    }
                }
            })
        
        } else {
            aiv.isHidden = true
            aiv.stopAnimating()
            let alert = UIAlertController(title: "No Internet Connectivity", message: "Establish an Internet Connection and try again.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: false, completion: nil)
            
        }
    }
    
    func verifyPassword() {
        if passwordTextField.text! != verifyPasswordTextField.text! {
            self.aiv.isHidden = true
            self.aiv.stopAnimating()
            let alert = UIAlertController(title: "Password Mismatch", message: "Please make sure that your passwords match.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: false, completion: nil)
        } else {
            createUser()
        }
    }
    
    func createUser() {
        let email = emailTextField.text
        let password = passwordTextField.text
        
        if GlobalFunctions.shared.hasConnectivity() {
        
            FIRAuth.auth()?.createUser(withEmail: email!, password: password!) { (user, error) in
                if let user = user {
                    let newUser = user as FIRUser
                    self.appDelegate.userLevel = "New"
                    self.signedIn(user: user)
                    FirebaseClient.sharedInstance.addNewUser(uid: newUser.uid, displayName: self.displayNameTextField.text!, email: self.emailTextField.text!, level: "New")
                } else {
                    self.aiv.isHidden = true
                    self.aiv.stopAnimating()
                    let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: false, completion: nil)
                }
            }
            
        } else {
            
            aiv.isHidden = true
            aiv.stopAnimating()
            let alert = UIAlertController(title: "No Internet Connectivity", message: "Establish an Internet Connection and try again.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: false, completion: nil)
            
        }
        
    }
    
    func signedIn(user: FIRUser?) {
        appDelegate.uid = (user?.uid)!
        appDelegate.displayName = displayNameTextField.text!
        let slvc = self.storyboard?.instantiateViewController(withIdentifier: "SelectLevelViewController") as! SelectLevelViewController
        self.present(slvc, animated: false, completion: nil)
        aiv.stopAnimating()
        aiv.isHidden = true
    }
    
    func cancelButtonPressed(_ sender: Any) {
        let lvc = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.present(lvc, animated: false, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidChange(_ textField: UITextField) {
        if textField == passwordTextField {
            if textField.text != "" {
                verifyPasswordTextField.isEnabled = true
            } else {
                verifyPasswordTextField.isEnabled = false
            }
        }
    }
    
}

class CustomTextField: UITextField {
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x + 5, y: bounds.origin.y, width: bounds.width - 10, height: bounds.height)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x + 5, y: bounds.origin.y, width: bounds.width - 10, height: bounds.height)
    }
    
}
