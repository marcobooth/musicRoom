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
    let playlists: [String:String]?
    let invitedPlaylists: [String:String]?
    let events: [String:String]?
    let invitedEvents: [String:String]?
    let ref: FIRDatabaseReference?
    
    init(snapshot: FIRDataSnapshot) {
        var checkPlaylists: [String:String]? = nil
        var checkInvitedPlaylists: [String:String]? = nil
        var checkEvents: [String:String]? = nil
        var checkInvitedEvents: [String:String]? = nil
        var checkRef: FIRDatabaseReference? = nil
        
        if let snapshotValue = snapshot.value as? [String: AnyObject] {
            checkRef = snapshot.ref
            
            if let playlists = snapshotValue["playlists"] {
                if let playlists = playlists as? [String:String] {
                    checkPlaylists = playlists
                }
            }
            
            if let playlists = snapshotValue["invitedPlaylists"] {
                if let playlists = playlists as? [String:String] {
                    checkInvitedPlaylists = playlists
                }
            }
            
            if let events = snapshotValue["events"] {
                if let events = events as? [String:String] {
                    checkEvents = events
                }
            }
            
            if let events = snapshotValue["invitedEvents"] {
                if let events = events as? [String:String] {
                    checkInvitedEvents = events
                }
            }
        }
        
        self.playlists = checkPlaylists
        self.invitedPlaylists = checkInvitedPlaylists
        self.events = checkEvents
        self.invitedEvents = checkInvitedEvents
        self.ref = checkRef
    }
}
