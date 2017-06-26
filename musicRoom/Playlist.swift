//
//  Playlist.swift
//  musicRoom
//
//  Created by Marco BOOTH on 6/12/17.
//  Copyright © 2017 Marco BOOTH. All rights reserved.
//

import Foundation

struct Playlist {
    
//    let key: String
    var name: String
    var createdBy: String
    var deezerTrackIds: [String: String]?
    var userIds: [String:Bool]?
    var ref: FIRDatabaseReference?
    
    init(name: String, userId: String) {
        self.name = name
        self.createdBy = userId
        self.deezerTrackIds = nil
        self.userIds = [userId : true]
        self.ref = nil
    }
    
    init(snapshot: FIRDataSnapshot) {
        self.name = ""
        self.createdBy = ""
        self.deezerTrackIds = nil
        self.userIds = nil
        self.ref = nil
        
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
            ref = snapshot.ref
        }
    }
    
    func toPrivateObject() -> Any {
        return [
            "name": name,
            "createdBy": createdBy,
            "userIds" : userIds,
            "deezerTrackIds": deezerTrackIds
        ]
    }
    
    func toPublicObject() -> Any {
        return [
            "name": name,
            "createdBy": createdBy,
            "deezerTrackIds": deezerTrackIds
        ]
    }
    
}
