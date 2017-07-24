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
    
    // MARK: lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nowPlayingText.text = self.NOTHING_PLAYING_TEXT
        DeezerSession.sharedInstance.setUp(playerDelegate: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if DeezerSession.sharedInstance.deezerPlayer?.isPlaying() == true {
            self.changeStatePlayPauseButton(newState: "play")
        } else if DeezerSession.sharedInstance.deezerPlayer?.isReady() == true {
            self.changeStatePlayPauseButton(newState: "pause")
        } else {
            self.changeStatePlayPauseButton(newState: nil)
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
    
    func changeStatePlayPauseButton(newState : String?) {
        print("newState", newState)
        if newState == "play" {
            self.playPauseButton.setImage(UIImage(named: "pause"), for: .normal)
            self.playPauseButton.tag = 1
            self.playPauseButton.isEnabled = true
        } else if newState == "pause" {
            self.playPauseButton.setImage(UIImage(named: "play"), for: .normal)
            self.playPauseButton.tag = 0
            self.playPauseButton.isEnabled = true
        } else {
            self.playPauseButton.setImage(UIImage(named: "play"), for: .normal)
            self.playPauseButton.isEnabled = false
        }
    }
    
    // MARK: action
    
    @IBAction func playPause(_ sender: UIButton) {
        if self.playPauseButton.tag == 0 {
            print("play action")
            DeezerSession.sharedInstance.controller?.play()
        } else {
            print("pause action")
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
