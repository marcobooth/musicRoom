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
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var submitUsername: UIButton!
    @IBOutlet weak var manageFriends: UIButton!
    
    var usernameRef: DatabaseReference!
    var handle: UInt!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.manageFriends.isHidden = true
        self.usernameRef = Database.database().reference(withPath: "users/" + (Auth.auth().currentUser?.uid)! + "/username")
        self.googleSignInButton.style = GIDSignInButtonStyle(rawValue: 2)!
        self.updateAccountsView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        GIDSignIn.sharedInstance().uiDelegate = self
        
        handle = self.usernameRef.observe(.value, with: { snapshot in
            if let username = snapshot.value as? String {
                self.username.isUserInteractionEnabled = false
                self.username.text = username
                self.submitUsername.isHidden = true
                self.manageFriends.isHidden = false
            }
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Remove listener with handle
        self.usernameRef.removeObserver(withHandle: handle)
    }
    
    @IBAction func submitUsername(_ sender: UIButton) {
        if self.username.text != nil {
            if let uid = Auth.auth().currentUser?.uid {
                let ref = Database.database().reference()
                let updatedUserData = ["users/\(uid)/username": self.username.text!, "usernames/\(self.username.text!)": uid] as [String : Any]
                
                ref.updateChildValues(updatedUserData, withCompletionBlock: { (error, ref) -> Void in
                    if error != nil {
                        print("Error updating data: \(error.debugDescription)")
                    } else {
                        print("error is nil")
                    }
                })
            }
        }
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
