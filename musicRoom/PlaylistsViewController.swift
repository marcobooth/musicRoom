//
//  PlaylistsViewController.swift
//  musicRoom
//
//  Created by Marco BOOTH on 6/11/17.
//  Copyright © 2017 Marco BOOTH. All rights reserved.
//

import UIKit
import Firebase

class PlaylistsViewController: UIViewController {
    
    @IBOutlet weak var selector: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    var playlistsToShow = [(uid: String, name: String)]()
    var publicPlaylists = [(uid: String, name: String)]()
    var privatePlaylists = [(uid: String, name: String)]()
    var selectedPlaylist : (uid: String, name: String)?
    
    
    var userRef: DatabaseReference!
    var publicPlaylistRef: DatabaseReference!
    var handleUser: UInt!
    var handlePublicPlaylist: UInt!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.userRef = Database.database().reference(withPath: "users/" + (Auth.auth().currentUser?.uid)!)
        self.publicPlaylistRef = Database.database().reference(withPath: "playlists/public")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        handleUser = self.userRef.observe(.value, with: { snapshot in
            var playlists = [(uid: String, name: String)]()
            
            let user = User(snapshot: snapshot)
            if let userPlaylists = user.playlists {
                for playlist in userPlaylists {
                    playlists.append((uid: playlist.key, name: playlist.value))
                }
            }
            
            if let invitedPlaylists = user.invitedPlaylists {
                for playlist in invitedPlaylists {
                    playlists.append((uid: playlist.key, name: playlist.value))
                }
            }
            
            self.privatePlaylists = playlists
            if self.selector.selectedSegmentIndex == 1 {
                self.playlistsToShow = self.privatePlaylists
            }
            self.tableView.reloadData()
        })
        
        handlePublicPlaylist = self.publicPlaylistRef.observe(.value, with: { snapshot in
            var playlists = [(uid: String, name: String)]()
            
            for snap in snapshot.children {
                let playlist = Playlist(snapshot: snap as! DataSnapshot)
                playlists.append((uid: "public/" + (playlist.ref?.key)!, name: playlist.name))
            }
            self.publicPlaylists = playlists
            if self.selector.selectedSegmentIndex == 0 {
                self.playlistsToShow = self.publicPlaylists
            }
            self.tableView.reloadData()
        })
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        self.userRef.removeObserver(withHandle: handleUser)
        self.publicPlaylistRef.removeObserver(withHandle: handlePublicPlaylist)
    }
    
    
    @IBAction func selectorChange(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            playlistsToShow = publicPlaylists
            self.tableView.reloadData()
        } else if sender.selectedSegmentIndex == 1 {
            playlistsToShow = privatePlaylists
            self.tableView.reloadData()
        }
    }
    
    @IBAction func unwindToPlaylists(segue: UIStoryboardSegue) {
        print("I'm back")
    }
}

extension PlaylistsViewController: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.playlistsToShow.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "playlistCell", for: indexPath)
        
        cell.textLabel?.text = self.playlistsToShow[indexPath.row].1
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        self.selectedPlaylist = self.playlistsToShow[indexPath.row]
        self.performSegue(withIdentifier: "showPlaylist", sender: self)
    }
}

extension PlaylistsViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let showSegue = segue.destination as? ShowPlaylistViewController {
            showSegue.playlistId = self.selectedPlaylist?.uid
            showSegue.playlistName = self.selectedPlaylist?.name
        }
    }
}
