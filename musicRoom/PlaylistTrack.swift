//
//  PlaylistTrack.swift
//  musicRoom
//
//  Created by Teo FLEMING on 6/28/17.
//  Copyright © 2017 Marco BOOTH. All rights reserved.
//

import Foundation

class PlaylistTrack: Track {
    let trackKey: String
    let orderNumber: Double
    
    init(dict: [String: AnyObject], trackKey: String) {
        self.trackKey = trackKey
        self.orderNumber = dict["orderNumber"] as? Double ?? 0
        
        super.init(dict: dict)
    }
}
