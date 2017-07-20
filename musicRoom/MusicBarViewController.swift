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
    
    private var controller: MusicController?
    
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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        controller?.destroy()
    }
    
    // MARK: DZRPlayerDelegate
    
    func didStartPlaying(track: Track?) {
        if let track = track {
            self.nowPlayingText.text = "\(track.name) by \(track.creator)"
        } else {
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
