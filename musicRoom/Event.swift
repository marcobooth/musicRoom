//
//  Event.swift
//  musicRoom
//
//  Created by Antoine LEBLANC on 6/23/17.
//  Copyright © 2017 Marco BOOTH. All rights reserved.
//

import Foundation
import CoreLocation

struct Event {
    var name: String
    var createdBy: String
    var startDate: UInt?
    var endDate: UInt?
    var longitude: Double?
    var latitude: Double?
    var radius: Int?
    var userIds: [String:Bool]?
    var tracks: [EventTrack]?
    var uid: String = ""
    
    init(name: String, userId: String) {
        self.name = name
        self.createdBy = userId
        self.startDate = nil
        self.endDate = nil
        self.longitude = nil
        self.latitude = nil
        self.radius = nil
        self.userIds = nil
        self.tracks = nil
    }
    
    init(snapshot: DataSnapshot) {
        self.name = ""
        self.createdBy = ""
        self.userIds = nil
        self.startDate = nil
        self.endDate = nil
        self.longitude = nil
        self.latitude = nil
        self.tracks = nil
        
        if let snapshotValue = snapshot.value as? [String: AnyObject] {
            if let name = snapshotValue["name"] as? String {
                self.name = name
            }
            if let createdBy = snapshotValue["createdBy"] as? String {
                self.createdBy = createdBy
            }
            let trackDicts = snapshotValue["tracks"] as? [String: [String: AnyObject]]
            if let trackDicts = trackDicts {
                self.tracks = trackDicts.map { element in EventTrack(dict: element.value, trackKey: element.key) }
            }
            
            if let userIds = snapshotValue["userIds"] as? [String: Bool] {
                self.userIds = userIds
            }
            if let startDate = snapshotValue["startDate"] as? UInt {
                self.startDate = startDate
            }
            if let endDate = snapshotValue["endDate"] as? UInt {
                self.endDate = endDate
            }
            if let longitude = snapshotValue["longitude"] as? Double {
                self.longitude = longitude
            }
            if let latitude = snapshotValue["latitude"] as? Double {
                self.latitude = latitude
            }
            if let radius = snapshotValue["radius"] as? Int {
                self.radius = radius
            }
            
            
        }
        
        self.uid = snapshot.ref.key
    }
    
    
    func toDict() -> Any {
        return [
            "name": name,
            "createdBy": createdBy,
            "startDate": startDate as Any,
            "endDate": endDate as Any,
            "longitude": longitude as Any,
            "latitude": latitude as Any,
            "radius": radius as Any,
            "userIds": userIds as Any,
            "tracks": tracks as Any,
        ]
    }
    
    func sortedTracks() -> [EventTrack] {
        // TODO: should this be cached?
        return self.tracks?.sorted { $0.vote > $1.vote } ?? []
    }
    
    func closeEnough(to location: CLLocation) -> Bool {
        if let longitude = self.longitude, let latitude = self.latitude, let radius = self.radius {
            let eventLocation = CLLocation(latitude: latitude, longitude: longitude)
            
            return location.distance(from: eventLocation) < Double(radius)
        }
        
        return true
    }
}
