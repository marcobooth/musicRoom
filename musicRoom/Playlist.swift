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
    let name: String
    let createdBy: String
    let deezerTrackIds: [String: String]?
    let userIds: [String:Bool]?
    let ref: FIRDatabaseReference?
    
    init(name: String, userId: String) {
        self.name = name
        self.createdBy = userId
        self.deezerTrackIds = nil
        self.userIds = [userId : true]
        self.ref = nil
    }
    
    init(snapshot: FIRDataSnapshot) {
        let snapshotValue = snapshot.value as! [String: AnyObject]
        name = snapshotValue["name"] as! String
        createdBy = snapshotValue["createdBy"] as! String
        deezerTrackIds = snapshotValue["deezerTrackIds"] as! [String: String]
        userIds = snapshotValue["userIds"] as! [String:Bool]
        ref = snapshot.ref
    }
    
    func toAnyObject() -> Any {
        return [
            "name": name,
            "createdBy": createdBy,
            "userIds" : userIds,
            "deezerTrackIds": deezerTrackIds
        ]
    }
    
}
