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
    
    var usernames = [(id: String, username: String)]()
    var invitations = [(id: String, username: String)]()
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let uid = (Auth.auth().currentUser?.uid)!
        self.friendsRef = Database.database().reference(withPath: "users/" + uid + "/friends")
        self.invtationsRef = Database.database().reference(withPath: "users/" + uid + "/friendInvitations")
        self.usernamesRef = Database.database().reference(withPath: "usernames")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        friendsHandle = self.friendsRef.observe(.value, with: { snapshot in
        })
        
        invitationsHandle = self.invtationsRef.observe(.value, with: { snapshot in
            print(snapshot.value)
        })
        
        usernamesHandle = self.usernamesRef.observe(.value, with: { snapshot in
            if let allUsernames = snapshot.value as? [String:String] {
                var usernames = [(id: String, username: String)]()
                for username in allUsernames {
                    usernames.append((id: username.value, username: username.key))
                }
                self.usernames = usernames
                self.tableView.reloadData()
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
            let updatedUserData = ["\(uid)/friends/\(self.usernames[button.tag].id)": false, "\(self.usernames[button.tag].id)/friendInvitations/\(uid)": true] as [String : Any]
                
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

extension FriendsViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 {
            return self.usernames.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "newFriend", for: indexPath)
            if let cell = cell as? NewFriendTableViewCell {
                cell.username.text = self.usernames[indexPath.row].username
                cell.addFriend.addTarget(self, action: #selector(addFriend), for: .touchUpInside)
                cell.addFriend.tag = indexPath.row
                return cell
            }
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath)
        cell.textLabel?.text = "test"
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
}
