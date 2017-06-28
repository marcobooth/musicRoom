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
    
    var usernames = [(id: String, username: String)]()
    var invitations = [(id: String, username: String)]()
    var friends = [(id: String, username: String)]()
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let uid = (Auth.auth().currentUser?.uid)!
        self.friendsRef = Database.database().reference(withPath: "users/" + uid + "/friends")
        self.invtationsRef = Database.database().reference(withPath: "users/" + uid + "/friendInvitations")
        self.usernamesRef = Database.database().reference(withPath: "usernames")
        
        self.tableView.allowsMultipleSelectionDuringEditing = false
        
        //TODO: protect against this username not coming back
        let ref = Database.database().reference(withPath: "users/\(uid)/username")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            print("snapshot", snapshot)
            if let username = snapshot.value as? String {
                self.myUsername = username
            }
        }) { (error) in
            print(error.localizedDescription)
        }
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
            if let allUsernames = snapshot.value as? [String:String] {
                var usernames = [(id: String, username: String)]()
                for username in allUsernames {
                    if username.key != self.myUsername {
                        usernames.append((id: username.value, username: username.key))
                    }
                }
                self.usernames = usernames
                self.tableView.reloadSections(IndexSet(integer: 2), with: .none)
            }
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
        if let uid = Auth.auth().currentUser?.uid {
            let ref = Database.database().reference(withPath: "users/")
            let updatedUserData = ["\(uid)/friends/\(self.usernames[button.tag].id)": false, "\(self.usernames[button.tag].id)/friendInvitations/\(uid)": self.myUsername!] as [String : Any]
                
            ref.updateChildValues(updatedUserData, withCompletionBlock: { (error, ref) -> Void in
                if error != nil {
                    print("Error updating data: \(error.debugDescription)")
                    self.showBasicAlert(title: "Error", message: "There was a problem")
                }
            })
        }
    }
    
    func acceptInvitation(button : UIButton) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let ref = Database.database().reference(withPath: "users/")
        let updatedUserData = ["\(uid)/friends/\(self.invitations[button.tag].id)": self.invitations[button.tag].username, "\(self.invitations[button.tag].id)/friends/\(uid)": self.myUsername!, "\(uid)/friendInvitations/\(self.invitations[button.tag].id)": NSNull()] as [String : Any]
        ref.updateChildValues(updatedUserData, withCompletionBlock: { (error, ref) -> Void in
            if error != nil {
                print("Error updating data: \(error.debugDescription)")
                self.showBasicAlert(title: "Error", message: "There was a problem")
            }
        })
        
    }
    
    func rejectInvitation(button : UIButton) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let ref = Database.database().reference(withPath: "users/")
        let updatedUserData = ["\(self.invitations[button.tag].id)/friends/\(uid)": NSNull(), "\(uid)/friendInvitations/\(self.invitations[button.tag].id)": NSNull()] as [String : Any]
        ref.updateChildValues(updatedUserData, withCompletionBlock: { (error, ref) -> Void in
            if error != nil {
                print("Error updating data: \(error.debugDescription)")
                self.showBasicAlert(title: "Error", message: "There was a problem")
            }
        })
    }
    
    func deleteFriend(row : Int) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let ref = Database.database().reference(withPath: "users/")
        let updatedUserData = ["\(self.friends[row].id)/friends/\(uid)": NSNull(), "\(uid)/friends/\(self.friends[row].id)": NSNull()] as [String : Any]
        ref.updateChildValues(updatedUserData, withCompletionBlock: { (error, ref) -> Void in
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
        var cell : UITableViewCell
        
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "friend", for: indexPath)
            if let cell = cell as? FriendTableViewCell {
                cell.username.text = self.friends[indexPath.row].username
            }
        } else if indexPath.section == 1 {
            cell = tableView.dequeueReusableCell(withIdentifier: "invitation", for: indexPath)
            if let cell = cell as? InvitationTableViewCell {
                cell.username.text = self.invitations[indexPath.row].username
                cell.accept.tag = indexPath.row
                cell.reject.tag = indexPath.row
                cell.accept.addTarget(self, action: #selector(acceptInvitation), for: .touchUpInside)
                cell.reject.addTarget(self, action: #selector(rejectInvitation), for: .touchUpInside)
            }
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "newFriend", for: indexPath)
            if let cell = cell as? NewFriendTableViewCell {
                cell.username.text = self.usernames[indexPath.row].username
                cell.addFriend.addTarget(self, action: #selector(addFriend), for: .touchUpInside)
                cell.addFriend.tag = indexPath.row
            }
        }
        return cell
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
