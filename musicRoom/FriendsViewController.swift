//
//  FriendsViewController.swift
//  musicRoom
//
//  Created by Marco BOOTH on 6/27/17.
//  Copyright © 2017 Marco BOOTH. All rights reserved.
//

import UIKit

class FriendsViewController: UIViewController {

    var friendsRef: DatabaseReference!
    var invtationsRef: DatabaseReference!
    var usernamesRef: DatabaseReference!
    var friendsHandle: UInt!
    var invitationsHandle: UInt!
    var usernamesHandle: UInt!
    var myUsername : String?
    var uid: String?
    var usernames = [(id: String, username: String)]()
    var invitations = [(id: String, username: String)]()
    var friends = [(id: String, username: String)]()
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: System-wide to check for logout. For possibly uid and username, should go back if not found
        let uid = (Auth.auth().currentUser?.uid)!
        
        let ref = Database.database().reference(withPath: "users/\(uid)/username")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let username = snapshot.value as? String {
                self.myUsername = username
            }
        }) { (error) in
            print(error.localizedDescription)
            self.showBasicAlert(title: "Username error", message: "Username not found")
        }

        self.friendsRef = Database.database().reference(withPath: "users/" + uid + "/friends")
        self.invtationsRef = Database.database().reference(withPath: "users/" + uid + "/friendInvitations")
        self.usernamesRef = Database.database().reference(withPath: "usernames")
        
        self.tableView.allowsMultipleSelectionDuringEditing = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        friendsHandle = self.friendsRef.observe(.value, with: { snapshot in
            var friends = [(id: String, username: String)]()
            if let allFriends = snapshot.value as? [String:String] {
                for friend in allFriends {
                    friends.append((id: friend.key, username: friend.value))
                }
            }
            self.friends = friends
            self.tableView.reloadSections(IndexSet(integer: 0), with: .none)
        })
        
        invitationsHandle = self.invtationsRef.observe(.value, with: { snapshot in
            var invitations = [(id: String, username: String)]()
            if let allInvitations = snapshot.value as? [String:String] {
                for invite in allInvitations {
                    invitations.append((id: invite.key, username: invite.value))
                }
            }
            self.invitations = invitations
            self.tableView.reloadSections(IndexSet(integer: 1), with: .none)
        })
        
        usernamesHandle = self.usernamesRef.observe(.value, with: { snapshot in
            var usernames = [(id: String, username: String)]()
            if let allUsernames = snapshot.value as? [String:String] {
                for username in allUsernames {
                    if username.key != self.myUsername {
                        usernames.append((id: username.value, username: username.key))
                    }
                }
            }
            self.usernames = usernames
            self.tableView.reloadSections(IndexSet(integer: 2), with: .none)
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Remove listener with handle
        self.friendsRef.removeObserver(withHandle: friendsHandle)
        self.invtationsRef.removeObserver(withHandle: invitationsHandle)
        self.usernamesRef.removeObserver(withHandle: usernamesHandle)
    }
    
    func addFriend(button : UIButton) {
        guard let uid = Auth.auth().currentUser?.uid, let username = self.myUsername else {
            self.showBasicAlert(title: "User error", message: "You do not appear to be logged in")
            return
        }
        
        // Adds friend with false value in current user table and adds invitation to invited user's table
        let addFriend = ["\(uid)/friends/\(self.usernames[button.tag].id)": false, "\(self.usernames[button.tag].id)/friendInvitations/\(uid)": username] as [String : Any]
        
        self.updateMultipleUserValues(updatedValues: addFriend)
    }
    
    func acceptInvitation(button : UIButton) {
        guard let uid = Auth.auth().currentUser?.uid, let username = self.myUsername else {
            self.showBasicAlert(title: "User error", message: "You do not appear to be logged in")
            return
        }
        
        // Deletes invitation and adds username as friend in both user's tables
        let acceptInvitation = ["\(uid)/friends/\(self.invitations[button.tag].id)": self.invitations[button.tag].username, "\(self.invitations[button.tag].id)/friends/\(uid)": username, "\(uid)/friendInvitations/\(self.invitations[button.tag].id)": NSNull()] as [String : Any]
        
        self.updateMultipleUserValues(updatedValues: acceptInvitation)
    }
    
    func rejectInvitation(button : UIButton) {
        guard let uid = Auth.auth().currentUser?.uid else {
            self.showBasicAlert(title: "User error", message: "You do not appear to be logged in")
            return
        }
        // Deletes invitation and friend reference from user who invited friend
        let rejectInvitation = ["\(self.invitations[button.tag].id)/friends/\(uid)": NSNull(), "\(uid)/friendInvitations/\(self.invitations[button.tag].id)": NSNull()] as [String : Any]
        
        self.updateMultipleUserValues(updatedValues: rejectInvitation)
    }
    
    func deleteFriend(row : Int) {
        guard let uid = Auth.auth().currentUser?.uid else {
            self.showBasicAlert(title: "User error", message: "You do not appear to be logged in")
            return
        }
        // Deletes friend reference from both user's tables
        let deleteFriend = ["\(self.friends[row].id)/friends/\(uid)": NSNull(), "\(uid)/friends/\(self.friends[row].id)": NSNull()] as [String : Any]
        
        self.updateMultipleUserValues(updatedValues: deleteFriend)
    }
    
    func updateMultipleUserValues(updatedValues : [String: Any]) {
        let ref = Database.database().reference(withPath: "users/")
        
        ref.updateChildValues(updatedValues, withCompletionBlock: { (error, ref) -> Void in
            if error != nil {
                print("Error updating data: \(error.debugDescription)")
                self.showBasicAlert(title: "Error", message: "There was a problem")
            }
        })
    }
    
}

extension FriendsViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return friends.count
        } else if section == 1 {
            return invitations.count
        } else {
            return self.usernames.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friend", for: indexPath)
        guard let friendCell = cell as? FriendTableViewCell else {
            return cell
        }
    
        if indexPath.section == 0 {
            friendCell.username.text = self.friends[indexPath.row].username
            friendCell.accept.isHidden = true
            friendCell.reject.isHidden = true
            friendCell.addFriend.isHidden = true
        } else if indexPath.section == 1 {
            friendCell.username.text = self.invitations[indexPath.row].username
            friendCell.accept.tag = indexPath.row
            friendCell.reject.tag = indexPath.row
            friendCell.accept.addTarget(self, action: #selector(acceptInvitation), for: .touchUpInside)
            friendCell.reject.addTarget(self, action: #selector(rejectInvitation), for: .touchUpInside)
            friendCell.addFriend.isHidden = true
        } else {
            friendCell.username.text = self.usernames[indexPath.row].username
            friendCell.addFriend.addTarget(self, action: #selector(addFriend), for: .touchUpInside)
            friendCell.addFriend.tag = indexPath.row
            friendCell.accept.isHidden = true
            friendCell.reject.isHidden = true
        }
        return friendCell
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Friends"
        } else if section == 1 {
            return "Invitations"
        } else {
            return "Users"
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return true
        }
        
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            self.deleteFriend(row: indexPath.row)
        }
    }
}
