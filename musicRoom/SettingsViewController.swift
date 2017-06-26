//
//  SettingsViewController.swift
//  musicRoom
//
//  Created by Marco BOOTH on 6/13/17.
//  Copyright © 2017 Marco BOOTH. All rights reserved.
//

import UIKit
import GoogleSignIn
import FBSDKLoginKit

class SettingsViewController: UIViewController, GIDSignInUIDelegate {
    
    var googleAccountAdded: Bool = false
    var facebookAccountAdded: Bool = false
    @IBOutlet weak var googleSignInButton: GIDSignInButton!
    @IBOutlet weak var facebookSignInButton: UIButton!
    @IBOutlet weak var facebookStatus: UILabel!
    @IBOutlet weak var googleStatus: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        self.googleSignInButton.style = GIDSignInButtonStyle(rawValue: 2)!
        self.updateAccountsView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        GIDSignIn.sharedInstance().uiDelegate = self
    }
}

extension SettingsViewController {
    
    @IBAction func loginToDeezer(_ sender: UIButton) {
        DeezerSession.sharedInstance.deezerConnect?.authorize([DeezerConnectPermissionBasicAccess, DeezerConnectPermissionManageLibrary])
    }
    
    @IBAction func linkFacebook(_ sender: UIButton) {
        let login = FBSDKLoginManager()
        login.logIn(withReadPermissions: ["public_profile"], from: self) { (result, error) in
            let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            self.addSocialAccount(credential: credential)
        }
    }
    
    @IBAction func logoutOfAllAccounts(_ sender: UIButton) {
        //        DeezerSession.sharedInstance.deezerConnect?.accessToken = ""
        //        DeezerSession.sharedInstance.deezerConnect?.logout()
        do {
            try Auth.auth().signOut()
            self.performSegue(withIdentifier: "signOut", sender: self)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    func addSocialAccount(credential : AuthCredential) {
        Auth.auth().currentUser?.link(with: credential, completion: { user, error in
            if error != nil {
                self.showBasicAlert(title: "Account not linked", message: error.debugDescription)
            } else {
                self.updateAccountsView()
            }
        })
    }
}

extension SettingsViewController {
    func updateAccountsView() {
        let user = Auth.auth().currentUser
        if let user = user {
            for provider in user.providerData {
                if provider.providerID == "facebook.com" {
                    self.facebookAccountAdded = true
                    self.facebookStatus.text = "Facebook Account Linked"
                } else if provider.providerID == "google.com" {
                    self.googleAccountAdded = true
                    self.googleStatus.text = "Google Account Linked"
                }
            }
        }
        
        self.facebookSignInButton.isHidden = self.facebookAccountAdded
        self.googleSignInButton.isHidden = self.googleAccountAdded
    }
}

extension SettingsViewController {
    func showBasicAlert(title : String, message : String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok, noted", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
