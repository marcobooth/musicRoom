//
//  EventsViewController.swift
//  musicRoom
//
//  Created by Antoine LEBLANC on 6/23/17.
//  Copyright © 2017 Marco BOOTH. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class EventsTableViewController: UITableViewController, CLLocationManagerDelegate {


    @IBOutlet weak var selector: UISegmentedControl!
    var eventsToShow = [(uid: String, name: String)]()
    var privateEvents = [(uid: String, name: String)]()
    var publicEvents = [(uid: String, name: String)]()
    var selectedEvent : (uid: String, name: String)?
    let userRef = Database.database().reference(withPath: "users/" + (Auth.auth().currentUser?.uid)!)
    let publicEventRef = Database.database().reference(withPath: "events/public")
    let locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Start location
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.requestWhenInUseAuthorization()
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.locationManager.startUpdatingLocation()
        }
        
        DeezerSession.sharedInstance.deezerConnect = DeezerConnect(appId: "238082", andDelegate: DeezerSession.sharedInstance)
        DeezerSession.sharedInstance.setUp()
        
        // Observe private events
        self.userRef.observe(.value, with: { snapshot in
            var events = [(uid: String, name: String)]()
            
            let user = User(snapshot: snapshot)
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
            
            self.privateEvents = events
            if self.selector.selectedSegmentIndex == 1 {
                self.eventsToShow = self.privateEvents
            }
            self.tableView.reloadData()
        })
        
        
        // Observe public events
        self.publicEventRef.observe(.value, with: { snapshot in
            var events = [(uid: String, name: String)]()
            
            for snap in snapshot.children {
                print("event")
                let event = Event(snapshot: (snap as? DataSnapshot)!)
                if event.checkLocation(location: self.locationManager.location!) == true {
                    events.append((uid: "FAKE UID", name: event.name))
                }
            }
            self.publicEvents = events
            if self.selector.selectedSegmentIndex == 0 {
                self.eventsToShow = self.publicEvents
            }
            self.tableView.reloadData()
        })
        

    }
    
    @IBAction func selectorChange(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            eventsToShow = publicEvents
            self.tableView.reloadData()
        } else if sender.selectedSegmentIndex == 1 {
            eventsToShow = privateEvents
            self.tableView.reloadData()
        }
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.eventsToShow.count + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath)
        if indexPath.row == 0 {
            cell.textLabel?.text = "Create Event"
        } else {
            cell.textLabel?.text = self.eventsToShow[indexPath.row - 1].1
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            self.performSegue(withIdentifier: "createEventSegue", sender: self)
        } else {
            self.selectedEvent = self.eventsToShow[indexPath.row - 1]
  //          self.performSegue(withIdentifier: "showEvent", sender: self)
        }
    }
    
    @IBAction func unwindToEvents(segue: UIStoryboardSegue) {
        print("I'm back")
    }
}
