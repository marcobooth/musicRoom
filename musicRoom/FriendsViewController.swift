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
    
    
    var usernamesSnapshot = [String:String]()
    var friendsSnapshot = [String:String]()
    var pendingInvitationsSnapshot = [String:Bool]()
    var invitationsSnapshot = [String:String]()

    var filteredUsernames = [(id: String, username: String)]()
    var invitations = [(id: String, username: String)]()
    var pendingInvitations = [String]()
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
            var pendingInvitations = [String]()
            
            if let allFriends = snapshot.value as? [String:Any] {
                // Saving snapshot values (for checking which ones not to show in usernames table)
                var friendsSnapshot = [String:String]()
                var pendingInvitationsSnapshot = [String:Bool]()
                for friend in allFriends {
                    if let friendValue = friend.value as? Bool {
                        pendingInvitationsSnapshot[friend.key] = friendValue
                    } else if let friendValue = friend.value as? String {
                        friendsSnapshot[friend.key] = friendValue
                    } else {
                        print("this should be not be here")
                    }
                }
                self.friendsSnapshot = friendsSnapshot
                self.pendingInvitationsSnapshot = pendingInvitationsSnapshot
                
                // Saving table values
                for friend in friendsSnapshot {
                    friends.append((id: friend.key, username: friend.value))
                }
                for pendingInvite in pendingInvitationsSnapshot {
                    pendingInvitations.append(pendingInvite.key)
                }
            } else {
                self.friendsSnapshot = [String:String]()
                self.pendingInvitationsSnapshot = [String:Bool]()
            }
            self.friends = friends
            self.pendingInvitations = pendingInvitations
            print("pending invitations", self.pendingInvitations)
            self.tableView.reloadData()
//            self.tableView.reloadSections(IndexSet(integer: 0), with: .none)
//            self.tableView.reloadSections(IndexSet(integer: 4), with: .none)
            self.updateUsernames()
        })
        
        invitationsHandle = self.invtationsRef.observe(.value, with: { snapshot in
            var invitations = [(id: String, username: String)]()
            if let allInvitations = snapshot.value as? [String:String] {
                self.invitationsSnapshot = snapshot.value as! [String:String]
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
        
        usernamesHandle = self.usernamesRef.observe(.value, with: { snapshot in
            if let usernamesSnapshot = snapshot.value as? [String:String] {
                self.usernamesSnapshot = usernamesSnapshot
            } else {
                self.usernamesSnapshot = [String:String]()
            }
            
            self.updateUsernames()
        })
    }
    
    func updateUsernames() {
        let filteredUsernames = self.usernamesSnapshot.filter { username in
            // TODO: you're here . Filter my own username
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
        
        self.tableView.reloadSections(IndexSet(integer: 2), with: .none)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        self.invtationsRef.removeObserver(withHandle: invitationsHandle)
        self.invtationsRef.removeObserver(withHandle: invitationsHandle)
        self.usernamesRef.removeObserver(withHandle: usernamesHandle)
    }
    
    func addFriend(button : UIButton) {
        guard let uid = Auth.auth().currentUser?.uid, let username = self.myUsername else {
            self.showBasicAlert(title: "User error", message: "You do not appear to be logged in")
            return
        }
        
        // Adds friend with false value in current user table and adds invitation to invited user's table
        let addFriend = ["\(uid)/friends/\(self.filteredUsernames[button.tag].id)": false, "\(self.filteredUsernames[button.tag].id)/friendInvitations/\(uid)": username] as [String : Any]
        
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
        } else if section == 2 {
            return self.filteredUsernames.count
        } else {
            return self.pendingInvitations.count
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
        } else if indexPath.section == 2 {
            friendCell.username.text = self.filteredUsernames[indexPath.row].username
            friendCell.addFriend.addTarget(self, action: #selector(addFriend), for: .touchUpInside)
            friendCell.addFriend.tag = indexPath.row
            friendCell.accept.isHidden = true
            friendCell.reject.isHidden = true
        } else {
            friendCell.username.text = self.usernamesSnapshot[self.pendingInvitations[indexPath.row]] ?? "username not found"
            friendCell.accept.isHidden = true
            friendCell.reject.isHidden = true
            friendCell.addFriend.isHidden = true
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
        if section == 2 && self.filteredUsernames.count != 0 {
            return "Add Friends"
        }
        if section == 3 && self.pendingInvitations.count != 0 {
            return "Pending Invitations"
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
