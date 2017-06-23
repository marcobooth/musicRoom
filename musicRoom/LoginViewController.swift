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
        
        print("current user", FIRAuth.auth()?.currentUser?.uid)
        GIDSignIn.sharedInstance().uiDelegate = self
//        GIDSignIn.sharedInstance().signIn()
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
                print("logged in")
                self.performSegue(withIdentifier: "music", sender: self)
            } else {
                let alert = UIAlertController(title: "Verify Email", message: "Please go and verify your email", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok, my bad", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                print("error", error ?? "no error to print")
            }
            print("email verified", user?.isEmailVerified ?? "")
        }
    }
    
    @IBAction func loginWithFacebook(_ sender: Any) {
        let login = FBSDKLoginManager()
        login.logIn(withReadPermissions: ["public_profile"], from: self) { (result, error) in
            let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            self.loginWithCredential(credential: credential)
        }
    }
    
    func loginWithCredential(credential : FIRAuthCredential) {
        FIRAuth.auth()?.signIn(with: credential) { thing, error in
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "music", sender: self)
//                self.thisIsSilly()
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

