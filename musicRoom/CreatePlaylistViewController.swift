//
//  CreatePlaylistViewController.swift
//  musicRoom
//
//  Created by Marco BOOTH on 6/12/17.
//  Copyright © 2017 Marco BOOTH. All rights reserved.
//

import UIKit

class CreatePlaylistViewController: UIViewController {
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var publicOption: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func createPlaylist(_ sender: UIButton) {
        print("createPlaylist")
        
        if self.name.text == "" {
            print("please name this something")
            return
        }
        
        if let currentUser = Auth.auth().currentUser?.uid {
            let userRef = Database.database().reference(withPath: "users/" + currentUser)
            
            var playlistRef : DatabaseReference
            if self.publicOption.isOn {
                playlistRef = Database.database().reference(withPath: "playlists/public")
            } else {
                playlistRef = Database.database().reference(withPath: "playlists/private")
            }
            
            let newPlaylistRef = playlistRef.childByAutoId()
            let playlist = Playlist(name: self.name.text!, userId: (Auth.auth().currentUser?.uid)!)
            
            if self.publicOption.isOn {
                newPlaylistRef.setValue(playlist.toPublicObject())
            } else {
                newPlaylistRef.setValue(playlist.toPrivateObject())
                userRef.child("playlists/" + newPlaylistRef.key).setValue(self.name.text)
            }
            
            self.performSegue(withIdentifier: "unwindToPlaylists", sender: self)
        }
    }
}
