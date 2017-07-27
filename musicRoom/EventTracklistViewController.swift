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
    var eventName: String?
    var publicEvent: Bool?
    var firebasePath: String?
    
    var eventRef: DatabaseReference?
    var eventHandle: UInt?
    
    var tracks: [EventTrack]?
    var event: Event?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addFriendsButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var infoLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let eventUid = self.eventUid, self.publicEvent != nil  {
            let publicOrPrivate = (self.publicEvent == true ? "public" : "private")
            let path = "events/\(publicOrPrivate)/\(eventUid)"

            self.firebasePath = path
            self.eventRef = Database.database().reference(withPath: path)
        }
        
        self.title = self.eventName
        
        // TODO: button should be disabled for those who are not the owner
        if self.publicEvent == true {
            self.addFriendsButton.setTitle("Music Control", for: .normal)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.isHidden = true
        
        self.eventHandle = self.eventRef?.observe(.value, with: { snapshot in
            let event = Event(snapshot: snapshot)
            
            self.event = event
            
            self.tracks = event.sortedTracks()
            if self.tracks?.count == 0 {
                self.tableView.isHidden = true
                self.infoLabel.isHidden = false
                self.infoLabel.text = "You haven't added any tracks yet!"
                self.startButton.isEnabled = false
            } else {
                self.tableView.isHidden = false
                self.infoLabel.isHidden = true
                self.startButton.isEnabled = true
            }
            
            self.tableView.reloadData()
            
            if event.createdBy == Auth.auth().currentUser?.uid {
                if event.playingOnDeviceId != nil {
                    self.startButton.isEnabled = true
                    self.startButton.setTitle("Stop", for: .normal)
                } else {
                    self.startButton.setTitle("Start", for: .normal)
                }
            } else {
                if let currentUser = Auth.auth().currentUser?.uid, event.playingOnDeviceId != nil, event.userIds?[currentUser] == true {
                    if event.isCurrentlyPlaying == true {
                        self.startButton.setTitle("Pause", for: .normal)
                        self.startButton.isEnabled = true
                    } else if event.isCurrentlyPlaying == false {
                        self.startButton.setTitle("Play", for: .normal)
                        self.startButton.isEnabled = true
                    } else {
                        self.startButton.setTitle("Play", for: .normal)
                        self.startButton.isEnabled = false
                    }
                } else {
                    self.startButton.isEnabled = false
                }
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if let handle = eventHandle {
            self.eventRef?.removeObserver(withHandle: handle)
        }
    }
    
    @IBAction func addFriends(_ sender: UIButton) {
        self.performSegue(withIdentifier: "addAFriend", sender: nil)
    }

    // MARK: helpers
    
    func upVote(sender: UIButton) {
        guard let track = tracks?[sender.tag],
                let currentUser = Auth.auth().currentUser?.uid,
                let ref = self.eventRef?.child("tracks/" + track.trackKey) else {
            return
        }
        
        ref.runTransactionBlock({ (currentData: MutableData) in

            guard let currentValue = currentData.value as? [String: AnyObject] else {
                return TransactionResult.abort()
            }
            
            let currentTrack = EventTrack(dict: currentValue, trackKey: track.trackKey)
            
            let userVote = currentTrack.voters?[currentUser]
            
            if userVote == false {
                currentTrack.vote += 2
                currentTrack.voters?[currentUser] = true
            } else if userVote == nil {
                currentTrack.vote += 1
                currentTrack.voters?[currentUser] = true
            } else if userVote == true {
                currentTrack.vote -= 1
                currentTrack.voters?[currentUser] = nil
            }
            
            currentData.value = currentTrack.toDict()
            return TransactionResult.success(withValue: currentData)
        }, andCompletionBlock: {
            (error, committed, snapshot) in
            if error != nil {
                print(error?.localizedDescription ?? "No description of the error")
            }
        })
        
    }
    
    func downVote(sender: UIButton) {
        guard let track = tracks?[sender.tag],
                let currentUser = Auth.auth().currentUser?.uid,
                let ref = self.eventRef?.child("tracks/" + track.trackKey) else {
            return
        }
        
        ref.runTransactionBlock({ (currentData: MutableData) in
            
            guard let currentValue = currentData.value as? [String: AnyObject] else {
                return TransactionResult.abort()
            }
            
            let currentTrack = EventTrack(dict: currentValue, trackKey: track.trackKey)
            
            let userVote = currentTrack.voters?[currentUser]

            if userVote == true {
                currentTrack.vote -= 2
                currentTrack.voters?[currentUser] = false
            } else if userVote == nil {
                currentTrack.vote -= 1
                currentTrack.voters?[currentUser] = false
            } else if userVote == false {
                currentTrack.vote += 1
                currentTrack.voters?[currentUser] = nil
            }
            
            currentData.value = currentTrack.toDict()
            return TransactionResult.success(withValue: currentData)
        }, andCompletionBlock: {
            (error, committed, snapshot) in
            if error != nil {
                print(error?.localizedDescription ?? "No description of the error")
            }
        })
    }
    
    // MARK: segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? SongSearchViewController, let path = self.firebasePath {
            destination.firebasePath = path
            destination.from = "event"
        } else if let destination = segue.destination as? InviteFriendsViewController, let path = self.firebasePath {
            destination.publicEvent = self.publicEvent
            destination.firebasePath = path
            destination.from = "event"
            destination.name = event?.name
        }
    }
    
    @IBAction func unwindToEventTracklist(segue: UIStoryboardSegue) {
        print("I'm back in the event tracklist")
    }
    
    // MARK: events
    @IBAction func startEvent(_ sender: UIButton) {
        guard let path = self.firebasePath, let buttonText = self.startButton.titleLabel?.text else {
            return
        }
        
        let eventDeviceRef = Database.database().reference(withPath: path + "/playingOnDeviceId")
        let eventCurrentlyPlayingRef = Database.database().reference(withPath: path + "/isCurrentlyPlaying")

        switch buttonText {
        case "Start":
            if let deviceId = DeezerSession.sharedInstance.deviceId {
                eventDeviceRef.setValue(deviceId, withCompletionBlock: { (error, reference) in
                    if error == nil {
                        DeezerSession.sharedInstance.setMusic(toEvent: path)
                    }
                })
            }
        case "Stop":
            DeezerSession.sharedInstance.clearMusic()
            eventDeviceRef.removeValue()
        case "Play":
            eventCurrentlyPlayingRef.setValue(true)
        case "Pause":
            eventCurrentlyPlayingRef.setValue(false)
        default:
            print("Someone named this button weirdly...")
        }
    }
}

