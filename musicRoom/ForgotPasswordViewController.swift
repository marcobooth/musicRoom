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
            FIRAuth.auth()?.sendPasswordReset(withEmail: "marcobooth@hotmail.com") { (error) in
                if error == nil {
                    print("password email sent")
                } else {
                    print("error", error)
                }
            }
        }
    }

}
