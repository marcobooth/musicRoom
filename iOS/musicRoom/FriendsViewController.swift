//
//  FriendsViewController.swift
//  musicRoom
//
//  Created by Marco BOOTH on 6/27/17.
//  Copyright © 2017 Marco BOOTH. All rights reserved.
//

import UIKit

class FriendsViewController: UIViewController {

    var friendsRef: DatabaseReference?
    var invitationsRef: DatabaseReference?
    var usernamesRef: DatabaseReference?
    var pendingInvitationsRef: DatabaseReference?
    
    var friendsHandle: UInt?
    var invitationsHandle: UInt?
    var usernamesHandle: UInt?
    var pendingInvitationsHandle: UInt?
    
    var myUsername : String?
    var uid: String?
    
    
    var usernamesSnapshot = [String:String]()
    var friendsSnapshot = [String:String]()
    var pendingInvitationsSnapshot = [String:String]()
    var invitationsSnapshot = [String:String]()

    var filteredUsernames = [(id: String, username: String)]()
    var invitations = [(id: String, username: String)]()
    var pendingInvitations = [(id: String, username: String)]()
    var friends = [(id: String, username: String)]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
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
        self.invitationsRef = Database.database().reference(withPath: "users/" + uid + "/friendInvitations")
        self.pendingInvitationsRef = Database.database().reference(withPath: "users/" + uid + "/pendingInvitations")
        self.usernamesRef = Database.database().reference(withPath: "usernames")
        
        self.tableView.allowsMultipleSelectionDuringEditing = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        friendsHandle = self.friendsRef?.observe(.value, with: { snapshot in
            var friends = [(id: String, username: String)]()
            
            if let allFriends = snapshot.value as? [String:String] {
                self.friendsSnapshot = allFriends

                for friend in allFriends {
                    friends.append((id: friend.key, username: friend.value))
                }
            } else {
                self.friendsSnapshot = [String:String]()
            }
            self.friends = friends
            self.tableView.reloadSections(IndexSet(integer: 0), with: .none)
            self.updateUsernames()
        })
        
        invitationsHandle = self.invitationsRef?.observe(.value, with: { snapshot in
            var invitations = [(id: String, username: String)]()
            
            if let allInvitations = snapshot.value as? [String:String] {
                self.invitationsSnapshot = allInvitations
                
                for invite in allInvitations {
                    invitations.append((id: invite.key, username: invite.value))
                }
            } else {
                self.invitationsSnapshot = [String:String]()
            }
            self.invitations = invitations
            self.tableView.reloadSections(IndexSet(integer: 1), with: .none)
            self.updateUsernames()
        })
        
        usernamesHandle = self.usernamesRef?.observe(.value, with: { snapshot in
            if let usernamesSnapshot = snapshot.value as? [String:String] {
                self.usernamesSnapshot = usernamesSnapshot
            } else {
                self.usernamesSnapshot = [String:String]()
            }
            
            self.updateUsernames()
        })
        
