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
    var tracks: [Track] = []

    var playlistRef: DatabaseReference?
    var playlistHandle: UInt?
    var firebasePlaylistPath: String?

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = playlistName

        if let playlistId = self.playlistId {
            firebasePlaylistPath = "playlists/private/" + playlistId
            
            if let path = firebasePlaylistPath {
                self.playlistRef = Database.database().reference(withPath: path)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.tracks = []

        self.playlistHandle = playlistRef?.observe(.value, with: { snapshot in
            let playlist = Playlist(snapshot: snapshot)
            
            if let tracks = playlist.tracks {
                self.tracks = tracks
            }
            
            self.tableView.reloadData()
            print("reloading data")
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

    @IBAction func unwindToPlaylist(segue: UIStoryboardSegue) {
        print("I'm back in the playlist bit")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? SearchTableViewController, let path = self.firebasePlaylistPath {
            destination.firebasePlaylistPath = path
        }
    }
    
    @IBAction func shuffleMusic(_ sender: UIButton) {
        print("shuffle not implemented")
//        let trackList = TrackArray()
//        trackList.tracks = self.tracks
//        
//        let tracks = DZRPlayableArray()
//        tracks.setTracks(trackList, error: nil)
//        
//        DeezerSession.sharedInstance.player?.play(tracks)
    }
}

extension ShowPlaylistViewController: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count 
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("TrackTableViewCell", owner: nil, options: nil)?.first as! TrackTableViewCell
        cell.track = self.tracks[indexPath.row]
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        print("selected:", indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
}
