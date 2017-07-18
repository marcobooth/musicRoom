//
//  InviteFriendsTableViewController.swift
//  musicRoom
//
//  Created by Antoine LEBLANC on 6/28/17.
//  Copyright © 2017 Marco BOOTH. All rights reserved.
//

import UIKit

class InviteFriendsTableViewController: UITableViewController {

    var firebasePath: String?
    var userRef: DatabaseReference!
    var eventOrPlaylistRef: DatabaseReference!
    var eventOrPlaylistHandle: UInt!
    var from: String?
    var name: String?
    var friends = [String:String]()
    var invited = [String:Bool]()
    var invitedFriends = [(id: String, name: String)]()
    var uninvitedFriends = [(id: String, name: String)]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let uid = Auth.auth().currentUser?.uid, let path = self.firebasePath else {
            return
        }
        self.eventOrPlaylistRef = Database.database().reference(withPath: path)
        self.userRef = Database.database().reference(withPath: "users/" + uid)
        
        self.userRef.observeSingleEvent(of: .value, with: { snapshot in
            if let friends = User(snapshot: snapshot).friends {
                self.friends = friends
            } else {
                self.friends = [:]
            }
            
            self.updateFriends()
        })
        
        self.eventOrPlaylistHandle = self.eventOrPlaylistRef.child("userIds").observe(.value, with: { snapshot in
            if let invited = snapshot.value as? [String:Bool] {
                self.invited = invited
            } else {
                self.invited = [:]
            }
            
            self.updateFriends()
        })
    }
    
    func updateFriends() {
        var invitedFriends = [(id: String, name: String)]()
        var uninvitedFriends = [(id: String, name: String)]()

        for friend in self.friends {
            if invited[friend.key] != nil {
                invitedFriends.append((id: friend.key, name: friend.value))
            } else {
                uninvitedFriends.append((id: friend.key, name: friend.value))
            }
        }
        self.invitedFriends = invitedFriends
        self.uninvitedFriends = uninvitedFriends

        self.tableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let eventOrPlaylistHandle = self.eventOrPlaylistHandle {
            eventOrPlaylistRef?.removeObserver(withHandle: eventOrPlaylistHandle)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 && self.friends.count != 0 {
            return "Invited"
        } else if section == 1 && self.uninvitedFriends.count != 0 {
            return "Uninvited"
        }
        
        return nil
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.invitedFriends.count
        } else {
            return self.uninvitedFriends.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "inviteFriend", for: indexPath)
        guard let friendCell = cell as? AddFriendsTableViewCell else {
            return cell
        }
        
        if indexPath.section == 0 {
            friendCell.name.text = self.invitedFriends[indexPath.row].name
            friendCell.addFriend.isHidden = true
        } else {
            friendCell.name.text = self.uninvitedFriends[indexPath.row].name
            friendCell.addFriend.addTarget(self, action: #selector(addFriend), for: .touchUpInside)
            friendCell.addFriend.tag = indexPath.row
        }

        return friendCell
    }
    
    func addFriend(button : UIButton) {
        if let from = self.from, let name = self.name {
            let addFriend: [String: Any] = [
                "users/\(self.uninvitedFriends[button.tag].id)/\(from)s/\(self.eventOrPlaylistRef.key)": name,
                "\(from)s/private/\(self.eventOrPlaylistRef.key)/userIds/\(self.uninvitedFriends[button.tag].id)": true,
            ]
            
            let ref = Database.database().reference()
            ref.updateChildValues(addFriend, withCompletionBlock: { (error, ref) -> Void in
                if error != nil {
                    print("Error updating data: \(error.debugDescription)")
                    self.showBasicAlert(title: "Error", message: "There was a problem")
                }
            })
        }
    }
}
