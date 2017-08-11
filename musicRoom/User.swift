//
//  User.swift
//  musicRoom
//
//  Created by Marco BOOTH on 6/12/17.
//  Copyright © 2017 Marco BOOTH. All rights reserved.
//

import Foundation

struct User {

    let playlists: [String: String]?
    let events: [String: String]?
    let friends: [String: String]?
    
    init(dict: [String: AnyObject]) {
        self.playlists = dict["playlists"] as? [String: String]
        self.events = dict["events"] as? [String: String]
        self.friends = dict["friends"] as? [String: String]
    }
    
    init(snapshot: DataSnapshot) {
        if let snapshotValue = snapshot.value as? [String: AnyObject] {
            self.init(dict: snapshotValue)
        } else {
            self.init(dict: [:])
        }
    }

}
