//
//  CreatePlaylistTableViewController.swift
//  musicRoom
//
//  Created by Marco BOOTH on 7/19/17.
//  Copyright © 2017 Marco BOOTH. All rights reserved.
//

import UIKit

class CreatePlaylistTableViewController: UITableViewController, UITextFieldDelegate {
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var publicOption: UISwitch!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        name.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true;
    }
    
    @IBAction func createPlaylist(_ sender: UIButton) {
        
        guard let text = self.name.text, self.name.text != "" else {
            self.showBasicAlert(title: "Invalid name", message: "Please enter a name")
            return
        }
        
        guard let uid = Auth.auth().currentUser?.uid else {
            self.showBasicAlert(title: "Not logged in", message: "You probably shouldn't be reading this error message. How can you not be logged in?")
            return
        }
        
        let playlist = Playlist(name: text, userId: uid)
        let playlistRef = Database.database().reference(withPath: "playlists/" + (self.publicOption.isOn == true ? "public" : "private"))
        let newPlaylistRef = playlistRef.childByAutoId()
        
        if self.publicOption.isOn {
            newPlaylistRef.setValue(playlist.toPublicObject()) { error, _ in
                guard error == nil else { return }
                
                Log.event("created_playlist", parameters: [
                    "playlist_id": newPlaylistRef.key,
                    "playlist_name": playlist.name,
                    "public_or_private": "public",
                ])
            }
        } else {
            let newPrivatePlaylistRef : [String:Any] = [
                "users/\(uid)/playlists/\(newPlaylistRef.key)": text,
                "playlists/private/\(newPlaylistRef.key)": playlist.toPrivateObject()
            ]
            
            let ref = Database.database().reference()
            ref.updateChildValues(newPrivatePlaylistRef, withCompletionBlock: { (error, ref) -> Void in
                if error == nil {
                    Log.event("created_playlist", parameters: [
                        "playlist_id": newPlaylistRef.key,
                        "playlist_name": playlist.name,
                        "public_or_private": "private",
                    ])
                } else {
                    print("Error updating data: \(error.debugDescription)")
                    self.showBasicAlert(title: "Error", message: "This probably means that Firebase denied access")
                }
            })
        }
        
        self.performSegue(withIdentifier: "unwindToPlaylists", sender: self)
    }
}
