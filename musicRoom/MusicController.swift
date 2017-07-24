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
    
    // TODO: incredibly unclear what the identifier function does, so I'm not sure if I'm doing it right
    private let allLetters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    private var randID: String
    
    var snapshotHandler: SnapshotHandler?

    // MARK: lifecycle
    
    /*
    ** path is the firebase path; takeOverFrom is the controller to destroy when this one becomes ready
    */
    init(path: String, takeOverFrom: MusicController?) {
        self.playablePath = path
        
        // from: https://stackoverflow.com/a/26845710
        self.randID = ""
        
        let lettersLength = UInt32(allLetters.length)
        for _ in 0 ..< 16 {
            let rand = arc4random_uniform(lettersLength)
            var nextChar = allLetters.character(at: Int(rand))
            self.randID += NSString(characters: &nextChar, length: 1) as String
        }
        
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
                    DeezerSession.sharedInstance.deezerPlayer?.play(self)
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
    }
    
    func getTrackFor(dzrId: String) -> Track? {
        // TODO: change for events?
        print("tracks", self.tracks)
        print("dzrId", dzrId)
        
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
    
    func identifier() -> String {
        return self.randID
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
