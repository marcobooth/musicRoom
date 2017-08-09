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
                
                if let snap = snap as? DataSnapshot {
                    let playlist = Playlist(snapshot: snap)
                    if let ref = playlist.ref {
                        playlists.append((uid: ref.key, name: playlist.name))
                    }
                }
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
        if let playlists = playlistsForSection(section: section), playlists.count > 0 {
            return playlists.count
        }
        
        return 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "playlistCell", for: indexPath)
        
        let playlists = playlistsForSection(section: indexPath.section)

        if let playlists = playlists, playlists.count > 0 {
            cell.textLabel?.text = playlists[indexPath.row].1
            
            cell.selectionStyle = UITableViewCellSelectionStyle.default
            cell.textLabel?.textColor = UIColor.black
        } else {
            if playlists == nil {
                cell.textLabel?.text = "Loading..."
            } else {
                if indexPath.section == 0 {
                    cell.textLabel?.text = "No private playlists yet..."
                } else if indexPath.section == 1 {
                    cell.textLabel?.text = "No public playlists yet..."
                }
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.textLabel?.textColor = UIColor.gray
        }
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let playlists = playlistsForSection(section: indexPath.section), playlists.count > 0 {
            let playlist = playlists[indexPath.row]
            let publicOrPrivate = indexPath.section == 0 ? "private" : "public"

            self.selectedPlaylist = (playlist.uid, playlist.name, publicOrPrivate)
            
            self.performSegue(withIdentifier: "showPlaylist", sender: self)
        }
    }
    
    private func playlistsForSection(section: Int) -> [(uid: String, name: String)]? {
        if section == 0 {
            return self.privatePlaylists
        } else if section == 1 {
            return self.publicPlaylists
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if let playlists = playlistsForSection(section: indexPath.section) {
            return playlists.count > 0
        }
        
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            if indexPath.section == 0, let privatePlaylists = self.privatePlaylists {
                let privateRef = Database.database().reference(withPath: "playlists/private")
                privateRef.child(privatePlaylists[indexPath.row].uid).observeSingleEvent(of: .value, with: { snapshot in
                    
                    let playlist = Playlist(snapshot: snapshot)
                    if playlist.createdBy != Auth.auth().currentUser?.uid {
                        tableView.setEditing(false, animated: true)
                        
                        self.showBasicAlert(title: "You can't delete this playlist", message: "This playlist is not yours.")
                    } else {
                        var userPlaylists: [AnyHashable: Any] = [
                            "playlists/private/\(privatePlaylists[indexPath.row].uid)": NSNull()
                        ]
                        
                        if let userIds = playlist.userIds {
                            for user in userIds {
                                userPlaylists["users/\(user.key)/playlists/\(privatePlaylists[indexPath.row].uid)"] = NSNull()
                            }
                        }
                        
                        Database.database().reference().updateChildValues(userPlaylists)
                    }
                })
            } else if indexPath.section == 1, let publicPlaylists = self.publicPlaylists, let publicRef = self.publicPlaylistRef {
                publicRef.child(publicPlaylists[indexPath.row].uid).observeSingleEvent(of: .value, with: { snapshot in

                    let playlist = Playlist(snapshot: snapshot)
                    if playlist.createdBy != Auth.auth().currentUser?.uid {
                        tableView.setEditing(false, animated: true)
                        
                        self.showBasicAlert(title: "You can't delete this playlist", message: "This playlist is not yours.")
                    } else {
                       publicRef.child(publicPlaylists[indexPath.row].uid).removeValue()
                    }
                })
                
            }
        }
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
