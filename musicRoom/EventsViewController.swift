//
//  EventsViewController.swift
//  musicRoom
//
//  Created by Antoine LEBLANC on 6/23/17.
//  Copyright © 2017 Marco BOOTH. All rights reserved.
//

import UIKit
import Firebase

class EventsTableViewController: UITableViewController {

    var eventNames = [(uid: String, name: String)]()
    var selectedEvent : (uid: String, name:String)?
    let userRef = FIRDatabase.database().reference(withPath: "users/" + (FIRAuth.auth()?.currentUser?.uid)!)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DeezerSession.sharedInstance.deezerConnect = DeezerConnect(appId: "238082", andDelegate: DeezerSession.sharedInstance)
        DeezerSession.sharedInstance.setUp()
        
        self.userRef.observe(.value, with: { snapshot in
            var events = [(uid: String, name: String)]()
            
            let user = User(snapshot: snapshot)
            print(user)
            if let userEvents = user.events {
                for event in userEvents {
                    events.append((uid: event.key, name: event.value))
                }
            }
            
            if let invitedEvents = user.invitedEvents {
                for event in invitedEvents {
                    events.append((uid: event.key, name: event.value))
                }
            }
            
            self.eventNames = events
            print("reload data");
            self.tableView.reloadData()
        })
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.eventNames.count + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath)
        if indexPath.row == 0 {
            cell.textLabel?.text = "Create Event"
        } else {
            cell.textLabel?.text = self.eventNames[indexPath.row - 1].1
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            self.performSegue(withIdentifier: "createEventSegue", sender: self)
        } else {
            self.selectedEvent = self.eventNames[indexPath.row - 1]
  //          self.performSegue(withIdentifier: "showEvent", sender: self)
        }
    }
    
    @IBAction func unwindToEvents(segue: UIStoryboardSegue) {
        print("I'm back")
    }
}
