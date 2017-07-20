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
    var uid: String?
    
    var name: String?
    var createdBy: String?
    var startDate: UInt?
    var endDate: UInt?
    var longitude: Double?
    var latitude: Double?
    var radius: Int?
    var userIds: [String:Bool]?
    var tracks: [EventTrack]?
    
    var playingOnDeviceId: String?
    var currentTrack: Track?
    var isCurrentlyPlaying: Bool?
    
    init(uid: String?, dict: [String: Any]) {
        self.uid = uid
        
        self.name = dict["name"] as? String
        self.createdBy = dict["createdBy"] as? String
        self.startDate = dict["startDate"] as? UInt
        self.endDate = dict["endDate"] as? UInt
        self.longitude = dict["longitude"] as? Double
        self.latitude = dict["latitude"] as? Double
        self.radius = dict["radius"] as? Int
        self.userIds = dict["userIds"] as? [String: Bool]
        
        let trackDicts = dict["tracks"] as? [String: [String: AnyObject]]
        if let trackDicts = trackDicts {
            self.tracks = trackDicts.map { element in EventTrack(dict: element.value, trackKey: element.key) }
        }
        
        self.playingOnDeviceId = dict["playingOnDeviceid"] as? String
        if let currentTrack = dict["currentTrack"] as? [String: AnyObject] {
            self.currentTrack = Track(dict: currentTrack)
        }
        
        self.isCurrentlyPlaying = dict["isCurrentlyPlaying"] as? Bool
    }
    
    init(name: String, createdBy: String) {
        self.init(uid: nil, dict: [
            "name": name,
            "createdBy": createdBy,
        ])
    }
    
    init(snapshot: DataSnapshot) {
        if let snapshotValue = snapshot.value as? [String: Any] {
            self.init(uid: snapshot.ref.key, dict: snapshotValue)
        } else {
            print("Failed to cast snapshot value for event:", snapshot.value as Any)
            self.init(uid: nil, dict: [:])
        }
    }
    
    func toDict() -> [String: Any] {
        return [
            "name": name as Any,
            "createdBy": createdBy as Any,
            "startDate": startDate as Any,
            "endDate": endDate as Any,
            "longitude": longitude as Any,
            "latitude": latitude as Any,
            "radius": radius as Any,
            "userIds": userIds as Any,
            "tracks": tracks as Any,
            "playingOnDeviceId": playingOnDeviceId as Any,
            "currentTrack": currentTrack as Any,
            "isCurrentlyPlaying": isCurrentlyPlaying as Any,
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
