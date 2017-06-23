//
//  SettingsViewController.swift
//  musicRoom
//
//  Created by Marco BOOTH on 6/13/17.
//  Copyright © 2017 Marco BOOTH. All rights reserved.
//

import UIKit
import GoogleSignIn

class SettingsViewController: UIViewController, GIDSignInUIDelegate {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    @IBAction func loginToDeezer(_ sender: UIButton) {
        print("pressed login to deezer")
        DeezerSession.sharedInstance.deezerConnect?.authorize([DeezerConnectPermissionBasicAccess, DeezerConnectPermissionManageLibrary])
    }
    
    @IBAction func logout(_ sender: UIButton) {
//        DeezerSession.sharedInstance.deezerConnect?.accessToken = ""
//        DeezerSession.sharedInstance.deezerConnect?.logout()
        do {
            try FIRAuth.auth()?.signOut()
            self.performSegue(withIdentifier: "signOut", sender: self)            
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        

    }

}