extension EventTracklistViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let tracks = self.tracks else {
            return 0
        }
        return tracks.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("EventTrackTableViewCell", owner: self, options: nil)?.first as! EventTrackTableViewCell
        
        if let tracks = self.tracks, tracks.count > 0, let currentUser = Auth.auth().currentUser?.uid {
            cell.title.text = tracks[indexPath.row].name
            cell.artist.text = tracks[indexPath.row].creator
            cell.nbVote.text = String(describing: tracks[indexPath.row].vote)
            
            if tracks[indexPath.row].voters?[currentUser] == true {
                cell.upVote.setTitle("✅", for: .normal)
                cell.downVote.setTitle("👎", for: .normal)
            } else if tracks[indexPath.row].voters?[currentUser] == false {
                cell.upVote.setTitle("👍", for: .normal)
                cell.downVote.setTitle("❌", for: .normal)
            } else {
                cell.upVote.setTitle("👍", for: .normal)
                cell.downVote.setTitle("👎", for: .normal)
            }
            
            cell.upVote.tag = indexPath.row
            cell.downVote.tag = indexPath.row
            cell.upVote.addTarget(self, action: #selector(upVote), for: .touchUpInside)
            cell.downVote.addTarget(self, action: #selector(downVote), for: .touchUpInside)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}
