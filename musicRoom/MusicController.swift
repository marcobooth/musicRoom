//
//  TrackList.swift
//  musicRoom
//
//  Created by Teo FLEMING on 6/28/17.
//  Copyright © 2017 Marco BOOTH. All rights reserved.
//

import Foundation

class MusicController: DZRObjectList {
//    private let playableType: String?
//    private let playablePath: String?
    private var playableRef: DatabaseReference? = nil
    private var playableHandle: UInt? = nil
    
    private var tracks: [Track]? = nil

    // MARK: lifecycle
    
    private init(isEvent: Bool, path: String) {
        // TODO: set both user's playing event, the event's device as this one: make sure they have the rights and all
        
        //        var amOnline = new Firebase('https://<demo>.firebaseio.com/.info/connected');
        //        var userRef = new Firebase('https://<demo>.firebaseio.com/presence/' + userid);
        //        amOnline.on('value', function(snapshot) {
        //            if (snapshot.val()) {
        //                userRef.onDisconnect().remove();
        //                userRef.set(true);
        //            }
        //        });
        
        // have to do this before the self is captured in the closure
        super.init()
        
        playableRef = Database.database().reference(withPath: path)

        playableHandle = playableRef?.observe(.value, with: { snapshot in
            if isEvent {
                // TODO: we actually have to keep the songs we've already played around so Deezer doesn't get confused
                // about the indexes
                self.tracks = Event(snapshot: snapshot).sortedTracks()
            } else {
                self.tracks = Playlist(snapshot: snapshot).sortedTracks()
                
                // TODO: If the track index has changed, reset currentIndex
                // DeezerSession.sharedInstance.player?.currentTrack.identifier()
            }
        })
    }
    
    public convenience init(playlist path: String, startIndex: Int?) {
        // TODO: startIndex
        
        self.init(isEvent: false, path: path)
    }
    
    public convenience init(event path: String) {
        self.init(isEvent: true, path: path)
    }
    
    func destroy() {
        if let ref = playableRef, let handle = playableHandle {
            ref.removeObserver(withHandle: handle)
        }
    }
    
    func getTrackFor(dzrId: String) -> Track? {
        // TODO: optimize for events?
        
        if let tracks = self.tracks {
            for track in tracks {
                if track.deezerId == dzrId {
                    return track
                }
            }
        }
        
        return nil
    }
    
    // MARK: DZRObjectList
    
    override func object(at index: UInt, with manager: DZRRequestManager!, callback: ((Any?, Error?) -> Void)!) {
        let track = self.tracks?[Int(index)]
        
        DZRTrack.object(withIdentifier: track?.deezerId, requestManager: DZRRequestManager.default(), callback: {(
            _ trackObject: Any?, _ error: Error?) -> Void in
            if let trackObject = trackObject as? DZRTrack {
                callback(trackObject, nil)
            } else {
                callback(nil, error)
            }
        })
    }
    
    // these two object functions I've defined because I don't know if Deezer uses them...
    override func objects(at indexes: IndexSet!, with manager: DZRRequestManager!, callback: (([Any]?, Error?) -> Void)!) {
        print("Don't use this one, silly Deezer! (objects() in MusicController)")
    }
    
    override func allObjects(with manager: DZRRequestManager!, callback: (([Any]?, Error?) -> Void)!) {
        print("Don't use this one, silly Deezer! (allObjects() in MusicController)")
    }
    
    override func count() -> UInt {
        if let count = tracks?.count {
            return UInt(count)
        }
        
        return 0
    }
}
