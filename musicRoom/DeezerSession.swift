//
//  DeezerSession.swift
//  musicRoom
//
//  Created by Marco BOOTH on 6/13/17.
//  Copyright © 2017 Marco BOOTH. All rights reserved.
//

import Foundation

class DeezerSession : NSObject, DeezerSessionDelegate, DZRPlayerDelegate {
    
    static let sharedInstance = DeezerSession()
    
    var deezerConnect : DeezerConnect?
    var player: DZRPlayer?
    var currentUser: DZRUser?
    
    func setUp() {
        DZRRequestManager.default().dzrConnect = self.deezerConnect
        self.player = DZRPlayer(connection: self.deezerConnect)
        self.player?.delegate = self
    }
    
    func deezerDidLogin() {
        print("did login")
        DZRUser.object(withIdentifier: "me", requestManager:DZRRequestManager.default(), callback: {(_ objs: Any?, _ error: Error?) -> Void in
            if let user = objs as? DZRUser {
                self.currentUser = user
            }
        })
    }

    func deezerDidLogout() {
        print("did logout")
    }
    
    func deezerDidNotLogin(cancelled: Bool) {
        print("did not login")
    }
}
