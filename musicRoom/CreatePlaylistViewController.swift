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
        } else if DeezerSession.sharedInstance.currentUser == nil {
            print("go login")
            return
        }

        DeezerSession.sharedInstance.currentUser?.createPlaylist(self.name.text, containingTracks: nil, with: DZRRequestManager.default(), callback: { playlist, error in
            if error != nil {
                print("something has gone horribly wrong with Deezer, no playlist was created")
            }
//            print("error", error)
//            print("playlist", playlist)
//            print(playlist?.identifier())
            if let currentUser = FIRAuth.auth()?.currentUser?.uid {
                let userRef = FIRDatabase.database().reference(withPath: "users/" + currentUser)
                
                var playlistRef : FIRDatabaseReference
                if self.publicOption.isOn {
                    playlistRef = FIRDatabase.database().reference(withPath: "playlists/public")
                } else {
                    playlistRef = FIRDatabase.database().reference(withPath: "playlists/private")
                }
                
                let newPlaylistRef = playlistRef.childByAutoId()
                let playlist = Playlist(name: self.name.text!, createdBy: (FIRAuth.auth()?.currentUser?.uid)!, deezerId: (playlist?.identifier())! ,privateAccess: true)
                newPlaylistRef.setValue(playlist.toAnyObject())
                
                print(newPlaylistRef.key)
                
                userRef.child("myPlaylists/" + newPlaylistRef.key).setValue(self.name.text)
                
                self.performSegue(withIdentifier: "unwindToPlaylists", sender: self)
            }
        })

        
    }
}
