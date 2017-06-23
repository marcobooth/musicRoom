//
//  Event.swift
//  musicRoom
//
//  Created by Antoine LEBLANC on 6/23/17.
//  Copyright © 2017 Marco BOOTH. All rights reserved.
//

import Foundation

struct Event {
    var name: String
    var createdBy: String
    var startDate: String?
    var endDate: String?
//    var location: ????
    var userIds: [String:Bool]?
    var deezerTrackIds: [String: String]?
    var ref: FIRDatabaseReference?
    
    init(name: String, userId: String) {
        self.name = name
        self.createdBy = userId
        self.startDate = nil
        self.endDate = nil
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
//            "location": location
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
}
