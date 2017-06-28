//
//  EventTracklistTableViewController.swift
//  musicRoom
//
//  Created by Antoine LEBLANC on 6/26/17.
//  Copyright © 2017 Marco BOOTH. All rights reserved.
//

import UIKit

class EventTracklistTableViewController: UITableViewController {

    
    var path: String?
    var handle: UInt!
    var ref: DatabaseReference!
    var tracks = [Track]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
      //  self.tableView.register(EventCellTableViewCell.self, forCellReuseIdentifier: "eventCell")
        if let p = self.path {
            self.ref = Database.database().reference(withPath: "events/" + p + "/tracks")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Observe private events
        handle = self.ref.observe(.value, with: { snapshot in
            var tracks = [Track]()
            
            print("Tracks updating...")
            for snap in snapshot.children {
                let  track = Track(snapshot: (snap as? DataSnapshot)!)
                tracks.append(track)
            }
            self.tracks = tracks.sorted(by: { $0.vote > $1.vote })
            self.tableView.reloadData()
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.ref.removeObserver(withHandle: handle)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: EventCellTableViewCell
        if let c = tableView.dequeueReusableCell(withIdentifier: "eventCell") as! EventCellTableViewCell? {
            cell = c
        } else {
            cell = Bundle.main.loadNibNamed("EventCellTableViewCell", owner: self, options: nil)?.first as! EventCellTableViewCell
        }
        cell.title.text = tracks[indexPath.row].name
        cell.artist.text = tracks[indexPath.row].creator
        cell.nbVote.text = String(describing: tracks[indexPath.row].vote)
        
        if tracks[indexPath.row].voters?[(Auth.auth().currentUser?.uid)!] == true {
            cell.upVote.setTitle("☑️", for: .normal)
            cell.downVote.setTitle("👎", for: .normal)
        } else if tracks[indexPath.row].voters?[(Auth.auth().currentUser?.uid)!] == nil {
            cell.upVote.setTitle("👍", for: .normal)
            cell.downVote.setTitle("👎", for: .normal)
        } else {
            cell.upVote.setTitle("👍", for: .normal)
            cell.downVote.setTitle("☑️", for: .normal)
        }
        cell.upVote.tag = indexPath.row
        cell.upVote.addTarget(self, action: #selector(upVote), for: .touchUpInside)
        cell.downVote.tag = indexPath.row
        cell.downVote.addTarget(self, action: #selector(downVote), for: .touchUpInside)
        return cell
    }
    
    func upVote(sender: UIButton) {
        var track = tracks[sender.tag]
        var userVote = track.voters?[(Auth.auth().currentUser?.uid)!]
        if userVote == false {
            track.vote += 2
            track.voters?[(Auth.auth().currentUser?.uid)!] = true
        } else if userVote == nil {
            track.vote += 1
            track.voters?[(Auth.auth().currentUser?.uid)!] = true
        } else if userVote == true {
            track.vote -= 1
            track.voters?[(Auth.auth().currentUser?.uid)!] = nil
        }
        
        track.ref?.setValue(track.toDict())

    }
    
    func downVote(sender: UIButton) {
        var track = tracks[sender.tag]
        var userVote = track.voters?[(Auth.auth().currentUser?.uid)!]
        
        if userVote == true {
            track.vote -= 2
            track.voters?[(Auth.auth().currentUser?.uid)!] = false
        } else if userVote == nil {
            track.vote -= 1
            track.voters?[(Auth.auth().currentUser?.uid)!] = false
        } else if userVote == false {
            track.vote += 1
            track.voters?[(Auth.auth().currentUser?.uid)!] = nil
        }
        
        track.ref?.setValue(track.toDict())
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tracks.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? SearchTableViewController, let path = self.path {
            destination.firebasePath = "events/" + path
            destination.from = "event"
        }
    }
    
    @IBAction func unwindToEventTracklist(segue: UIStoryboardSegue) {
        print("I'm back in the event tracklist")
    }
}
