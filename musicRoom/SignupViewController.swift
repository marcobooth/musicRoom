//
//  SignupViewController.swift
//  musicRoom
//
//  Created by Marco BOOTH on 6/11/17.
//  Copyright © 2017 Marco BOOTH. All rights reserved.
//

import UIKit
import Firebase

class SignupViewController: UIViewController {
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var passwordConfirmation: UITextField!

    @IBAction func signupAction(_ sender: UIButton) {
        if let email = self.email.text, let password = self.password.text {
            guard self.password.text == self.passwordConfirmation.text else {
                self.showBasicAlert(title: "Uh oh", message: "The passwords you entered don't match")
                
                return
            }
            
            Auth.auth().createUser(withEmail: email, password: password) { user, error in
                if let error = error {
                    print("Error creating user:", error as Any)
                    self.showBasicAlert(title: "Error", message: "There was a problem creating your account.")
                } else {
                    user?.sendEmailVerification { error in
                        if let error = error {
                            print("Error sending verification email:", error as Any)
                            self.showBasicAlert(title: "Error", message: "There was a problem sending your verification email.")
                        } else {
                            let alert = UIAlertController(title: "Welcome!", message: "Verify your email in order to log in for the first time.", preferredStyle: UIAlertControllerStyle.alert)
                            
                            alert.addAction(UIAlertAction(title: "Thanks so much - I'll be right back", style: UIAlertActionStyle.default, handler: { action in
                                self.performSegue(withIdentifier: "unwindToLogin", sender: self)
                            }))
                            
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }

    @IBAction func backToLogin(_ sender: UIButton) {
        self.performSegue(withIdentifier: "unwindToLogin", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? LoginViewController {
            destination.login.text = self.email.text
            destination.password.text = self.password.text
        }
    }

}
