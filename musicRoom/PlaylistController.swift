//
//  PlaylistController.swift
//  musicRoom
//
//  Created by Teo FLEMING on 7/20/17.
//  Copyright © 2017 Marco BOOTH. All rights reserved.
//

import Foundation

class PlaylistController: MusicController, SnapshotHandler {
    var playlist: Playlist?
    var currentIndex: Int
    
    init(playlist path: String, startIndex: Int?, takeOverFrom: MusicController?) {
        self.currentIndex = startIndex ?? 0
        
        // XXX: rather hacky but it's unclear how to tell whether Deezer will call next() before calling current()
        // Already checked if we could use DZRPlayer.state for this.
        if DeezerSession.sharedInstance.playedOnce {
            self.currentIndex -= 1
        }
        
        super.init(path: path, takeOverFrom: takeOverFrom)
        self.snapshotHandler = self
    }
    
    func snapshotChanged(snapshot: DataSnapshot) {
        print("snapshot changed")
        self.playlist = Playlist(snapshot: snapshot)
        
        self.tracks = playlist?.sortedTracks()
        
        // TODO: update currentIndex if the song moves or is deleted
    }
    
    
    override func current(with requestManager: DZRRequestManager, callback: DZRTrackFetchingCallback?) {
        if let sortedTracks = self.tracks, currentIndex < sortedTracks.count, let callback = callback {
            let track = sortedTracks[currentIndex]
//            print("current track:", track.trackKey as Any, track.name as Any)
            
            DZRTrack.object(withIdentifier: track.deezerId, requestManager: DZRRequestManager.default(), callback: {(
                _ trackObject: Any?, _ error: Error?) -> Void in
                if let trackObject = trackObject as? DZRTrack {
                    callback(trackObject, nil)
                } else {
                    callback(nil, error)
                }
            })
        } else {
            print("Clearing music")
            
            DeezerSession.sharedInstance.clearMusic()
        }
    }
    
    override func next(with requestManager: DZRRequestManager, callback: DZRTrackFetchingCallback?) {
        print("asking for next track")
        
        currentIndex += 1
        
        return current(with: requestManager, callback: callback)
    }
    
}
