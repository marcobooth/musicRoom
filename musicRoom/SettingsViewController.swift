//
//  SettingsViewController.swift
//  musicRoom
//
//  Created by Marco BOOTH on 6/13/17.
//  Copyright © 2017 Marco BOOTH. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
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
            
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            if let loginViewController = storyBoard.instantiateViewController(withIdentifier: "loginView") as? LoginViewController {
                self.present(loginViewController, animated:true, completion:nil)
            }
            
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        

    }

}
