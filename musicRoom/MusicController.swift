//
//  TrackList.swift
//  musicRoom
//
//  Created by Teo FLEMING on 6/28/17.
//  Copyright © 2017 Marco BOOTH. All rights reserved.
//

import Foundation

class MusicController: NSObject, DZRPlayable, DZRPlayableIterator {
    private var playablePath: String
    private var playableRef: DatabaseReference?
    private var playableHandle: UInt?
    
    var tracks: [Track]?
    
    var snapshotHandler: SnapshotHandler?
    private var firstTimePlaying = true

    // MARK: lifecycle
    
    /*
    ** path is the firebase path; takeOverFrom is the controller to destroy when this one becomes ready
    */
    init(path: String, takeOverFrom: MusicController?) {
        self.playablePath = path

        // have to do this so that it compiles
        super.init()
        
        //TODO: on disconnect remove deviceId

        //        var amOnline = new Firebase('https://<demo>.firebaseio.com/.info/connected');
        //        var userRef = new Firebase('https://<demo>.firebaseio.com/presence/' + userid);
        //        amOnline.on('value', function(snapshot) {
        //            if (snapshot.val()) {
        //                userRef.onDisconnect().remove();
        //                userRef.set(true);
        //            }
        //        });
        
        playableRef = Database.database().reference(withPath: path)

        var firstSnapshot = true
        playableHandle = playableRef?.observe(.value, with: { snapshot in
            self.snapshotHandler?.snapshotChanged(snapshot: snapshot)

            if firstSnapshot {
                firstSnapshot = false
                
                // make sure this controller is still the current one (to prevent a race condition)
                if self == DeezerSession.sharedInstance.controller {
                    self.play()
                } else {
                    print("Another controller has been put into place before this one could be started:", self.playablePath)
                }
                
                // XXX: still need to clean up regardless even if the new controller isn't necessarily ready
                takeOverFrom?.destroy()
            }
        })
    }

    func destroy() {
        if let ref = playableRef, let handle = playableHandle {
            ref.removeObserver(withHandle: handle)
        }
//        DeezerSession.sharedInstance.playerDelegate?.changePlayPauseButtonState(to: nil)
    }
    
    func play() {
        // don't actually know if passing self again will mess anything up, but best be safe
        if self.firstTimePlaying {
            self.firstTimePlaying = false
            
            DeezerSession.sharedInstance.deezerPlayer?.play(self)
        } else {
            DeezerSession.sharedInstance.deezerPlayer?.play()
        }
        
        DeezerSession.sharedInstance.playerDelegate?.changePlayPauseButtonState(to: true)
    }
    
    func pause() {
        DeezerSession.sharedInstance.deezerPlayer?.pause()
        DeezerSession.sharedInstance.playerDelegate?.changePlayPauseButtonState(to: false)
    }
    
    func getTrackFor(dzrId: String) -> Track? {
        if let tracks = self.tracks {
            for track in tracks {
                if track.deezerId == dzrId {
                    return track
                }
            }
        } else {
            print("You forgot to set self.tracks in your controller.")
            print("You need to do this in order for the getTrackFor function in MusicController to work.")
        }
        
        return nil
    }
    
    // We don't know what this function does, but it's required by DZRPlayable and needs to return a string
    func identifier() -> String {
        return "I am a string"
    }
    
    /*!
     Hand over a track iterator which itself will provide the tracks of the playable object
     to a DZRPlayer.
     */
    func iterator() -> DZRPlayableIterator {
        return self
    }
    
    func current(with requestManager: DZRRequestManager, callback: DZRTrackFetchingCallback?) {
        print("This should be implemented in a subclass")
    }
    
    func next(with requestManager: DZRRequestManager, callback: DZRTrackFetchingCallback?) {
        print("This should be implemented in a subclass")
    }
}
