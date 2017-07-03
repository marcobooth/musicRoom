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
    var from: String?
    var name: String?
    var friends = [(uid: String, name: String, isInvited: Bool)]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let path = firebasePath {
            self.eventOrPlaylistRef = Database.database().reference(withPath: path)
        }
        
        self.userRef = Database.database().reference(withPath: "users/" + (Auth.auth().currentUser?.uid)!)
        self.userRef.observeSingleEvent(of: .value, with: { snapshot in
            if let friends = User(snapshot: snapshot).friends {
                for friend in friends {
                    self.eventOrPlaylistRef.child("userIds").observeSingleEvent(of: .value, with: { snapshot in
                        if snapshot.hasChild(friend.key) == true {
                            self.friends.append((uid: friend.key, name: friend.value, isInvited: true))
                        } else {
                            self.friends.append((uid: friend.key, name: friend.value, isInvited: false))
                        }
                        self.tableView.reloadData()
                    })
                }
            }
        })
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return friends.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: AddFriendsTableViewCell
        if let c = tableView.dequeueReusableCell(withIdentifier: "friendCell") as! AddFriendsTableViewCell? {
            cell = c
        } else {
            cell = Bundle.main.loadNibNamed("AddFriendsTableViewCell", owner: self, options: nil)?.first as! AddFriendsTableViewCell
        }
        print("cell", indexPath.row)
        cell.name.text = friends[indexPath.row].name
        cell.friend.tag = indexPath.row
        cell.friend.isOn = friends[indexPath.row].isInvited
        cell.friend.addTarget(self, action: #selector(friendshipStatusChange), for: .valueChanged)

        return cell
    }
 
    func friendshipStatusChange(sender: UISwitch) {
        let friendRef = Database.database().reference(withPath: "users/" + friends[sender.tag].uid)
        if sender.isOn {
            eventOrPlaylistRef.child("userIds/" + friends[sender.tag].uid).setValue(true)
            if from == "event" {
                friendRef.child("invitedEvents/" + eventOrPlaylistRef.key).setValue(name)
            } else {
                friendRef.child("invitedPlaylists/" + eventOrPlaylistRef.key).setValue(name)
            }
            print("is on")
        } else {
            eventOrPlaylistRef.child("userIds/" + friends[sender.tag].uid).setValue(nil)
            if from == "event" {
                friendRef.child("invitedEvents/" + eventOrPlaylistRef.key).setValue(nil)
            } else {
                friendRef.child("invitedPlaylists/" + eventOrPlaylistRef.key).setValue(nil)
            }
            print("is off")
        }
    }

}
