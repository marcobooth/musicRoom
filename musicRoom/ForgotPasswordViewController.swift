//
//  ForgotPasswordViewController.swift
//  musicRoom
//
//  Created by Marco BOOTH on 6/23/17.
//  Copyright © 2017 Marco BOOTH. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var email: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func resetPassword(_ sender: UIButton) {
        if let email = email.text {
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                if let error = error {
                    print("Error sending password reset:", error)
                    self.showBasicAlert(title: "Error", message: "There was a problem sending your password reset email.")
                } else {
                    self.showBasicAlert(title: "Done!", message: "Go check your email to reset your password.")
                    self.performSegue(withIdentifier: "backToLogin", sender: self)
                }
            }
        }
    }
    
    @IBAction func backToLogin(_ sender: UIButton) {
        self.performSegue(withIdentifier: "backToLogin", sender: self)
    }

}
