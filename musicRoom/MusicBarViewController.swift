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
    
    private let NOTHING_PLAYING_TEXT = "Nothing playing... yet!"
    
    // MARK: lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nowPlayingText.text = self.NOTHING_PLAYING_TEXT
        DeezerSession.sharedInstance.setUp(playerDelegate: self)
    }
    
    // MARK: PlayerDelegate
    
    func didStartPlaying(track: Track?) {
        DispatchQueue.main.async {
            if let track = track {
                self.nowPlayingText.text = "\(track.name) by \(track.creator)"
            } else {
                self.nowPlayingText.text = self.NOTHING_PLAYING_TEXT
            }
        }
    }
    
    // MARK: segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "musicBarEmbed" {
            self.embeddedViewController = segue.destination
        }
    }
}
