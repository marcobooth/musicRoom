//
//  MusicBarViewController.swift
//  musicRoom
//
//  Created by Teo FLEMING on 6/27/17.
//  Copyright © 2017 Marco BOOTH. All rights reserved.
//

import UIKit

class MusicBarViewController: UIViewController, DZRPlayerDelegate {

    @IBOutlet private weak var nowPlayingText: UILabel!
    
    private var controller: MusicController?
    
    public var embeddedViewController: UIViewController?
    public var deviceId: String?
    
    private let NOTHING_PLAYING_TEXT = "Nothing playing... yet!"
    
    // MARK: lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DeezerSession.sharedInstance.deezerConnect = DeezerConnect(appId: "238082", andDelegate: DeezerSession.sharedInstance)
        DeezerSession.sharedInstance.setUp()
        DeezerSession.sharedInstance.player?.delegate = self
        
        // you should never actually be able to see this text, but just in case...
        self.nowPlayingText.text = "Getting instance ID..."
        InstanceID.instanceID().getID(handler: { (instanceId, error) in
            self.nowPlayingText.text = self.NOTHING_PLAYING_TEXT
            self.deviceId = instanceId
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        controller?.destroy()
    }
    
    // MARK: public functions
    
    public func setMusic(toPlaylist path: String, startingAt startIndex: Int?) {
        print("setMusic:", path, "at", startIndex as Any)
        
        let oldController = self.controller
        self.controller = MusicController(playlist: path, startIndex: startIndex)
        
        oldController?.destroy()
    }
    
    public func setMusic(toEvent path: String) {
        print("setMusic:", path)
        
        let oldController = self.controller
        self.controller = MusicController(event: path)
        
        oldController?.destroy()
    }
    
    public func clearMusic() {
        self.controller?.destroy()
        self.controller = nil
        
        self.nowPlayingText.text = self.NOTHING_PLAYING_TEXT
    }
    
    // MARK: DZRPlayerDelegate
    
    func player(_ player: DZRPlayer, didStartPlaying: DZRTrack) {
        // we could do an API call here to get the name, but I'm going to look through the entire list instead because it's probably faster at this point
        // (playlists are going to be less than 100 songs for the foreseeable future ;] )
        let track = controller?.getTrackFor(dzrId: didStartPlaying.identifier())
        
        if let track = track {
            self.nowPlayingText.text = "\(track.name) by \(track.creator)"
        } else {
            self.nowPlayingText.text = "Couldn't get track info"
        }
    }
    
    // MARK: segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "musicBarEmbed" {
            self.embeddedViewController = segue.destination
        }
    }
}

extension UIViewController {
    func getMusicBarVC() -> MusicBarViewController? {
        if let parent = self.parent {
            if let musicBarVC = parent as? MusicBarViewController {
                return musicBarVC
            }
            
            return parent.getMusicBarVC()
        }
        
        return nil
    }
}
