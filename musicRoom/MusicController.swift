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
    private var playableRef: DatabaseReference? = nil
    private var playableHandle: UInt? = nil
    
    var tracks: [Track]?
    
    private let allLetters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    private var randID: String
    
    var snapshotHandler: SnapshotHandler?

    // MARK: lifecycle
    
    init(path: String, whenReady: @escaping (MusicController) -> ()) {
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
        
        // TODO: set both user's playing event, the event's device as this one: make sure they have the rights and all
        
        //        var amOnline = new Firebase('https://<demo>.firebaseio.com/.info/connected');
        //        var userRef = new Firebase('https://<demo>.firebaseio.com/presence/' + userid);
        //        amOnline.on('value', function(snapshot) {
        //            if (snapshot.val()) {
        //                userRef.onDisconnect().remove();
        //                userRef.set(true);
        //            }
        //        });
        
        playableRef = Database.database().reference(withPath: path)

        playableHandle = playableRef?.observe(.value, with: { snapshot in
            self.snapshotHandler?.snapshotChanged(snapshot: snapshot)

            whenReady(self)
        })
    }

    func destroy() {
        if let ref = playableRef, let handle = playableHandle {
            ref.removeObserver(withHandle: handle)
        }
    }
    
    func getTrackFor(dzrId: String) -> Track? {
        // TODO: change for events?
        
        if let tracks = self.tracks {
            for track in tracks {
                if track.deezerId == dzrId {
                    return track
                }
            }
        }
        
        return nil
    }
    
    // TODO: incredibly unclear what this identifier function does, so I'm not sure if I'm doing it right
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
