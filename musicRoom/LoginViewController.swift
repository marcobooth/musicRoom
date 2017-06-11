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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func loginAction(_ sender: UIButton) {
        FIRAuth.auth()?.signIn(withEmail: login.text!, password: password.text!) { user, error in
            if error == nil && user?.isEmailVerified == true {
                print("logged in")
                self.performSegue(withIdentifier: "music", sender: self)
            } else {
                print("error", error)
            }
            print("email verified", user?.isEmailVerified)
        }
    }
    
    @IBAction func loginWithFacebook(_ sender: Any) {
        let login = FBSDKLoginManager()
        login.logIn(withReadPermissions: ["public_profile"], from: self) { (result, error) in
            print(result)
            print(error)
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


//        let loginButton = FBSDKLoginButton()
//        loginButton.delegate = self
//        loginButton.center = view.center
//        view.addSubview(loginButton)
//    /**
//     Sent to the delegate when the button was used to login.
//     - Parameter loginButton: the sender
//     - Parameter result: The results of the login
//     - Parameter error: The error (if any) from the login
//     */
//    public func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error?) {
//        print(result)
////      print("error", error)
//        let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
//        print(credential)
//        FIRAuth.auth()?.signIn(with: credential) { thing in
//            print("account should have been created")
//        }
//    }
//
//
//    /**
//     Sent to the delegate when the button was used to logout.
//     - Parameter loginButton: The button that was clicked.
//     */
//    public func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
//        print("apparently I'm now logging out")
//    }

