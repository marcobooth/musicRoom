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
    var startDate: String?
    var endDate: String?
    var longitude: Double?
    var latitude: Double?
    var userIds: [String:Bool]?
    var deezerTrackIds: [String: String]?
    var ref: FIRDatabaseReference?
    
    init(name: String, userId: String) {
        self.name = name
        self.createdBy = userId
        self.startDate = nil
        self.endDate = nil
        self.longitude = nil
        self.latitude = nil
        self.userIds = [userId : true]
        self.ref = nil
    }
    
    init(snapshot: FIRDataSnapshot) {
        self.name = ""
        self.createdBy = ""
        self.deezerTrackIds = nil
        self.userIds = nil
        self.ref = nil
        self.startDate = nil
        self.endDate = nil
        self.longitude = nil
        self.latitude = nil
        
        if let snapshotValue = snapshot.value as? [String: AnyObject] {
            if let name = snapshotValue["name"] as? String {
                self.name = name
            }
            if let createdBy = snapshotValue["createdBy"] as? String {
                self.createdBy = createdBy
            }
            if let deezerTrackIds = snapshotValue["deezerTrackIds"] as? [String: String] {
                self.deezerTrackIds = deezerTrackIds
            }
            if let userIds = snapshotValue["userIds"] as? [String:Bool] {
                self.userIds = userIds
            }
            if let startDate = snapshotValue["startDate"] as? String {
                self.startDate = startDate
            }
            if let endDate = snapshotValue["endDate"] as? String {
                self.endDate = endDate
            }
            if let longitude = snapshotValue["longitude"] as? Double {
                self.longitude = longitude
            }
            if let latitude = snapshotValue["latitude"] as? Double {
                self.latitude = latitude
            }
            ref = snapshot.ref
        }
        
    }
    
    func toPublicObject() -> Any {
        return [
            "name": name,
            "createdBy": createdBy,
            "deezerTrackIds": deezerTrackIds
        ]
    }
    
    func toPublicLocationObject() -> Any {
        return [
            "name": name,
            "createdBy": createdBy,
            "deezerTrackIds": deezerTrackIds,
            "startDate": startDate,
            "endDate": endDate,
            "longitude": longitude,
            "latitude": latitude
        ]
    }
    
    func toPublicInvitedObject() -> Any {
        return [
            "name": name,
            "createdBy": createdBy,
            "userIds" : userIds,
            "deezerTrackIds": deezerTrackIds
        ]
    }
    
    func toPrivateObject() -> Any {
        return [
            "name": name,
            "createdBy": createdBy,
            "userIds" : userIds,
            "deezerTrackIds": deezerTrackIds
        ]
    }
    
    func checkLocation(location: CLLocation) -> Bool {
        if let longitude = self.longitude, let latitude = self.latitude, let startDate = self.startDate, let endDate = self.endDate {
            let eventLocation = CLLocation(latitude: latitude, longitude: longitude)
            let currentDate = Date();
            if location.distance(from: eventLocation) < 500 {
                if startDate.toDate() < currentDate && currentDate < endDate.toDate() {
                    return true
                } else {return false}
            } else {return false }
        } else { return true }
    }
}
