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
    let listOfSongs: [String]
    let privateAccess: Bool
    let ref: FIRDatabaseReference?
    
    init(name: String, createdBy: String, privateAccess: Bool, key: String = "") {
//        self.key = key
        self.name = name
        self.createdBy = createdBy
        self.listOfSongs = []
        self.privateAccess = privateAccess
        self.ref = nil
    }
    
    init(snapshot: FIRDataSnapshot) {
//        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        name = snapshotValue["name"] as! String
        createdBy = snapshotValue["createdBy"] as! String
        privateAccess = snapshotValue["privateAccess"] as! Bool
//        listOfSongs = snapshotValue["listOfSongs"] as! Array
        listOfSongs = [String]()
        ref = snapshot.ref
    }
    
    func toAnyObject() -> Any {
        return [
            "name": name,
            "createdBy": createdBy,
            "listOfSongs": listOfSongs,
            "privateAccess": privateAccess
        ]
    }
    
}