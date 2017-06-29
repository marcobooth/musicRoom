//
//  Track.swift
//  musicRoom
//
//  Created by Antoine LEBLANC & Teo FLEMING on 6/27/17.
//  Copyright © 2017 Marco BOOTH. All rights reserved.
//

import Foundation


class Track {

    var deezerId: String
    var name: String
    var creator: String
    var duration: Int
    var ref: DatabaseReference?
    
    init(deezerId: String, name: String, creator: String, duration: NSInteger) {
        self.deezerId = deezerId
        self.name = name
        self.creator = creator
        self.duration = duration
    }
    
    init(dict: [String: AnyObject]) {
        self.deezerId = dict["deezerId"] as? String ?? ""
        self.name = dict["name"] as? String ?? ""
        self.creator = dict["creator"] as? String ?? ""
        self.duration = dict["duration"] as? NSInteger ?? 0
    }
    
    convenience init(snapshot: DataSnapshot) {
        if let snapshotValue = snapshot.value as? [String: AnyObject] {
            self.init(dict: snapshotValue)
            self.ref = snapshot.ref
            print("==== ref", self.ref)
        } else {
            // Wow Swift. Makin' me cast everything like that is ugly af
            self.init(dict: [
                "deezerId": "" as AnyObject,
                "name": "" as AnyObject,
                "creator": "" as AnyObject,
                "duration": 0 as AnyObject
            ])
        }
    }
    
    func toDict() -> [String: Any] {
              print("track dic")
        return [
            "deezerId": deezerId,
            "name": name,
            "creator": creator,
            "duration": duration
        ]
    }
}