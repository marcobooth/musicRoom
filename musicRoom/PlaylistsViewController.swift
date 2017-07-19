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
    
    @IBOutlet weak var tableView: UITableView!
    var publicPlaylists: [(uid: String, name: String)]?
    var privatePlaylists: [(uid: String, name: String)]?
    var selectedPlaylist: (uid: String, name: String, publicOrPrivate: String)?
    
    var userRef: DatabaseReference?
    var publicPlaylistRef: DatabaseReference?
    var userHandle: UInt?
    var publicPlaylistHandle: UInt?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.userRef = Database.database().reference(withPath: "users/" + (Auth.auth().currentUser?.uid)!)
        self.publicPlaylistRef = Database.database().reference(withPath: "playlists/public")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        userHandle = self.userRef?.observe(.value, with: { snapshot in
            var playlists = [(uid: String, name: String)]()
            
            let user = User(snapshot: snapshot)
            if let userPlaylists = user.playlists {
                for playlist in userPlaylists {
                    playlists.append((uid: playlist.key, name: playlist.value))
                }
            }
            
            self.privatePlaylists = playlists
            self.tableView.reloadData()
        })
        
        publicPlaylistHandle = self.publicPlaylistRef?.observe(.value, with: { snapshot in
            var playlists = [(uid: String, name: String)]()
            
            for snap in snapshot.children {
                let playlist = Playlist(snapshot: snap as! DataSnapshot)
                playlists.append((uid: "public/" + (playlist.ref?.key)!, name: playlist.name))
            }
            
            self.publicPlaylists = playlists
            self.tableView.reloadData()
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if let handle = userHandle {
            self.userRef?.removeObserver(withHandle: handle)
        }
        if let handle = publicPlaylistHandle {
            self.publicPlaylistRef?.removeObserver(withHandle: handle)
        }
    }
    
    @IBAction func unwindToPlaylists(segue: UIStoryboardSegue) {
        print("Back on the playlist list page")
    }
}

extension PlaylistsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Private playlists"
        } else if section == 1 {
            return "Public playlists"
        }

        return nil
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let playlists = playlistsForSection(section: section) {
            return playlists.count
        }
        
        return 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "playlistCell", for: indexPath)
        
        let playlists = playlistsForSection(section: indexPath.section)

        if let playlists = playlists, playlists.count > 0 {
            cell.textLabel?.text = playlists[indexPath.row].1
        } else {
            if indexPath.section == 0 {
                cell.textLabel?.text = "No private playlists yet..."
            } else if indexPath.section == 1 {
                cell.textLabel?.text = "No public playlists yet..."
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyle.none
        }
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        var playlists: [(uid: String, name: String)]?
        
        if indexPath.section == 0 {
            playlists = self.privatePlaylists
        } else if indexPath.section == 1 {
            playlists = self.publicPlaylists
        }
        
        if let playlists = playlists {
            let playlist = playlists[indexPath.row]
            let publicOrPrivate = indexPath.section == 0 ? "private" : "public"

            self.selectedPlaylist = (playlist.uid, playlist.name, publicOrPrivate)
        }
        
        self.performSegue(withIdentifier: "showPlaylist", sender: self)
    }
    
    private func playlistsForSection(section: Int) -> [(uid: String, name: String)]? {
        if section == 0 {
            return self.privatePlaylists
        } else if section == 1 {
            return self.publicPlaylists
        }
        
        return nil
    }
}

extension PlaylistsViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let showSegue = segue.destination as? ShowPlaylistViewController, let selected = self.selectedPlaylist {
            showSegue.publicOrPrivate = selected.publicOrPrivate
            showSegue.playlistId = selected.uid
            showSegue.playlistName = selected.name
        }
    }
}
