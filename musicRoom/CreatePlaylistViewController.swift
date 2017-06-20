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
        if self.name.text == "" {
            print("please name this something")
            return
        }
        
        if let currentUser = FIRAuth.auth()?.currentUser?.uid {
            let userRef = FIRDatabase.database().reference(withPath: "users/" + currentUser)
            
            var playlistRef : FIRDatabaseReference
            if self.publicOption.isOn {
                playlistRef = FIRDatabase.database().reference(withPath: "playlists/public")
            } else {
                playlistRef = FIRDatabase.database().reference(withPath: "playlists/private")
            }
            
            let newPlaylistRef = playlistRef.childByAutoId()
            let playlist = Playlist(name: self.name.text!, userId: (FIRAuth.auth()?.currentUser?.uid)!)
            
            newPlaylistRef.setValue(playlist.toAnyObject())
            
            print(newPlaylistRef.key)
            
            userRef.child("playlists/" + newPlaylistRef.key).setValue(self.name.text)
            
            self.performSegue(withIdentifier: "unwindToPlaylists", sender: self)
        }

    }
}
