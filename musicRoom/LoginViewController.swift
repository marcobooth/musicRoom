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

class LoginViewController: UIViewController {
    
    @IBOutlet weak var login: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginButton.layer.cornerRadius = 5
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.view.isHidden = true
        if FIRAuth.auth()?.currentUser != nil {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "music", sender: self)
            }
        } else {
            self.view.isHidden = false
        }
    }
    
    @IBAction func hitEnterKey(_ sender: UITextField) {
        self.view.endEditing(true)
        loginAction(self.loginButton)
    }
    
    @IBAction func loginAction(_ sender: UIButton) {
        FIRAuth.auth()?.signIn(withEmail: login.text!, password: password.text!) { user, error in
            if error == nil && user?.isEmailVerified == true {
                print("Logged in...")
                self.performSegue(withIdentifier: "music", sender: self)
            } else {
                print("Login error:", error ?? "no error to print")
                
                let alert = UIAlertController(title: "Verify Email", message: "Please go and verify your email", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Resend verification email", style: UIAlertActionStyle.default, handler: { action in
                    print(action)
                }))
                alert.addAction(UIAlertAction(title: "Ok, my bad", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func loginWithFacebook(_ sender: Any) {
        let login = FBSDKLoginManager()
        login.logIn(withReadPermissions: ["public_profile"], from: self) { (result, error) in
            let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            print(credential)
            FIRAuth.auth()?.signIn(with: credential) { thing in
                self.performSegue(withIdentifier: "music", sender: self)
                print("account should have been created")
            }
        }
    }
    
    @IBAction func unwindToMenu(segue: UIStoryboardSegue) {
        print("I'm back")
    }
}

