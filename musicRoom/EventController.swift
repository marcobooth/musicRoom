//
//  EventController.swift
//  musicRoom
//
//  Created by Marco BOOTH on 7/21/17.
//  Copyright © 2017 Marco BOOTH. All rights reserved.
//

import Foundation

class EventController: MusicController, SnapshotHandler {
    
    var event: Event?
    var currentTrack: DZRTrack?
    var path : String?
    
    init(event path: String, takeOverFrom: MusicController?) {
        super.init(path: path, takeOverFrom: takeOverFrom)
        self.snapshotHandler = self
        self.path = path
    }
    
    func snapshotChanged(snapshot: DataSnapshot) {
        self.event = Event(snapshot: snapshot)
        
        self.tracks = event?.sortedTracks()
    }
    
    
    override func current(with requestManager: DZRRequestManager, callback: DZRTrackFetchingCallback?) {
        guard let callback = callback else {
            print("this is not a good sign")
            return
        }

        if let track = self.currentTrack {
            callback(track, nil)
        } else {
            return next(with: requestManager, callback: callback)
        }
    }
    
    override func next(with requestManager: DZRRequestManager, callback: DZRTrackFetchingCallback?) {
        guard let callback = callback else {
            print("this is not a good sign")
            return
        }
        
        if let tracks = self.tracks, tracks.count > 0, let path = self.path, let track = tracks[0] as? EventTrack {
            let eventRef = Database.database().reference(withPath: path + "/tracks/\(track.trackKey)")
            // Race condition but it's ok because only one person can play an event at once
            eventRef.removeValue()
            
            DZRTrack.object(withIdentifier: track.deezerId, requestManager: DZRRequestManager.default(), callback: {(
                _ trackObject: Any?, _ error: Error?) -> Void in
                if let trackObject = trackObject as? DZRTrack {
                    self.currentTrack = trackObject
                    callback(trackObject, nil)
                } else {
                    self.currentTrack = nil
                    callback(nil, error)
                }
            })
        } else {
            //TODO: make sure event has stopeed when tracks run out
            print("Clearing music")
            DeezerSession.sharedInstance.clearMusic()
        }
    }
    
}
