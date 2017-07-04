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
    var privateEvents: [(uid: String, name: String)]?
    var publicEvents: [(uid: String, name: String)]?
    var selectedEvent: (uid: String, name: String, publicOrPrivate: String)?

    var userRef: DatabaseReference?
    var publicEventsRef: DatabaseReference?
    
    var userHandle: UInt?
    var publicEventsHandle: UInt?
    
    let locationManager = CLLocationManager()
    var locationReceivedOnce = false
    
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
            self.locationManager.requestWhenInUseAuthorization()
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.locationManager.startUpdatingLocation()
        }
        
        self.userHandle = self.userRef?.observe(.value, with: { snapshot in
            let user = User(snapshot: snapshot)
            
            self.privateEvents = user.events?.map { element in (uid: element.key, name: element.value) }
        })
        
        self.publicEventsHandle = self.publicEventsRef?.observe(.value, with: { snapshot in
            var events = [(uid: String, name: String)]()
            
            for snap in snapshot.children {
                if let snap = snap as? DataSnapshot {
                    let event = Event(snapshot: snap)
                    events.append((uid: ""))
                }
                
            }
        })
        
        publicPlaylistHandle = self.publicPlaylistRef?.observe(.value, with: { snapshot in
            var playlists = [(uid: String, name: String)]()
            
            for snap in snapshot.children {
                let playlist = Playlist(snapshot: snap as! DataSnapshot)
                playlists.append((uid: "public/" + (playlist.ref?.key)!, name: playlist.name))
            }
            
            self.publicPlaylists = playlists
            self.tableView.reloadData()
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
            destination.path = self.selectedEvent?.uid
        }
    }
    
    // MARK: tableView
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Private events"
        } else if section == 1 {
            return "Public events"
        }
        
        return nil
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let playlists = eventsForSection(section: section) {
            return playlists.count
        }
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "playlistCell", for: indexPath)

        if let playlists = eventsForSection(section: indexPath.section), playlists.count > 0 {
            cell.textLabel?.text = playlists[indexPath.row].1
        } else {
            if indexPath.section == 0 {
                cell.textLabel?.text = "No private events yet..."
            } else if indexPath.section == 1 {
                cell.textLabel?.text = "No public events yet..."
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyle.none
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        var playlists: [(uid: String, name: String)]?
        
        if indexPath.section == 0 {
            playlists = self.privatePlaylists
        } else if indexPath.section == 1 {
            playlists = self.publicPlaylists
        }
        
        if let playlists = playlists {
            let playlist = playlists[indexPath.row]
            let publicOrPrivate = indexPath.section == 0 ? "private" : "public"
            
            self.selectedPlaylist = (playlist.uid, playlist.name, publicOrPrivate)
        }
        
        self.selectedEvent = self.eventsToShow[indexPath.row - 1]
        self.performSegue(withIdentifier: "eventTracklistSegue", sender: self)
    }
    
    // MARK: helpers
    
    private func eventsForSection(section: Int) -> [(uid: String, name: String)]? {
        if section == 0 {
            return self.userEvents
        } else if section == 1 {
            return self.privateEvents
        } else if section == 2 {
            return self.publicEvents
        }
        
        return nil
    }
    
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
