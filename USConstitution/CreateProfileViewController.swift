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
    
    var displayNameTextField: CustomTextField!
    var emailTextField: CustomTextField!
    var passwordTextField: CustomTextField!
    var verifyPasswordTextField: CustomTextField!
    var aiv: UIActivityIndicatorView!
    var submitButton: UIButton!
    var cancelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayNameTextField = CustomTextField(frame: CGRect(x: 20, y: 40, width: screenRect.width-40, height: 30))
        emailTextField = CustomTextField(frame: CGRect(x: 20, y: 80, width: screenRect.width-40, height: 30))
        passwordTextField = CustomTextField(frame: CGRect(x: 20, y: 120, width: screenRect.width-40, height: 30))
        verifyPasswordTextField = CustomTextField(frame: CGRect(x: 20, y: 160, width: screenRect.width-40, height: 30))
        
        passwordTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        
        displayNameTextField.placeholder = "Display Name"
        emailTextField.placeholder = "Email"
        passwordTextField.placeholder = "Password"
        verifyPasswordTextField.placeholder = "Verify Password"
        
        verifyPasswordTextField.isEnabled = false
        passwordTextField.isSecureTextEntry = true
        verifyPasswordTextField.isSecureTextEntry = true
        
        let textFields = [displayNameTextField,emailTextField,passwordTextField,verifyPasswordTextField]
        
        for tf in textFields {
            tf!.autocapitalizationType = .none
            tf!.autocorrectionType = .no
            tf!.layer.borderWidth = 1
            tf!.layer.borderColor = UIColor.lightGray.cgColor
            tf!.layer.cornerRadius = 5
            self.view.addSubview(tf!)
            tf!.delegate = self
        }
        
        aiv = UIActivityIndicatorView(frame: CGRect(x: screenRect.width/2-50, y: 200, width: 100, height: 100))
        aiv.color = .lightGray
        aiv.isHidden = true
        
        submitButton = UIButton(frame: CGRect(x: 20, y: screenRect.height - 90, width: screenRect.width - 40, height: 30))
        submitButton.setTitle("Submit",for:.normal)
        submitButton.setTitleColor(.blue,for:.normal)
        submitButton.layer.borderWidth = 1
        submitButton.layer.cornerRadius = 5
        submitButton.addTarget(self, action: #selector(CreateProfileViewController.submitButtonPressed(_:)), for: .touchUpInside)
        
        cancelButton = UIButton(frame: CGRect(x: 20, y: screenRect.height - 50, width: screenRect.width - 40, height: 30))
        cancelButton.setTitle("Cancel",for:.normal)
        cancelButton.setTitleColor(.blue,for:.normal)
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.cornerRadius = 5
        cancelButton.addTarget(self, action: #selector(CreateProfileViewController.cancelButtonPressed(_:)), for: .touchUpInside)
        
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
        FirebaseClient.sharedInstance.getAllDisplayNames(completion: { (displayNames, error) -> () in
            if let displayNames = displayNames {
                print(displayNames)
                if displayNames.contains(displayName) {
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
        
        FIRAuth.auth()?.createUser(withEmail: email!, password: password!) { (user, error) in
            if let user = user {
                self.signedIn(user: user)
            } else {
                print("profile creation unsuccessful")
                self.aiv.isHidden = true
                self.aiv.stopAnimating()
                let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: false, completion: nil)
            }
        }
    }
    
    func signedIn(user: FIRUser?) {
        appDelegate.uid = (user?.uid)!
        appDelegate.displayName = displayNameTextField.text!
        appDelegate.userLevel = "New"
        FirebaseClient.sharedInstance.addNewUser(uid: (user?.uid)!, displayName: displayNameTextField.text!, email: emailTextField.text!, password: passwordTextField.text!, level: "New")
        print("\(user?.email!) is signed in")
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
