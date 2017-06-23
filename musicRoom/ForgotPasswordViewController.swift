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
            FIRAuth.auth()?.sendPasswordReset(withEmail: email) { (error) in
                if error == nil {
                    print("password email sent")
                    self.performSegue(withIdentifier: "backToLogin", sender: self)
                } else {
                    print("error", error ?? "error is nil")
                }
            }
        }
    }
    
    @IBAction func backToLogin(_ sender: UIButton) {
        self.performSegue(withIdentifier: "backToLogin", sender: self)
    }

}
