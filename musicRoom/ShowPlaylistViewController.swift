//
//  ShowPlaylistViewController.swift
//  musicRoom
//
//  Created by Marco BOOTH on 6/12/17.
//  Copyright © 2017 Marco BOOTH. All rights reserved.
//

import UIKit

class ShowPlaylistViewController: UIViewController {

    var playlist: Playlist?
    var playlistId: String?
    var publicOrPrivate: String?
    var playlistName: String?
    var tracks: [PlaylistTrack] = []

    var playlistRef: DatabaseReference?
    var playlistHandle: UInt?
    var firebasePlaylistPath: String?

    @IBOutlet weak var addFriendsButton: UIButton!

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = playlistName

        if let publicOrPrivate = publicOrPrivate, let playlistId = self.playlistId {
            self.firebasePlaylistPath = "playlists/\(publicOrPrivate)/\(playlistId)"
            
            if let path = self.firebasePlaylistPath {
                self.playlistRef = Database.database().reference(withPath: path)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.tracks = []

        self.playlistHandle = playlistRef?.observe(.value, with: { snapshot in
            let playlist = Playlist(snapshot: snapshot)
            self.playlist = playlist
            self.tracks = playlist.sortedTracks()
            
            self.tableView.reloadData()
            if self.playlist?.userIds == nil || self.playlist?.createdBy != Auth.auth().currentUser?.uid {
                self.addFriendsButton.isEnabled = false
            }
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
        if let path = self.firebasePlaylistPath {
            if let destination = segue.destination as? SongSearchViewController {
                destination.firebasePath = path
                destination.from = "playlist"
            } else if let destination = segue.destination as? InviteFriendsViewController {
                destination.firebasePath = path
                destination.from = "playlist"
                destination.name = playlistName
            }
        }
    }
    
    @IBAction func shuffleMusic(_ sender: UIButton) {
        if let musicBarVC = getMusicBarViewController(), let path = firebasePlaylistPath {
            musicBarVC.setMusic(toPlaylist: path, startingAt: nil)
        }
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
        if let musicBarVC = getMusicBarViewController(), let path = firebasePlaylistPath {
            musicBarVC.setMusic(toPlaylist: path, startingAt: indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete, let ref = playlistRef {
            ref.child("/tracks/\(self.tracks[indexPath.row].trackKey)").removeValue()
        }
    }
}
