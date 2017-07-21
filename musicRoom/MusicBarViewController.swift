//
//  MusicBarViewController.swift
//  musicRoom
//
//  Created by Teo FLEMING on 6/27/17.
//  Copyright © 2017 Marco BOOTH. All rights reserved.
//

import UIKit

class MusicBarViewController: UIViewController, PlayerDelegate {

    @IBOutlet private weak var nowPlayingText: UILabel!
    
    public var embeddedViewController: UIViewController?
    public var deviceId: String?
    
    private let NOTHING_PLAYING_TEXT = "Nothing playing... yet!"
    
    // MARK: lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DeezerSession.sharedInstance.setUp(playerDelegate: self)
        
        // you should never actually be able to see this text, but just in case...
        self.nowPlayingText.text = "Getting instance ID..."
        InstanceID.instanceID().getID(handler: { (instanceId, error) in
            self.nowPlayingText.text = self.NOTHING_PLAYING_TEXT
            self.deviceId = instanceId
        })
    }
    
    // MARK: DZRPlayerDelegate
    
    func didStartPlaying(track: Track?) {
        print("did start playing in the music bar view controller", track)
        
        if let track = track {
            self.nowPlayingText.text = "\(track.name) by \(track.creator)"
        } else {
            print("setting now playing text to the default text")
            self.nowPlayingText.text = NOTHING_PLAYING_TEXT
        }
    }
    
    // MARK: segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "musicBarEmbed" {
            self.embeddedViewController = segue.destination
        }
    }
}
