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
    var currentTrack: Track?
    var currentDZRTrack: DZRTrack?
    var path : String?
    
    init(event path: String, takeOverFrom: MusicController?) {
        super.init(path: path, takeOverFrom: takeOverFrom)
        self.snapshotHandler = self
        self.path = path
    }
    
    func snapshotChanged(snapshot: DataSnapshot) {
        self.event = Event(snapshot: snapshot)
        
        self.tracks = event?.sortedTracks()
        
        // Music Control Delegation - allows others (with permission) to play/pause your event
        if let isCurrentlyPlaying = event?.isCurrentlyPlaying {
            if DeezerSession.sharedInstance.deezerPlayer?.isPlaying() == true && isCurrentlyPlaying == false {
                self.pause()
            } else if DeezerSession.sharedInstance.deezerPlayer?.isPlaying() == false && isCurrentlyPlaying == true {
                self.play()
            }
            
        }
    }
    
    override func current(with requestManager: DZRRequestManager, callback: DZRTrackFetchingCallback?) {
        guard let callback = callback else {
            print("this is not a good sign")
            return
        }

        if let track = self.currentDZRTrack {
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
            
            DZRTrack.object(withIdentifier: track.deezerId, requestManager: DZRRequestManager.default()) {
                ( _ trackObject: Any?, _ error: Error?) -> Void in
                if let trackObject = trackObject as? DZRTrack {
                    self.currentTrack = track
                    self.currentDZRTrack = trackObject
                } else {
                    self.currentTrack = nil
                    self.currentDZRTrack = nil
                }
                
                callback(self.currentDZRTrack, error)
            }
        } else {
            print("Clearing music")
            DeezerSession.sharedInstance.clearMusic()
        }
    }
    
    override func getTrackFor(dzrId: String) -> Track? {
        if dzrId == self.currentTrack?.deezerId {
            return self.currentTrack
        }
        
        print("this should never happen, but in case it does...")
        return super.getTrackFor(dzrId: dzrId)
    }
    
    override func play() {
        if let path = self.path {
            let eventRef = Database.database().reference(withPath: path + "/isCurrentlyPlaying")
            eventRef.setValue(true)
        }
        
        super.play()
    }
    
    override func pause() {
        if let path = self.path {
            let eventRef = Database.database().reference(withPath: path + "/isCurrentlyPlaying")
            eventRef.setValue(false)
        }
        
        super.pause()
    }
    
    override func destroy() {
        super.destroy()
        
        if let path = self.path {
            let eventDeviceRef = Database.database().reference(withPath: path + "/playingOnDeviceId")
            eventDeviceRef.removeValue()
            let eventPlayingRef = Database.database().reference(withPath: path + "/isCurrentlyPlaying")
            eventPlayingRef.removeValue()
        }
    }
    
}
