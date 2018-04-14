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
import TwitterKit

class LoginViewController: UIViewController, GIDSignInUIDelegate, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var login: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signInButton: GIDSignInButton!
    @IBOutlet weak var twitterLoginButton: TWTRLogInButton!
    @IBOutlet weak var facebookLoginButton: FBSDKLoginButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginButton.layer.cornerRadius = 5
        
        if let buttonStyle = GIDSignInButtonStyle(rawValue: 1) {
            self.signInButton.style = buttonStyle
        }
        
        self.facebookLoginButton.delegate = self
        self.facebookLoginButton.readPermissions = ["public_profile"]
        
        setTwitterLoginCompletion()
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
    
    public func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        guard error == nil && result.isCancelled == false else {
            print(error ?? "no error")
            return
        }

        if let token = FBSDKAccessToken.current().tokenString {
            let credential = FacebookAuthProvider.credential(withAccessToken: token)
            FBSDKLoginManager().logOut()
            self.loginWithCredential(credential: credential)
        }
    }
    
    public func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("logging out")
    }
    
    func setTwitterLoginCompletion() {
        self.twitterLoginButton.logInCompletion = { session, error in
            guard error == nil else {
                print("Twitter error", error ?? "unkown error")
                return
            }
            
            if let authToken = session?.authToken, let secretToken = session?.authTokenSecret {
                let credential = TwitterAuthProvider.credential(withToken: authToken, secret: secretToken)
                self.loginWithCredential(credential: credential)
            }
        }
    }
    
    @IBAction func hitEnterKey(_ sender: UITextField) {
        self.view.endEditing(true)
        loginAction(self.loginButton)
    }
    
    @IBAction func loginAction(_ sender: UIButton) {
        guard let login = login.text, let password = password.text else {
            print("one of these optionals is nil - trying to log someone in")
            return
        }
        
        Auth.auth().signIn(withEmail: login, password: password) { user, error in
            if error == nil && user?.isEmailVerified == true {
                print("Logged into Firebase...")
                self.performSegue(withIdentifier: "music", sender: self)
            } else if user == nil {
                self.showBasicAlert(title: "No account", message: "We can not find any record of this account")
            } else {
                self.showEmailAlert(title: "Verify Email", message: "Please go and verify your email")
            }
        }
    }
    
    func loginWithCredential(credential : AuthCredential) {
        Auth.auth().signIn(with: credential) { user, error in
            if (error != nil) {
                print(error ?? "no error to be printed")
                return
            }
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
    
    func showEmailAlert(title : String, message : String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)

        let resendAction = UIAlertAction(title: "Resend verification email", style: UIAlertActionStyle.default) { UIAlertAction in
            print("yop")
            let user = Auth.auth().currentUser
            if let user = user {
                user.sendEmailVerification() { error in
                    print(error ?? "no error")
                }
            }
        }
        alert.addAction(UIAlertAction(title: "Ok, noted", style: UIAlertActionStyle.default, handler: nil))
        alert.addAction(resendAction)

        self.present(alert, animated: true, completion: nil)
    }
}

