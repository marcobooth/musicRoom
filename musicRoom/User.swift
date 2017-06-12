//
//  User.swift
//  musicRoom
//
//  Created by Marco BOOTH on 6/12/17.
//  Copyright © 2017 Marco BOOTH. All rights reserved.
//

import Foundation

struct User {
    
    //    let key: String
    let myPlaylists: [String:String]?
    let ref: FIRDatabaseReference?
    
    init(snapshot: FIRDataSnapshot) {
        //        key = snapshot.key
        if let snapshotValue = snapshot.value as? [String: AnyObject] {
            print("snapshot", snapshotValue)
            if let playlists = snapshotValue["myPlaylists"] {
                print("playlists", playlists)
                if let playlists = playlists as? [String:String] {
                    print("playlists", playlists)
                    self.myPlaylists = playlists
                    ref = snapshot.ref
                    return
                }
            }
        }
        ref = nil
        myPlaylists = nil
    }
    
}
