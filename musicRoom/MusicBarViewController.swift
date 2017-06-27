//
//  MusicBarViewController.swift
//  musicRoom
//
//  Created by Teo FLEMING on 6/27/17.
//  Copyright © 2017 Marco BOOTH. All rights reserved.
//

import UIKit

class MusicBarViewController: UIViewController {

    @IBOutlet private weak var nowPlayingText: UILabel!
    
    private var playablePath: String?
    
    private var refPath: String?
    private var ref: DatabaseReference?
    private var handle: UInt?
    
    private var currentIndex: Int = 0
    private var shuffle: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updatePlayable()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updatePlayable()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if let ref = ref, let handle = handle {
            ref.removeObserver(withHandle: handle)
        }
    }
    
    private func updatePlayable() {
        if let playablePath = playablePath {
            if refPath != playablePath {
                if let handle = self.handle {
                    ref?.removeObserver(withHandle: handle)
                    self.handle = nil
                }
                
                refPath = playablePath
                print("creating database with ref:", playablePath)
                ref = Database.database().reference(withPath: playablePath)
            }
            
            // if we should be playing something, go about and get that going
            if let ref = ref {
                print("about to observe ref...")
                handle = ref.observe(.value, with: {
                    print("yop:", $0)
                })
            }
        }
    }
    
    public func setMusic(toPlaylist path: String, startingAt startIndex: Int?) {
        self.playablePath = path
        updatePlayable()
        
        // TODO: I'm here.
        // - figure out how to change the text when the song changes
        // - hook up the music to this thing, which will provide do some cool stuff with arrays and such
        
        //        let trackList = TrackArray()
        //        trackList.tracks = self.tracks
        //
        //        let tracks = DZRPlayableArray()
        //        tracks.setTracks(trackList, error: nil)
        //
        //        DeezerSession.sharedInstance.player?.play(tracks)
    }
}

extension UIViewController {
    func getMusicBarViewController() -> MusicBarViewController? {
        if let parent = self.parent {
            if let musicBarVC = parent as? MusicBarViewController {
                return musicBarVC
            }
            
            return parent.getMusicBarViewController()
        }
        
        return nil
    }
}
