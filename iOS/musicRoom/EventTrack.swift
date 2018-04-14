//
//  EventTrack.swift
//  musicRoom
//
//  Created by Antoine LEBLANC on 6/29/17.
//  Copyright © 2017 Marco BOOTH. All rights reserved.
//

import Foundation

class EventTrack: Track {
    let trackKey: String
    var vote: Int
    var voters: [String: Bool]?
    
    init(dict: [String: AnyObject], trackKey: String) {
        self.trackKey = trackKey
        self.vote = dict["vote"] as? NSInteger ?? 0
        self.voters = dict["voters"] as? [String: Bool] ?? [:]
        
        super.init(dict: dict)
    }
    
    override func toDict() -> [String : Any] {
        var dict = super.toDict()
        
        dict["vote"] = vote
        dict["voters"] = voters
        
        return dict
    }
}
