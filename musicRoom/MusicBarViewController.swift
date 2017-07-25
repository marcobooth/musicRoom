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
    @IBOutlet weak var playPauseButton: UIButton!
    
    public var embeddedViewController: UIViewController?
    
    private let NOTHING_PLAYING_TEXT = "Nothing playing... yet!"
    
    private var isPlaying: Bool?
    
    // MARK: lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nowPlayingText.text = self.NOTHING_PLAYING_TEXT
        DeezerSession.sharedInstance.setUp(playerDelegate: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if DeezerSession.sharedInstance.deezerPlayer?.isPlaying() == true {
            self.changePlayPauseButtonState(to: true)
        } else if DeezerSession.sharedInstance.deezerPlayer?.isReady() == true {
            self.changePlayPauseButtonState(to: false)
        } else {
            self.changePlayPauseButtonState(to: nil)
        }
        
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
    
    func changePlayPauseButtonState(to newState: Bool?) {
        self.isPlaying = newState
        
        DispatchQueue.main.async {
            if newState == true {
                self.playPauseButton.setImage(UIImage(named: "pause"), for: .normal)
                self.playPauseButton.isEnabled = true
            } else if newState == false {
                self.playPauseButton.setImage(UIImage(named: "play"), for: .normal)
                self.playPauseButton.isEnabled = true
            } else {
                self.playPauseButton.setImage(UIImage(named: "play"), for: .normal)
                self.playPauseButton.isEnabled = false
            }
        }
    }
    
    // MARK: action
    
    @IBAction func playPause(_ sender: UIButton) {
        if self.isPlaying == false {
            print("play button")
            DeezerSession.sharedInstance.controller?.play()
        } else {
            print("pause button")
            DeezerSession.sharedInstance.controller?.pause()
        }
    }
    
    // MARK: segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "musicBarEmbed" {
            self.embeddedViewController = segue.destination
        }
    }
}
