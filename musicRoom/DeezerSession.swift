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
    
//    let DEEZER_TOKEN_KEY = "DeezerTokenKey"
//    let DEEZER_EXPIRATION_DATE_KEY = "DeezerExpirationDateKey"
//    let DEEZER_USER_ID_KEY = "DeezerUserId"
//    func retrieveTokenAndExpirationDate() {
//        let standardUserDefaults = UserDefaults.standard
//        deezerConnect?.accessToken = standardUserDefaults.object(forKey: DEEZER_TOKEN_KEY) as! String!
//        deezerConnect?.expirationDate = standardUserDefaults.object(forKey: DEEZER_EXPIRATION_DATE_KEY) as! Date!
//        deezerConnect?.userId = standardUserDefaults.object(forKey: DEEZER_USER_ID_KEY) as! String!
//    }
    
    func setUp() {
        DZRRequestManager.default().dzrConnect = self.deezerConnect
        self.player = DZRPlayer(connection: self.deezerConnect)
        self.player?.delegate = self
    }
    
    func deezerDidLogin() {
        print("did login")
        print("\n")
//        print(self.deezerConnect?.accessToken)
//        print(self.deezerConnect?.userId)
//        print(self.deezerConnect?.expirationDate)
    }
    
    func deezerDidLogout() {
        print("did logout")
    }
    
    func deezerDidNotLogin(cancelled: Bool) {
        print("did not login")
    }
}
