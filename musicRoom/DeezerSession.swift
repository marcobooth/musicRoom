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
//        print("currentUser", self.currentUser)
        print("did login")
        DZRUser.object(withIdentifier: "me", requestManager:DZRRequestManager.default(), callback: {(_ objs: Any?, _ error: Error?) -> Void in
            if let user = objs as? DZRUser {
                self.currentUser = user
//                print("currentUser", self.currentUser)
            }
        })
//        print(self.deezerConnect?.accessToken)
//        print(self.deezerConnect?.userId)
//        print(self.deezerConnect?.expirationDate)
    }
    
    func search() {
        //        DZRTrack.object(withIdentifier: "3135556", requestManager: DZRRequestManager.default(), callback: {(_ objs: Any?, _ error: Error?) -> Void in
        //                print("im in this thing")
        //                objectList.add
        //                DeezerSession.sharedInstance.player?.play(objs as! DZRPlayable!, at: 0)
        //        })
        //        DZRObject.search(for: DZRSearchType.track, withQuery: "californication", requestManager: DZRRequestManager.default(), callback: {(_ results: DZRObjectList?, _ error: Error?) -> Void in
        //            results!.allObjects(with: DZRRequestManager.default(), callback: {(_ objs: [Any]?, _ error: Error?) -> Void in
        //                print(objs?[0])
        //                print(type(of: objs?[0]))
        //                DeezerSession.sharedInstance.player?.play(objs as! DZRPlayable!, at: 0)
        //                //                for obj in objs! {
        //                //                    print(obj)
        //                //                }
        //            })
        //        })
    }

    func deezerDidLogout() {
        print("did logout")
    }
    
    func deezerDidNotLogin(cancelled: Bool) {
        print("did not login")
    }
}
