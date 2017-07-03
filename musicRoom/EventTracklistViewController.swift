//
//  EventTracklistViewController.swift
//  musicRoom
//
//  Created by Antoine LEBLANC on 6/26/17.
//  Copyright © 2017 Marco BOOTH. All rights reserved.
//

import UIKit

class EventTracklistViewController: UIViewController {
    var path: String?
    var handle: UInt!
    var ref: DatabaseReference!
    var tracks = [EventTrack]()
    var event: Event?
    
    var currentUser: String!
    
    @IBOutlet weak var edit: UIBarButtonItem!
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let currentUser = Auth.auth().currentUser?.uid {
            self.currentUser = currentUser
        }
        if let p = self.path {
            self.ref = Database.database().reference(withPath: "events/" + p)
            self.ref.observeSingleEvent(of: .value, with: { snapshot in
                
                self.event = Event(snapshot: snapshot)
                if self.event?.userIds == nil || self.event?.createdBy != self.currentUser {
                    self.edit.isEnabled = false
                    self.edit.title = ""
                }
            })
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Observe private events
        handle = self.ref.observe(.value, with: { snapshot in
            
            let event = Event(snapshot: snapshot)
            self.event = event
            self.tracks = event.sortedTracks()
            self.tableView.reloadData()
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.ref.removeObserver(withHandle: handle)
    }
    
    func upVote(sender: UIButton) {
        let track = tracks[sender.tag]
        let userVote = track.voters[currentUser]
        if userVote == false {
            track.vote += 2
            track.voters[currentUser] = true
        } else if userVote == nil {
            track.vote += 1
            track.voters[currentUser] = true
        } else if userVote == true {
            track.vote -= 1
            track.voters[currentUser] = nil
        }
        
        
        ref.child("tracks/" + track.trackKey).setValue(track.toDict())
    }
    
    func downVote(sender: UIButton) {
        print("downvote")
        let track = tracks[sender.tag]
        let userVote = track.voters[currentUser]
        if userVote == true {
            track.vote -= 2
            track.voters[currentUser] = false
        } else if userVote == nil {
            track.vote -= 1
            track.voters[currentUser] = false
        } else if userVote == false {
            track.vote += 1
            track.voters[currentUser] = nil
        }
        ref.child("tracks/" + track.trackKey).setValue(track.toDict())
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? SearchTableViewController, let path = self.path {
            destination.firebasePath = "events/" + path
            destination.from = "event"
        } else if let destination = segue.destination as? InviteFriendsTableViewController, let path = self.path {
            destination.firebasePath = "events/" + path
            destination.from = "event"
            destination.name = event?.name
        }
    }
    
    @IBAction func unwindToEventTracklist(segue: UIStoryboardSegue) {
        print("I'm back in the event tracklist")
    }
}

extension EventTracklistViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tracks.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("EventCellTableViewCell", owner: self, options: nil)?.first as! EventCellTableViewCell

        cell.title.text = tracks[indexPath.row].name
        cell.artist.text = tracks[indexPath.row].creator
        cell.nbVote.text = String(describing: tracks[indexPath.row].vote)
        
        if self.event?.userIds == nil || self.event?.userIds?[currentUser] != nil {
            if tracks[indexPath.row].voters[currentUser] == true {
                cell.upVote.setTitle("✅", for: .normal)
                cell.downVote.setTitle("👎", for: .normal)
            } else if tracks[indexPath.row].voters[currentUser] == nil {
                cell.upVote.setTitle("👍", for: .normal)
                cell.downVote.setTitle("👎", for: .normal)
            } else {
                cell.upVote.setTitle("👍", for: .normal)
                cell.downVote.setTitle("✅", for: .normal)
            }
            cell.upVote.tag = indexPath.row
            cell.upVote.addTarget(self, action: #selector(upVote), for: .touchUpInside)
            cell.downVote.tag = indexPath.row
            cell.downVote.addTarget(self, action: #selector(downVote), for: .touchUpInside)
        } else {
            cell.upVote.isHidden = true
            cell.downVote.isHidden = true
        }
        return cell
    }
}
