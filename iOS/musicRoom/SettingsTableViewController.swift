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

class SettingsTableViewController: UITableViewController, GIDSignInUIDelegate, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var deezerSignInButton: UIButton!
    @IBOutlet weak var googleSignInButton: GIDSignInButton!
    @IBOutlet weak var facebookSignInButton: FBSDKLoginButton!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var submitUsername: UIButton!
    @IBOutlet weak var manageFriends: UIButton!
    @IBOutlet weak var deezerLabel: UILabel!
    @IBOutlet weak var facebookLabel: UILabel!
    @IBOutlet weak var googleLabel: UILabel!
    
    var usernameRef: DatabaseReference?
    var usernameHandle: UInt?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let uid = Auth.auth().currentUser?.uid {
            self.usernameRef = Database.database().reference(withPath: "users/" + uid + "/username")
        }
        
        if let buttonStyle = GIDSignInButtonStyle(rawValue: 1) {
            self.googleSignInButton.style = buttonStyle
        }
        
        self.updateAccountsView()
        
        self.facebookSignInButton.delegate = self
        self.facebookSignInButton.readPermissions = ["public_profile"]
        
        self.facebookLabel.isHidden = true
        self.googleLabel.isHidden = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateAccountsView()
        GIDSignIn.sharedInstance().uiDelegate = self
        
        self.usernameHandle = self.usernameRef?.observe(.value, with: { snapshot in
            if let username = snapshot.value as? String {
                self.username.isUserInteractionEnabled = false
                self.username.text = username
                self.submitUsername.isHidden = true
                self.manageFriends.isHidden = false
            } else {
                self.username.isUserInteractionEnabled = true
                self.submitUsername.isHidden = false
                self.manageFriends.isHidden = true
            }
        })
    }
    
    /*
    ** viewWillDisappear instead of viewDidDisappear because otherwise there's a
    ** scary permission_denied Firebase error b/c we might have logged out
    */
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let usernameHandle = self.usernameHandle {
            self.usernameRef?.removeObserver(withHandle: usernameHandle)
        }
    }
    
    @IBAction func submitUsername(_ sender: UIButton) {
        guard let uid = Auth.auth().currentUser?.uid, let username = self.username.text else {
            return
        }
        
        let ref = Database.database().reference()
        let updatedUserData = ["users/\(uid)/username": username, "usernames/\(username)": uid] as [String : Any]

        ref.updateChildValues(updatedUserData, withCompletionBlock: { (error, ref) -> Void in
            if error != nil {
                print("Error updating data: \(error.debugDescription)")
            } else {
                Analytics.logEvent("created_username", parameters: Log.defaultInfo())
            }
        })
    }

    @IBAction func explainUsernames(_ sender: UIButton) {
        self.showBasicAlert(title: "Usernames", message: "Create a username to share playlists and events with friends")
    }
    
    @IBAction func loginToDeezer(_ sender: UIButton) {
        DeezerSession.sharedInstance.deezerConnect?.authorize([
            DeezerConnectPermissionBasicAccess,
            DeezerConnectPermissionManageLibrary,
            DeezerConnectPermissionOfflineAccess
        ])
    }
    
    public func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        guard error == nil && result.isCancelled == false else {
            print(error ?? "no error")
            return
        }
        
        if let token = FBSDKAccessToken.current().tokenString {
            let credential = FacebookAuthProvider.credential(withAccessToken: token)
            FBSDKLoginManager().logOut()
            self.addSocialAccount(credential: credential)
        }
    }
    
    public func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }
    
    func addSocialAccount(credential : AuthCredential) {
        Auth.auth().currentUser?.link(with: credential, completion: { user, error in
            if error != nil {
                print("Error", error.debugDescription)
                self.showBasicAlert(title: "Account not linked", message: "This credential is already associated with a different user account")
            } else {
                Analytics.logEvent("added_social_account", parameters: Log.defaultInfo())
                self.updateAccountsView()
            }
        })
    }

    func updateAccountsView() {
        guard let user = Auth.auth().currentUser else {
            return
        }

        if DeezerSession.sharedInstance.deezerConnect?.userId != nil {
            self.deezerSignInButton.isHidden = true
            self.deezerLabel.isHidden = false
        } else {
            self.deezerLabel.isHidden = true
            self.deezerSignInButton.isHidden = false
        }
        
        for provider in user.providerData {
            if provider.providerID == "facebook.com" {
                self.facebookSignInButton.isHidden = true
                self.facebookLabel.isHidden = false
            }
            if provider.providerID == "google.com" {
                self.googleSignInButton.isHidden = true
                self.googleLabel.isHidden = false
            }
        }
    }
    
    @IBAction func logout(_ sender: UIButton) {
        // TODO: make sure all accounts are logged out
        do {
            GIDSignIn.sharedInstance().signOut()
            FBSDKLoginManager().logOut()
            try Auth.auth().signOut()
            DeezerSession.sharedInstance.clearMusic()
            DeezerSession.sharedInstance.deezerConnect?.logout()
            Analytics.logEvent("logging_out", parameters: Log.defaultInfo())
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
