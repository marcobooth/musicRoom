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

class EventsViewController: UIViewController {

    var privateEvents: [(uid: String, name: String)]?
    var allPublicEvents: [Event]?
    var publicEvents: [(uid: String, name: String)]?
    var selectedEvent: (uid: String, name: String, publicEvent: Bool)?

    var userRef: DatabaseReference?
    var publicEventsRef: DatabaseReference?
    
    var userHandle: UInt?
    var publicEventsHandle: UInt?
    
    let locationManager = CLLocationManager()
    var lastKnownLocation: CLLocation?
    
    @IBOutlet weak var tableView: UITableView!
    // MARK: lifecycle
    
    override func viewDidLoad() {
        if let userId = Auth.auth().currentUser?.uid {
            self.userRef = Database.database().reference(withPath: "users/" + userId)
        }
        
        self.publicEventsRef = Database.database().reference(withPath: "events/public")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined:
                self.locationManager.requestWhenInUseAuthorization()
            case .denied:
                self.showLocationAlert()
            default: break
            }
            
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.locationManager.startUpdatingLocation()
        }
        
        self.userHandle = self.userRef?.observe(.value, with: { snapshot in
            let user = User(snapshot: snapshot)
            
            self.privateEvents = user.events?.map { element in (uid: element.key, name: element.value) }
            if self.privateEvents == nil {
                self.privateEvents = []
            }
            
            self.tableView.reloadData()
        })
        
        self.publicEventsHandle = self.publicEventsRef?.observe(.value, with: { snapshot in
            var events = [Event]()
            
            for snap in snapshot.children {
                if let snap = snap as? DataSnapshot {
                    let event = Event(snapshot: snap)
                    
                    events.append(event)
                }
            }
            
            self.allPublicEvents = events
            
            self.refilterPublicEvents()
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.stopUpdatingLocation()
        }

        if let handle = self.userHandle {
            self.userRef?.removeObserver(withHandle: handle)
        }
        if let handle = self.publicEventsHandle {
            self.publicEventsRef?.removeObserver(withHandle: handle)
        }
    }
    
    // MARK: segues
    
    @IBAction func unwindToEvents(segue: UIStoryboardSegue) {
        print("I'm back in the events list")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "eventTracklistSegue", let destination = segue.destination as? EventTracklistViewController {
            destination.eventUid = self.selectedEvent?.uid
            destination.eventName = self.selectedEvent?.name
            destination.publicEvent = self.selectedEvent?.publicEvent
        }
    }
    
    // MARK: helpers
    
    func eventsForSection(section: Int) -> [(uid: String, name: String)]? {
        if section == 0 {
            return self.privateEvents
        } else if section == 1 {
            return self.publicEvents
        }
        
        return nil
    }
    
    func refilterPublicEvents() {
        guard let lastKnownLocation = self.lastKnownLocation else {
            self.publicEvents = nil
            return
        }
        
        let goodToShow = self.allPublicEvents?.filter { event in
            if let userId = Auth.auth().currentUser?.uid {
                if userId == event.createdBy {
                    return true
                }
            }
            if event.closeEnough(to: lastKnownLocation) && event.timeRange() {
                return true
            } else {
                return false
            }
        }
        
        self.publicEvents = goodToShow?.map { event in
            if let uid = event.uid, let name = event.name {
                return (uid: uid, name: name)
            }
            
            // kinda hacky, but if this is ever run there's a problemo
            return (uid: "", name: "Name failed to load")
        }
        
        self.tableView.reloadData()
    }
}

extension EventsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Private events"
        } else if section == 1 {
            return "Public events"
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let events = eventsForSection(section: section), events.count > 0 {
            return events.count
        }
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath)
        
        let events = eventsForSection(section: indexPath.section)
        
        if let events = events, events.count > 0 {
            cell.textLabel?.text = events[indexPath.row].name
            
            cell.selectionStyle = UITableViewCellSelectionStyle.default
            cell.textLabel?.textColor = UIColor.black
        } else {
            if events == nil {
                cell.textLabel?.text = "Loading..."
            } else {
                if indexPath.section == 0 {
                    cell.textLabel?.text = "No private events yet..."
                } else if indexPath.section == 1 {
                    if lastKnownLocation == nil {
                        cell.textLabel?.text = "Waiting for location..."
                    } else {
                        cell.textLabel?.text = "No public events yet..."
                    }
                }
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.textLabel?.textColor = UIColor.gray
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let events = eventsForSection(section: indexPath.section), events.count > 0 {
            let metadata = events[indexPath.row]
            let publicOrPrivate = indexPath.section == 0 ? false : true
            self.selectedEvent = (uid: metadata.uid, name: metadata.name, publicEvent: publicOrPrivate)
            
            self.performSegue(withIdentifier: "eventTracklistSegue", sender: self)
        }
    }
}

extension EventsViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // unclear what the best practice is for getting the last known location (first? last? average? hum)
        self.lastKnownLocation = locations.first
        
        self.refilterPublicEvents()
    }
}
