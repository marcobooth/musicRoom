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
    var publicEventsCached = [Event]()
    var privateInvitedEventsCached = [Event]()
    var selectedEvent : (uid: String, name: String)?
    let userRef = Database.database().reference(withPath: "users/" + (Auth.auth().currentUser?.uid)!)
    let publicEventRef = Database.database().reference(withPath: "events/public")
    let privateEventRef = Database.database().reference(withPath: "events/private")
    let locationManager = CLLocationManager()
    var handleUser: UInt!
    var handlePublicEvents: UInt!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Start location
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.requestWhenInUseAuthorization()
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.locationManager.startUpdatingLocation()
        }
        
        // Observe private events
        handleUser = self.userRef.observe(.value, with: { snapshot in
            var events = [(uid: String, name: String)]()
            let user = User(snapshot: snapshot)
            self.privateInvitedEventsCached.removeAll()
            
            // if user is the owner of the private event is always showed
            if let userEvents = user.events {
                for event in userEvents {
                    self.privateEventRef.child(event.key).observeSingleEvent(of: .value, with: { snapshot in
                        let eventToCheck = Event(snapshot: snapshot)
                        self.privateInvitedEventsCached.append(eventToCheck)
                    })
                    events.append((uid: "private/" + event.key, name: event.value))
                }
            }
            
            // if user is invited the the event, check if is in the good location before to show
            if let invitedEvents = user.invitedEvents {
                for event in invitedEvents {
                    self.privateEventRef.child(event.key).observeSingleEvent(of: .value, with: { snapshot in
                        let eventToCheck = Event(snapshot: snapshot)
                        self.privateInvitedEventsCached.append(eventToCheck)
                        if let location = self.locationManager.location {
                            if eventToCheck.checkLocation(location: location) == true || eventToCheck.createdBy == Auth.auth().currentUser?.uid {
                                events.append((uid: "private/" + event.key, name: event.value))
                            }
                        }
                    })
                }
            }
            
            self.privateEvents = events
            if self.selector.selectedSegmentIndex == 1 {
                self.eventsToShow = self.privateEvents
                self.tableView.reloadData()
            }
            
            
        })
        
        // Observe public events
        handlePublicEvents = self.publicEventRef.observe(.value, with: { snapshot in
            var events = [(uid: String, name: String)]()
            self.publicEventsCached.removeAll()
            
            for snap in snapshot.children {
                let event = Event(snapshot: (snap as? DataSnapshot)!)
                self.publicEventsCached.append(event)
                if let location = self.locationManager.location {
                    if event.checkLocation(location: location) == true || event.createdBy == Auth.auth().currentUser?.uid {
                        events.append((uid: "public/" + (event.ref?.key)!, name: event.name))
                    }
                }
            }
            self.publicEvents = events
            if self.selector.selectedSegmentIndex == 0 {
                self.eventsToShow = self.publicEvents
                self.tableView.reloadData()
            }
            
            
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.stopUpdatingLocation()
        }
        // Remove listener with handle
        self.userRef.removeObserver(withHandle: handleUser)
        self.publicEventRef.removeObserver(withHandle: handlePublicEvents)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var events = [(uid: String, name: String)]()
        for event in publicEventsCached {
            if let location = locations.first {
                if event.checkLocation(location: location) == true || event.createdBy == Auth.auth().currentUser?.uid {
                    events.append((uid: "public/" + (event.ref?.key)!, name: event.name))
                }
            }
        }
        self.publicEvents = events
        events.removeAll()
        
        for event in privateInvitedEventsCached {
            if let location = locations.first {
                if event.checkLocation(location: location) == true || event.createdBy == Auth.auth().currentUser?.uid {
                    events.append((uid: "private/" + (event.ref?.key)!, name: event.name))
                }
            }
        }
        
        self.privateEvents = events
        
        if self.selector.selectedSegmentIndex == 0 {
            self.eventsToShow = self.publicEvents
        } else {
            self.eventsToShow = self.privateEvents
        }
        self.tableView.reloadData()
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
            self.performSegue(withIdentifier: "eventTracklistSegue", sender: self)
        }
    }
    
    @IBAction func unwindToEvents(segue: UIStoryboardSegue) {
        print("I'm back")
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "eventTracklistSegue" {
            let dest = segue.destination as! EventTracklistTableViewController
            dest.path = self.selectedEvent?.uid
            
        }
    }
    
}
