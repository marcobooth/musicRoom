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
    @IBOutlet weak var username: UILabel!
    var playlistNames = [(uid: String, name: String)]()
    var selectedPlaylist : (uid: String, name: String)?
    let userRef = FIRDatabase.database().reference(withPath: "users/" + (FIRAuth.auth()?.currentUser?.uid)!)
    let privatePlaylistRef = FIRDatabase.database().reference(withPath: "playlists/private")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        DeezerSession.sharedInstance.deezerConnect = DeezerConnect(appId: "238082", andDelegate: DeezerSession.sharedInstance)
        DeezerSession.sharedInstance.setUp()
        
        self.username.text = FIRAuth.auth()?.currentUser?.uid
        
        self.userRef.observe(.value, with: { snapshot in
            var playlists = [(uid: String, name: String)]()
            
            let user = User(snapshot: snapshot)
            print(user)
            print(snapshot)
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

            self.playlistNames = playlists
            self.tableView.reloadData()
        })
    }
    
    @IBAction func unwindToPlaylists(segue: UIStoryboardSegue) {
        print("I'm back")
    }
}

extension PlaylistsViewController: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.playlistNames.count + 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "playlistCell", for: indexPath)
        if indexPath.row == 0 {
            cell.textLabel?.text = "Create Playlist"
        } else {
            cell.textLabel?.text = self.playlistNames[indexPath.row - 1].1
        }
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            self.performSegue(withIdentifier: "createPlaylistSegue", sender: self)
        } else {
            self.selectedPlaylist = self.playlistNames[indexPath.row - 1]
            self.performSegue(withIdentifier: "showPlaylist", sender: self)
        }

    }
}

extension PlaylistsViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let showSegue = segue.destination as? ShowPlaylistViewController {
            showSegue.playlistId = self.selectedPlaylist?.uid
            showSegue.playlistName = self.selectedPlaylist?.name
            print("now in here")
        } else {
            print("this failed")
            print(type(of: segue.destination))
        }
    }
}
