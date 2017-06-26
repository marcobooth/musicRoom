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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func signupAction(_ sender: UIButton) {
        if let email = self.email.text, let password = self.password.text, self.password.text == self.passwordConfirmation.text {
            Auth.auth().createUser(withEmail: email, password: password) { user, error in
                if error == nil {
                    user?.sendEmailVerification(completion: nil)
                    self.performSegue(withIdentifier: "unwindToLogin", sender: self)
                } else {
                    print("there was an error", error ?? "error was nil")
                }
            }
            
        }
    }

    @IBAction func backToLogin(_ sender: UIButton) {
        self.performSegue(withIdentifier: "unwindToLogin", sender: self)
    }

}
