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
    
    private var playablePath: String?
    private var refPath: String?
    private var ref: DatabaseReference?
    private var playableHandle: UInt?
    
    private var tracks: [Track] = []
    private var currentIndex: Int = 0
    private var shuffle: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DeezerSession.sharedInstance.deezerConnect = DeezerConnect(appId: "238082", andDelegate: DeezerSession.sharedInstance)
        DeezerSession.sharedInstance.setUp()
        DeezerSession.sharedInstance.player?.delegate = self

        self.updatePlayable()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.updatePlayable()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if let ref = ref, let handle = playableHandle {
            ref.removeObserver(withHandle: handle)
        }
    }
    
    private func updatePlayable() {
        if let playablePath = playablePath {
            if refPath != playablePath {
                if let handle = self.playableHandle {
                    ref?.removeObserver(withHandle: handle)
                    self.playableHandle = nil
                }
                
                refPath = playablePath
                print("creating database with ref:", playablePath)
                ref = Database.database().reference(withPath: playablePath)
            }
            
            // if we should be playing something, go about and get that going
            if let ref = ref {
                playableHandle = ref.observe(.value, with: { snapshot in
                    // TODO: figure out how to tell playlists from events
                    let playlist = Playlist(snapshot: snapshot)
                    self.tracks = playlist.sortedTracks()
                    
                    // XXX: this is super hacky
                    self.tracks = Array(self.tracks.dropFirst(self.currentIndex))
                    
                    // TODO: If the track index has changed, reset currentIndex
                    // DeezerSession.sharedInstance.player?.currentTrack.identifier()
                    
                    let trackList = TrackList(tracks: self.tracks)
                    
                    let tracks = DZRPlayableArray()
                    tracks.setTracks(trackList, error: nil)
                    DeezerSession.sharedInstance.player?.play(tracks)
                })
            }
        }
    }
    
    public func setMusic(toPlaylist path: String, startingAt startIndex: Int?) {
        print("setMusic:", path, "at", startIndex as Any)
        
        self.playablePath = path
        if let index = startIndex {
            self.currentIndex = index
        }

        updatePlayable()
    }
    
    func player(_ player: DZRPlayer, didStartPlaying: DZRTrack) {
        let startedPlayingId = didStartPlaying.identifier()
        print("Started playing", startedPlayingId as Any)
        
        // we could do an API call here to get the name, but I'm going to look through the entire list instead because it's probably faster at this point (playlists are going to be less than 100 songs for the foreseeable future ;] )
        for track in self.tracks {
            if track.deezerId == startedPlayingId {
                self.nowPlayingText.text = track.name + " by " + track.creator
            }
        }
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
