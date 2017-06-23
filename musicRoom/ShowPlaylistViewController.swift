//
//  ShowPlaylistViewController.swift
//  musicRoom
//
//  Created by Marco BOOTH on 6/12/17.
//  Copyright © 2017 Marco BOOTH. All rights reserved.
//

import UIKit

class ShowPlaylistViewController: UIViewController {

    var playlistId: String?
    var playlistName: String?
    var tracks: [(uid: String, name: String)] = []

    var playlistRef: FIRDatabaseReference?
    var playlistHandle: UInt?

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = playlistName

        if let playlistId = self.playlistId {
            self.playlistRef = FIRDatabase.database().reference(withPath: "playlists/private/" + playlistId)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.playlistHandle = playlistRef?.observe(.value, with: { snapshot in
            let playlist = Playlist(snapshot: snapshot)
            if let allTracks = playlist.deezerTrackIds {
                for track in allTracks {
                    self.tracks.append((uid: track.key, name: track.value))
                }
            }
            
            self.tableView.reloadData()
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if let playlistHandle = self.playlistHandle {
            playlistRef?.removeObserver(withHandle: playlistHandle)
        }
    }
    
    @IBAction func backToPlaylists(_ sender: UIButton) {
        self.performSegue(withIdentifier: "backToPlaylists", sender: self)
    }
    
    @IBAction func addSong(_ sender: UIButton) {
        let privatePlaylistRef = FIRDatabase.database().reference(withPath: "playlists/private/" + self.playlistId! + "/deezerTrackIds/3135556")
        privatePlaylistRef.setValue("Faster, Stronger")
    }
    
    @IBAction func shuffleMusic(_ sender: UIButton) {
        let trackList = TrackArray()
        trackList.tracks = self.tracks
        
        let tracks = DZRPlayableArray()
        tracks.setTracks(trackList, error: nil)
        
        DeezerSession.sharedInstance.player?.play(tracks)
    }
}

extension ShowPlaylistViewController: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count 
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath)
        cell.textLabel?.text = self.tracks[indexPath.row].name
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }
}
