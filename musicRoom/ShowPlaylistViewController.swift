//
//  ShowPlaylistViewController.swift
//  musicRoom
//
//  Created by Marco BOOTH on 6/12/17.
//  Copyright © 2017 Marco BOOTH. All rights reserved.
//

import UIKit

class ShowPlaylistViewController: UIViewController {

    var playlistId: String?
    var playlistName: String?
    var tracks: [(uid: String, name: String)] = []
    let userRef = FIRDatabase.database().reference(withPath: "users/" + (FIRAuth.auth()?.currentUser?.uid)!)
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = playlistName

        if let playlistId = self.playlistId {
            print("Asking for playlist info for:", playlistId)
            let privatePlaylistRef = FIRDatabase.database().reference(withPath: "playlists/private/" + playlistId)
            
            privatePlaylistRef.observe(.value, with: { snapshot in
                let playlist = Playlist(snapshot: snapshot)
                if let allTracks = playlist.deezerTrackIds {
                    for track in allTracks {
                        self.tracks.append((uid: track.key, name: track.value))
                    }
                }
                
                print("tracks", self.tracks)
                self.tableView.reloadData()
            })
        }
    }
    
    @IBAction func backToPlaylists(_ sender: UIButton) {
        self.performSegue(withIdentifier: "backToPlaylists", sender: self)
    }
    
    @IBAction func addSong(_ sender: UIButton) {
        let privatePlaylistRef = FIRDatabase.database().reference(withPath: "playlists/private/" + self.playlistId! + "/deezerTrackIds/3135556")
        privatePlaylistRef.setValue("Faster, Stronger")
    }
    
    @IBAction func shuffleMusic(_ sender: UIButton) {
        let trackList = TrackList()
        trackList.tracks = self.tracks
        
        let tracks = DZRPlayableArray()
        tracks.setTracks(trackList, error: nil)
        
        DeezerSession.sharedInstance.player?.play(tracks)
    }
}

extension ShowPlaylistViewController: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count 
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath)
        cell.textLabel?.text = self.tracks[indexPath.row].name
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }
}

class TrackList: DZRObjectList {
    var tracks: [(uid: String, name: String)]?
    
    override func object(at index: UInt, with manager: DZRRequestManager!, callback: ((Any?, Error?) -> Void)!) {
        let track = self.tracks?[Int(index)]
        
        DZRTrack.object(withIdentifier: track?.uid, requestManager: DZRRequestManager.default(), callback: {(
            _ trackObject: Any?, _ error: Error?) -> Void in
            if let trackObject = trackObject as? DZRTrack {
                callback(trackObject, nil)
            } else {
                callback(nil, error)
            }
        })
    }
    
    override func objects(at indexes: IndexSet!, with manager: DZRRequestManager!, callback: (([Any]?, Error?) -> Void)!) {
        print("Don't use this one, silly Deezer! (objects() in TrackList)")
        exit(1)
    }
    
    override func allObjects(with manager: DZRRequestManager!, callback: (([Any]?, Error?) -> Void)!) {
        print("Don't use this one, silly Deezer! (allObjects() in TrackList)")
        exit(1)
    }
    
    override func count() -> UInt {
        guard let count = tracks?.count else {
            return 0
        }
        
        return UInt(count)
    }
}

//class DZRTrackArray : DZRPlayableIterator {
//    
//    var playlistTracks : [DZRTrack]?
//    var currentTrack : Int
//    
//    init() {
//        playlistTracks = nil
//        currentTrack = 0
//    }
//    
//    func current(with requestManager: DZRRequestManager!, callback: DZRTrackFetchingCallback!) {
//        print("i am in current")
//    }
//
//    func next(with requestManager: DZRRequestManager!, callback: DZRTrackFetchingCallback!) {
//        print("i am in next")
//    }
//}
