//
//  ViewController.swift
//  musicRoom
//
//  Created by Marco BOOTH on 6/8/17.
//  Copyright © 2017 Marco BOOTH. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import GoogleSignIn

class LoginViewController: UIViewController, GIDSignInUIDelegate {
    
    @IBOutlet weak var login: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signInButton: GIDSignInButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginButton.layer.cornerRadius = 5
        
        self.signInButton.style = GIDSignInButtonStyle(rawValue: 2)!
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.view.isHidden = true
        if Auth.auth().currentUser != nil && Auth.auth().currentUser?.isEmailVerified == true {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "music", sender: self)
            }
        } else {
            self.view.isHidden = false
        }
        
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    @IBAction func hitEnterKey(_ sender: UITextField) {
        self.view.endEditing(true)
        loginAction(self.loginButton)
    }
    
    @IBAction func loginAction(_ sender: UIButton) {
        Auth.auth().signIn(withEmail: login.text!, password: password.text!) { user, error in
            if error == nil && user?.isEmailVerified == true {
                print("Logged in...")
                self.performSegue(withIdentifier: "music", sender: self)
            } else {
                self.showEmailAlert(title: "Verify Email", message: "Please go and verify your email")
            }
        }
    }
    
    @IBAction func loginWithFacebook(_ sender: Any) {
        let login = FBSDKLoginManager()
        login.logIn(withReadPermissions: ["public_profile"], from: self) { (result, error) in
            let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            self.loginWithCredential(credential: credential)
        }
    }
    
    func loginWithCredential(credential : AuthCredential) {
        Auth.auth().signIn(with: credential) { thing, error in
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "music", sender: self)
            }
        }
    }
    
    @IBAction func forgotYourPassword(_ sender: UIButton) {
        self.performSegue(withIdentifier: "forgotPassword", sender: self)
    }
    
    @IBAction func unwindToMenu(segue: UIStoryboardSegue) {
        print("I'm back")
    }
}

extension LoginViewController {
    func showEmailAlert(title : String, message : String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)

        let resendAction = UIAlertAction(title: "Resend verification email", style: UIAlertActionStyle.default) { UIAlertAction in
            print("I'm in this thing")
        }
        alert.addAction(UIAlertAction(title: "Ok, noted", style: UIAlertActionStyle.default, handler: nil))
        alert.addAction(resendAction)

        self.present(alert, animated: true, completion: nil)
    }
}

