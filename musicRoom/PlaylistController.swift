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
    
    var currentTrack: DZRTrack?
    var currentIndex: Int
    
    init(playlist path: String, startIndex: Int?, takeOverFrom: MusicController?) {
        self.currentIndex = startIndex ?? 0
        
        super.init(path: path, takeOverFrom: takeOverFrom)
        self.snapshotHandler = self
    }
    
    func snapshotChanged(snapshot: DataSnapshot) {
        self.playlist = Playlist(snapshot: snapshot)
        
        self.tracks = playlist?.sortedTracks()
        
        // TODO: update currentIndex if the song moves or is deleted
    }
    
    
    override func current(with requestManager: DZRRequestManager, callback: DZRTrackFetchingCallback?) {
        guard let callback = callback else {
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
            return
        }
        
        // this is how we know if Deezer has called current or next before -- thanks Deezer!
        if self.currentTrack != nil {
            currentIndex += 1
        }
        
        if let sortedTracks = self.tracks, currentIndex < sortedTracks.count {
            let track = sortedTracks[currentIndex]
            
            DZRTrack.object(withIdentifier: track.deezerId, requestManager: DZRRequestManager.default()) {
                ( _ trackObject: Any?, _ error: Error?) -> Void in
                
                if let trackObject = trackObject as? DZRTrack {
                    self.currentTrack = trackObject
                } else {
                    self.currentTrack = nil
                }
                
                callback(self.currentTrack, error)
            }
        } else {
            print("Clearing music")
            
            DeezerSession.sharedInstance.clearMusic()
        }
    }
    
}