        pendingInvitationsHandle = self.pendingInvitationsRef?.observe(.value, with: { snapshot in
            var pendingInvitations = [(id: String, username: String)]()
            if let allPendingInvitations = snapshot.value as? [String:String] {
                self.pendingInvitationsSnapshot = allPendingInvitations
                for pendingInvite in allPendingInvitations {
                    pendingInvitations.append((id: pendingInvite.key, username: pendingInvite.value))
                }
            } else {
                self.pendingInvitationsSnapshot = [String:String]()
            }
            self.pendingInvitations = pendingInvitations
            self.tableView.reloadSections(IndexSet(integer: 2), with: .none)
            self.updateUsernames()
        })
    }
    
    func updateUsernames() {
        let filteredUsernames = self.usernamesSnapshot.filter { username in
            if username.key != self.myUsername && self.friendsSnapshot[username.value] == nil && self.invitationsSnapshot[username.value] == nil && self.pendingInvitationsSnapshot[username.value] == nil {
                return true
            }
            return false
        }
        
        var filtered = [(id: String, username: String)]()
        for username in filteredUsernames {
            filtered.append((id: username.value, username: username.key))
        }

        self.filteredUsernames = filtered
        self.tableView.reloadSections(IndexSet(integer: 3), with: .none)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let invitationsHandle = self.invitationsHandle {
            self.invitationsRef?.removeObserver(withHandle: invitationsHandle)
        }
        if let friendsHandle = self.friendsHandle {
            self.friendsRef?.removeObserver(withHandle: friendsHandle)
        }
        if let usernamesHandle = self.usernamesHandle {
            self.usernamesRef?.removeObserver(withHandle: usernamesHandle)
        }
        if let pendingInvitationsHandle = self.pendingInvitationsHandle {
            self.pendingInvitationsRef?.removeObserver(withHandle: pendingInvitationsHandle)
        }
    }
    
    func addFriend(button : UIButton) {
        guard let uid = Auth.auth().currentUser?.uid, let username = self.myUsername else {
            self.showBasicAlert(title: "User error", message: "You do not appear to be logged in")
            return
        }
        
        // Adds friend with false value in current user table and adds invitation to invited user's table
        let addFriend = [
            "\(uid)/pendingInvitations/\(self.filteredUsernames[button.tag].id)": self.filteredUsernames[button.tag].username,
            "\(self.filteredUsernames[button.tag].id)/friendInvitations/\(uid)": username
        ] as [String : Any]
        
        self.updateMultipleUserValues(updatedValues: addFriend)
        Analytics.logEvent("added_a_friend", parameters: Log.defaultInfo())
    }
    
    func acceptInvitation(button : UIButton) {
        guard let uid = Auth.auth().currentUser?.uid, let username = self.myUsername else {
            self.showBasicAlert(title: "User error", message: "You do not appear to be logged in")
            return
        }
        
        // Deletes invitation and adds username as friend in both user's tables
        let acceptInvitation = [
            "\(uid)/friends/\(self.invitations[button.tag].id)": self.invitations[button.tag].username,
            "\(self.invitations[button.tag].id)/friends/\(uid)": username,
            "\(uid)/friendInvitations/\(self.invitations[button.tag].id)": NSNull(),
            "\(self.invitations[button.tag].id)/pendingInvitations/\(uid)": NSNull()
        ] as [String : Any]
        
        self.updateMultipleUserValues(updatedValues: acceptInvitation)
        Analytics.logEvent("accepted_invitation", parameters: Log.defaultInfo())
    }
    
    func rejectInvitation(button : UIButton) {
        guard let uid = Auth.auth().currentUser?.uid else {
            self.showBasicAlert(title: "User error", message: "You do not appear to be logged in")
            return
        }
        // Deletes invitation and friend reference from user who invited friend
        let rejectInvitation = ["\(self.invitations[button.tag].id)/pendingInvitations/\(uid)": NSNull(), "\(uid)/friendInvitations/\(self.invitations[button.tag].id)": NSNull()] as [String : Any]
        
        self.updateMultipleUserValues(updatedValues: rejectInvitation)
        Analytics.logEvent("rejected_a_invitation", parameters: Log.defaultInfo())
    }
    
    func deleteFriend(row : Int) {
        guard let uid = Auth.auth().currentUser?.uid else {
            self.showBasicAlert(title: "User error", message: "You do not appear to be logged in")
            return
        }
        // Deletes friend reference from both user's tables
        let deleteFriend = [
            "\(self.friends[row].id)/friends/\(uid)": NSNull(),
            "\(uid)/friends/\(self.friends[row].id)": NSNull()
        ] as [String : Any]
        
        self.updateMultipleUserValues(updatedValues: deleteFriend)
        Analytics.logEvent("deleted_a_friend", parameters: Log.defaultInfo())
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
        } else if section == 2 {
            return self.pendingInvitations.count
        } else {
            return self.filteredUsernames.count
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
            friendCell.accept.isHidden = false
            friendCell.reject.isHidden = false
            friendCell.addFriend.isHidden = true
        } else if indexPath.section == 2 {
            friendCell.username.text = self.pendingInvitations[indexPath.row].username
            friendCell.accept.isHidden = true
            friendCell.reject.isHidden = true
            friendCell.addFriend.isHidden = true
        } else {
            friendCell.username.text = self.filteredUsernames[indexPath.row].username
            friendCell.addFriend.addTarget(self, action: #selector(addFriend), for: .touchUpInside)
            friendCell.addFriend.tag = indexPath.row
            friendCell.accept.isHidden = true
            friendCell.reject.isHidden = true
            friendCell.addFriend.isHidden = false
        }

        return friendCell
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 && self.friends.count != 0 {
            return "Friends"
        }
        if section == 1 && self.invitations.count != 0 {
            return "Invitations"
        }
        if section == 2 && self.pendingInvitations.count != 0 {
            return "Pending Invitations"
        }
        if section == 3 && self.filteredUsernames.count != 0 {
            return "Add Friends"
        }

        
        return nil
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
