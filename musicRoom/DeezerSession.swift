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
    
    var deezerConnect: DeezerConnect?
    var deezerPlayer: DZRPlayer?
    var currentUser: DZRUser?
    var playerDelegate: PlayerDelegate?
    
    var controller: MusicController?
    
    public var deviceId: String?
    
    func setUp(playerDelegate: PlayerDelegate) {
        print("Setting up deezer")

        self.playerDelegate = playerDelegate
        
        self.deezerConnect = DeezerConnect(appId: "238082", andDelegate: DeezerSession.sharedInstance)
        DZRRequestManager.default().dzrConnect = self.deezerConnect
        self.deezerPlayer = DZRPlayer(connection: self.deezerConnect)
        self.deezerPlayer?.delegate = self
        
        InstanceID.instanceID().getID(handler: { (instanceId, error) in
            self.deviceId = instanceId
        })
    }
    
    // MARK: login, logout
    
    func deezerDidLogin() {
        print("Logged into Deezer")
        
        DZRUser.object(withIdentifier: "me", requestManager:DZRRequestManager.default(), callback: {(_ objs: Any?, _ error: Error?) -> Void in
            if let user = objs as? DZRUser {
                self.currentUser = user
            }
        })
        
        if let topVC = UIApplication.topViewController(), let settingsVC = topVC as? SettingsTableViewController {
            settingsVC.updateAccountsView()
        }
    }

    func deezerDidLogout() {
        print("Logged out of Deezer")
    }
    
    func deezerDidNotLogin(cancelled: Bool) {
        print("Didn't log into Deezer")
    }
    
    // MARK: setting the music
    
    public func setMusic(toPlaylist path: String, startingAt startIndex: Int?) {
        print("setMusic:", path, "at", startIndex as Any)
        
        self.controller = PlaylistController(playlist: path, startIndex: startIndex, takeOverFrom: self.controller)
    }
    
    public func setMusic(toEvent path: String) {
        print("setMusic:", path)
        
        self.controller = EventController(event: path, takeOverFrom: self.controller)
    }
    
    public func clearMusic() {
        self.controller?.destroy()
        self.controller = nil
        
        // Why does deezerPlayer?.stop() not work? I do not know
        self.deezerPlayer?.pause()
        playerDelegate?.changePlayPauseButtonState(to: nil)
        playerDelegate?.didStartPlaying(track: nil)
    }
    
    // MARK: DZRPlayerDelegate
    
    func player(_ player: DZRPlayer, didStartPlaying: DZRTrack) {
        // we could do an API call here to get the name, but I'm going to look through the entire list instead because it's probably faster at this point
        // (playlists are going to be less than 100 songs for the foreseeable future ;] )
        let track = controller?.getTrackFor(dzrId: didStartPlaying.identifier())
        
        playerDelegate?.didStartPlaying(track: track)
    }
}
