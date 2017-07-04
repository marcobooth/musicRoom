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

class EventsTableViewController: UITableViewController {

    var allPublicEvents = [Event]()
    var allPrivateEvents = [Event]()

    // TODO: need to be able to tell publicOrPrivate here
    var userEvents: [(uid: String, name: String)]?
    var privateEvents: [(uid: String, name: String)]?
    var publicEvents: [(uid: String, name: String)]?
    var selectedEvent: (uid: String, name: String, publicOrPrivate: String)?

    var userRef: DatabaseReference?
    var publicEventRef: DatabaseReference?
    var privateEventRef: DatabaseReference?
    
    var userHandle: UInt?
    var publicEventsHandle: UInt?
    
    let locationManager = CLLocationManager()
    var locationReceivedOnce = false
    
    override func viewDidLoad() {
        if let userId = Auth.auth().currentUser?.uid {
            self.userRef = Database.database().reference(withPath: "users/" + userId)
        }
        
        self.publicEventRef = Database.database().reference(withPath: "events/public")
        self.privateEventRef = Database.database().reference(withPath: "events/private")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.requestWhenInUseAuthorization()
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.locationManager.startUpdatingLocation()
        }
        
        self.userHandle = self.userRef?.observe(.value, with: { snapshot in
            let user = User(snapshot: snapshot)
            
            // if user is the owner of a private event, it is always shown
//            self.userEvents = user.events
            
            
            
            
            
            
//            var events = [(uid: String, name: String)]()
//            self.allPrivateEvents = []
//            
//            
//            if let userEvents = user.events {
//                for event in userEvents {
//                    self.privateEventRef.child(event.key).observeSingleEvent(of: .value, with: { snapshot in
//                        self.allPrivateEvents.append(Event(snapshot: snapshot))
//                    })
//                    events.append((uid: "private/" + event.key, name: event.value))
//                }
//            }
//            
//            // if user is in the the event, check if it's in the correct location before showing it
//            if let invitedEvents = user.invitedEvents {
//                for event in invitedEvents {
//                    self.privateEventRef.child(event.key).observeSingleEvent(of: .value, with: { snapshot in
//                        let eventToCheck = Event(snapshot: snapshot)
//                        self.allPrivateEvents.append(eventToCheck)
//                        if let location = self.locationManager.location {
//                            if eventToCheck.checkLocation(location: location) == true || eventToCheck.createdBy == Auth.auth().currentUser?.uid {
//                                events.append((uid: "private/" + event.key, name: event.value))
//                            }
//                        }
//                    })
//                }
//            }
        })

//        publicEventsHandle = self.publicEventRef.observe(.value, with: { snapshot in
//            var events = [(uid: String, name: String)]()
//            self.allPublicEvents.removeAll()
//            
//            for snap in snapshot.children {
//                let event = Event(snapshot: (snap as? DataSnapshot)!)
//                self.allPublicEvents.append(event)
//                if let location = self.locationManager.location {
//                    if event.checkLocation(location: location) == true || event.createdBy == Auth.auth().currentUser?.uid {
//                        events.append((uid: "public/" + (event.ref?.key)!, name: event.name))
//                    }
//                }
//            }
//            self.publicEvents = events
//            if self.selector.selectedSegmentIndex == 0 {
//                self.eventsToShow = self.publicEvents
//                self.tableView.reloadData()
//            }
//            
//            
//        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.stopUpdatingLocation()
        }

        if let handle = self.userHandle {
            self.userRef?.removeObserver(withHandle: handle)
        }
        if let handle = self.userHandle {
            self.publicEventRef?.removeObserver(withHandle: handle)
        }
    }
    
    // MARK: segues
    
    @IBAction func unwindToEvents(segue: UIStoryboardSegue) {
        print("I'm back in the events list")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "eventTracklistSegue", let destination = segue.destination as? EventTracklistViewController {
            destination.path = self.selectedEvent?.uid
        }
    }
    
    // MARK: tableView
    
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 2
//    }
//    
//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        if section == 0 {
//            return "Private playlists"
//        } else if section == 1 {
//            return "Public playlists"
//        }
//        
//        return nil
//    }
//    
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if let playlists = eventsForSection(section: section) {
//            return playlists.count
//        }
//        
//        return 1
//    }
//    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "playlistCell", for: indexPath)
//        
//        let playlists = eventsForSection(section: indexPath.section)
//        
//        if let playlists = playlists, playlists.count > 0 {
//            cell.textLabel?.text = playlists[indexPath.row].1
//        } else {
//            if indexPath.section == 0 {
//                cell.textLabel?.text = "No private playlists yet..."
//            } else if indexPath.section == 1 {
//                cell.textLabel?.text = "No public playlists yet..."
//            }
//            
//            cell.selectionStyle = UITableViewCellSelectionStyle.none
//        }
//        
//        return cell
//    }
//    
//    override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
//        var playlists: [(uid: String, name: String)]?
//        
//        if indexPath.section == 0 {
//            playlists = self.privatePlaylists
//        } else if indexPath.section == 1 {
//            playlists = self.publicPlaylists
//        }
//        
//        if let playlists = playlists {
//            let playlist = playlists[indexPath.row]
//            let publicOrPrivate = indexPath.section == 0 ? "private" : "public"
//            
//            self.selectedPlaylist = (playlist.uid, playlist.name, publicOrPrivate)
//        }
//        
//        self.performSegue(withIdentifier: "showPlaylist", sender: self)
//        
//        
//        
//        
//        self.selectedEvent = self.eventsToShow[indexPath.row - 1]
//        self.performSegue(withIdentifier: "eventTracklistSegue", sender: self)
//    }
//    
//    private func eventsForSection(section: Int) -> [(uid: String, name: String)]? {
//        if section == 0 {
//            return self.privateEvents
//        } else if section == 1 {
//            return self.publicEvents
//        }
//        
//        return nil
//    }
    
}

extension EventsTableViewController: CLLocationManagerDelegate {
//    // TODO: refactor
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        var events = [(uid: String, name: String)]()
//        for event in allPublicEvents {
//            if let location = locations.first {
//                if event.checkLocation(location: location) == true || event.createdBy == Auth.auth().currentUser?.uid {
//                    events.append((uid: "public/" + (event.ref?.key)!, name: event.name))
//                }
//            }
//        }
//        self.publicEvents = events
//        events.removeAll()
//        
//        for event in allPrivateEvents {
//            if let location = locations.first {
//                if event.checkLocation(location: location) == true || event.createdBy == Auth.auth().currentUser?.uid {
//                    events.append((uid: "private/" + (event.ref?.key)!, name: event.name))
//                }
//            }
//        }
//        
//        self.tableView.reloadData()
//    }
}
