//
//  EventTracklistViewController.swift
//  musicRoom
//
//  Created by Antoine LEBLANC on 6/26/17.
//  Copyright © 2017 Marco BOOTH. All rights reserved.
//

import UIKit

class EventTracklistViewController: UIViewController {
    var eventUid: String?
    var publicOrPrivate: String?
    var firebasePath: String?
    
    var eventRef: DatabaseReference?
    var eventHandle: UInt?
    
    var tracks = [EventTrack]()
    var event: Event?
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let eventUid = self.eventUid, let publicOrPrivate = self.publicOrPrivate {
            let path = "events/\(publicOrPrivate)/\(eventUid)"

            self.firebasePath = path
            self.eventRef = Database.database().reference(withPath: path)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Observe private events
        self.eventHandle = self.eventRef?.observe(.value, with: { snapshot in
            let event = Event(snapshot: snapshot)
            
            self.event = event
            self.tracks = event.sortedTracks()
            
            // TODO: don't have to reload all the data
            self.tableView.reloadData()
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if let handle = eventHandle {
            self.eventRef?.removeObserver(withHandle: handle)
        }
    }
    
    func upVote(sender: UIButton) {
        guard let currentUser = Auth.auth().currentUser?.uid else {
            return
        }
        
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
        
        eventRef?.child("tracks/" + track.trackKey).setValue(track.toDict())
    }
    
    func downVote(sender: UIButton) {
        guard let currentUser = Auth.auth().currentUser?.uid else {
            return
        }
        
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
        
        eventRef?.child("tracks/" + track.trackKey).setValue(track.toDict())
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? SearchTableViewController, let path = self.firebasePath {
            destination.firebasePath = path
            destination.from = "event"
        } else if let destination = segue.destination as? InviteFriendsTableViewController, let path = self.firebasePath {
            destination.firebasePath = path
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
        let cell = Bundle.main.loadNibNamed("EventTrackTableViewCell", owner: self, options: nil)?.first as! EventTrackTableViewCell

        cell.title.text = tracks[indexPath.row].name
        cell.artist.text = tracks[indexPath.row].creator
        cell.nbVote.text = String(describing: tracks[indexPath.row].vote)
        
        if let currentUser = Auth.auth().currentUser?.uid, self.event?.userIds == nil || self.event?.userIds?[currentUser] != nil {
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
