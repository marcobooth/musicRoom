//
//  TrackArray.swift
//  musicRoom
//
//  Created by Teo FLEMING on 6/23/17.
//  Copyright © 2017 Marco BOOTH. All rights reserved.
//

import Foundation

class TrackArray: DZRObjectList {
    var tracks: [(uid: String, name: String)]?
    
    override func object(at index: UInt, with manager: DZRRequestManager!, callback: ((Any?, Error?) -> Void)!) {
        let track = self.tracks?[Int(index)]
        
        DZRTrack.object(withIdentifier: track?.uid, requestManager: DZRRequestManager.default(), callback: {(
            _ trackObject: Any?, _ error: Error?) -> Void in
            if let trackObject = trackObject as? DZRTrack {
                callback(trackObject, nil)
            } else {
                callback(nil, error)
            }
        })
    }
    
    override func objects(at indexes: IndexSet!, with manager: DZRRequestManager!, callback: (([Any]?, Error?) -> Void)!) {
        print("Don't use this one, silly Deezer! (objects() in TrackList)")
        exit(1)
    }
    
    override func allObjects(with manager: DZRRequestManager!, callback: (([Any]?, Error?) -> Void)!) {
        print("Don't use this one, silly Deezer! (allObjects() in TrackList)")
        exit(1)
    }
    
    override func count() -> UInt {
        if let count = tracks?.count {
            return UInt(count)
        }
        
        return 0
    }
}
