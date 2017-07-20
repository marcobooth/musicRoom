//
//  InviteFriendsViewController.swift
//  musicRoom
//
//  Created by Marco BOOTH on 7/20/17.
//  Copyright © 2017 Marco BOOTH. All rights reserved.
//

import UIKit

class InviteFriendsViewController: UIViewController {
    
    var firebasePath: String?
    var eventOrPlaylistRef: DatabaseReference?
    var eventOrPlaylistHandle: UInt?
    var publicEvent: Bool?
    var from: String?
    var name: String?
    var friends = [String:String]()
    var invited = [String:Bool]()
    var invitedFriends = [(id: String, name: String)]()
    var uninvitedFriends = [(id: String, name: String)]()
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.publicEvent == true {
            self.title = "Delegate Control"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let uid = Auth.auth().currentUser?.uid, let path = self.firebasePath else {
            return
        }
        self.eventOrPlaylistRef = Database.database().reference(withPath: path)
        let userRef = Database.database().reference(withPath: "users/" + uid)
        
        userRef.observeSingleEvent(of: .value, with: { snapshot in
            self.friends = User(snapshot: snapshot).friends
            
            self.updateFriends()
        })
        
        self.eventOrPlaylistHandle = self.eventOrPlaylistRef?.child("userIds").observe(.value, with: { snapshot in
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
    
    func addFriend(button : UIButton) {
        if let from = self.from, let name = self.name, let eventOrPlaylistRef = self.eventOrPlaylistRef {
            if self.publicEvent == true {
                let publicEventRef = Database.database().reference(withPath: "events/public/\(eventOrPlaylistRef.key)/userIds/\(self.uninvitedFriends[button.tag].id)")
                publicEventRef.setValue(true)
                return
            }
            
            let addFriend: [String: Any] = [
                "users/\(self.uninvitedFriends[button.tag].id)/\(from)s/\(eventOrPlaylistRef.key)": name,
                "\(from)s/private/\(eventOrPlaylistRef.key)/userIds/\(self.uninvitedFriends[button.tag].id)": true,
                ]
            
            let ref = Database.database().reference()
            ref.updateChildValues(addFriend, withCompletionBlock: { (error, ref) -> Void in
                if error != nil {
                    print("Error updating data: \(error.debugDescription)")
                    self.showBasicAlert(title: "Error", message: "This probably means that Firebase denied access")
                }
            })
        }
    }
}

extension InviteFriendsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.publicEvent == true {
            if section == 0 && self.friends.count != 0 {
                return "Delegated Control"
            } else if section == 1 && self.uninvitedFriends.count != 0 {
                return "Invite to Control"
            }
            return nil
        }
        
        if section == 0 && self.friends.count != 0 {
            return "Collaborators"
        } else if section == 1 && self.uninvitedFriends.count != 0 {
            return "Uninvited"
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if self.invitedFriends.count == 0 {
                return 1
            }
            return self.invitedFriends.count
        } else {
            return self.uninvitedFriends.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "inviteFriend", for: indexPath)
        guard let friendCell = cell as? AddFriendsTableViewCell else {
            return cell
        }
        
        if indexPath.section == 0 {
            if self.invitedFriends.count != 0 {
                friendCell.name.text = self.invitedFriends[indexPath.row].name
                friendCell.name.textColor = UIColor.black
                friendCell.addFriend.isHidden = true
            } else {
                if self.publicEvent == true {
                    friendCell.name.text = "No friends have delegation control"
                } else {
                    friendCell.name.text = "No friends added yet"
                }
                friendCell.name.textColor = UIColor.gray
                friendCell.addFriend.isHidden = true
            }
            
        } else {
            friendCell.name.text = self.uninvitedFriends[indexPath.row].name
            friendCell.name.textColor = UIColor.black
            friendCell.addFriend.addTarget(self, action: #selector(addFriend), for: .touchUpInside)
            friendCell.addFriend.tag = indexPath.row
        }
        
        return friendCell
    }
}

