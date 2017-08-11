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
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    @IBAction func editButton(_ sender: UIBarButtonItem) {
        if editButton.title == "Edit" {
            tableView.setEditing(true, animated: true)
            addButton.isEnabled = false
            editButton.title = "Done"
        } else {
            tableView.setEditing(false, animated: true)
            addButton.isEnabled = true
            editButton.title = "Edit"
        }
    }

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
        
        if publicOrPrivate == "public" {
            addFriendsButton.isEnabled = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.tracks = []
        self.tableView.isHidden = true

        self.playlistHandle = playlistRef?.observe(.value, with: { snapshot in
            let playlist = Playlist(snapshot: snapshot)
            self.playlist = playlist
            
            self.tracks = playlist.sortedTracks()
            if self.tracks.count == 0 {
                // in case they delete all the songs while in editing mode
                self.tableView.setEditing(false, animated: true)
                self.addButton.isEnabled = true
                self.editButton.title = "Edit"
                
                self.tableView.isHidden = true
                self.infoLabel.isHidden = false
                self.infoLabel.text = "You haven't added any songs yet!"
                self.editButton.isEnabled = false
            } else {
                self.tableView.isHidden = false
                self.infoLabel.isHidden = true
                self.editButton.isEnabled = true
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
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if let path = firebasePlaylistPath {
            DeezerSession.sharedInstance.setMusic(toPlaylist: path, startingAt: indexPath.row)
        }
        
        return false
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete, let ref = playlistRef {
            if self.tracks[indexPath.row].creator == "Beyoncé" {
                self.showBasicAlert(title: "You can't delete this song", message: "Beyoncé's songs can't be deleted")
            } else {
                let trackId = self.tracks[indexPath.row].trackKey
                
                ref.child("/tracks/\(trackId)").removeValue() { error, _ in
                    Log.event("deleted_track", parameters: [
                        "playlist_id": self.playlistId ?? "undefined",
                        "track_id": trackId,
                    ])
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to toIndexPath: IndexPath) {
        var orderNumber: Double

        if toIndexPath.row == tracks.count - 1 {
            orderNumber = round(tracks[toIndexPath.row].orderNumber + 1)
        } else if toIndexPath.row == 0 {
            orderNumber = round(tracks[toIndexPath.row].orderNumber - 1)
        } else {
            orderNumber = (tracks[toIndexPath.row - 1].orderNumber + tracks[toIndexPath.row].orderNumber) / 2
        }
        if let ref = playlistRef {
            let trackId = tracks[fromIndexPath.row].trackKey
            
            ref.child("tracks/\(trackId)/orderNumber").setValue(orderNumber) { error, _ in
                Log.event("set_track_order_number")
            }
        }
    }
}
