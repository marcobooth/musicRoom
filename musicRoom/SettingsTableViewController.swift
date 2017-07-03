//
//  SettingsTableViewController.swift
//  musicRoom
//
//  Created by Marco BOOTH on 6/28/17.
//  Copyright © 2017 Marco BOOTH. All rights reserved.
//

import UIKit
import GoogleSignIn
import FBSDKLoginKit

class SettingsTableViewController: UITableViewController, GIDSignInUIDelegate {
    
    @IBOutlet weak var deezerSignInButton: UIButton!
    @IBOutlet weak var googleSignInButton: GIDSignInButton!
    @IBOutlet weak var facebookSignInButton: UIButton!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var submitUsername: UIButton!
    @IBOutlet weak var manageFriends: UIButton!
    
    var usernameRef: DatabaseReference!
    var handle: UInt!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.usernameRef = Database.database().reference(withPath: "users/" + (Auth.auth().currentUser?.uid)! + "/username")
        self.googleSignInButton.style = GIDSignInButtonStyle(rawValue: 2)!
        self.updateAccountsView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateAccountsView()
        GIDSignIn.sharedInstance().uiDelegate = self
        
        handle = self.usernameRef.observe(.value, with: { snapshot in
            if let username = snapshot.value as? String {
                self.username.isUserInteractionEnabled = false
                self.username.text = username
                self.submitUsername.isHidden = true
                self.manageFriends.isHidden = false
            } else {
                self.manageFriends.isHidden = true
            }
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Remove listener with handle
        self.usernameRef.removeObserver(withHandle: handle)
    }
    
    @IBAction func submitUsername(_ sender: UIButton) {
        guard let uid = Auth.auth().currentUser?.uid, self.username.text != nil else {
            return
        }
        
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

    
    @IBAction func loginToDeezer(_ sender: UIButton) {
        DeezerSession.sharedInstance.deezerConnect?.authorize([DeezerConnectPermissionBasicAccess, DeezerConnectPermissionManageLibrary])
    }
    
    @IBAction func linkFacebook(_ sender: UIButton) {
        let login = FBSDKLoginManager()
        login.logIn(withReadPermissions: ["public_profile"], from: self) { (result, error) in
            if error != nil || result?.token == nil {
                print("error adding facebook", error.debugDescription)
                return
            }
            let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            self.addSocialAccount(credential: credential)
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

    func updateAccountsView() {
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        if DeezerSession.sharedInstance.deezerConnect?.userId != nil {
            self.deezerSignInButton.titleLabel?.text = "Account added"
            self.deezerSignInButton.isEnabled = false
            self.deezerSignInButton.setTitleColor(UIColor.gray, for: .disabled)
        }
        
        for provider in user.providerData {
            if provider.providerID == "facebook.com" {
                self.facebookSignInButton.isHidden = true
            }
            if provider.providerID == "google.com" {
                self.googleSignInButton.isHidden = true
            }
        }
    }
    
    @IBAction func logout(_ sender: UIButton) {
        // TODO: make sure all accounts are logged out
        do {
            FBSDKLoginManager().logOut()
            try Auth.auth().signOut()
            self.performSegue(withIdentifier: "signOut", sender: self)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
            self.showBasicAlert(title: "Logout failed", message: "You didn't logout of the app, it just didn't work")
        }
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}
