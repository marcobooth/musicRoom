//
//  SearchTableViewController.swift
//  musicRoom
//
//  Created by Teo FLEMING on 6/22/17.
//  Copyright © 2017 Marco BOOTH. All rights reserved.
//

import UIKit

class SearchTableViewController: UITableViewController {
    
    class TrackResults {
        var deezerTracks: DZRObjectList
        
        // NOTE: tracks are populated when the cell is shown with tableView(... cellForRowAt)
        var tracks: [Track?]
        
        init(deezerTracks: DZRObjectList, tracks: [Track?]) {
            self.deezerTracks = deezerTracks
            self.tracks = tracks
        }
    }
    
    let searchController = UISearchController(searchResultsController: nil)
    var currentSearch = ""
    var cachedResults: [String: TrackResults] = [:]
    var firebasePath: String?
    var from: String?
    
    var playlistRef: DatabaseReference?
    var playlistHandle: UInt?
    var latestPlaylist: Playlist?

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        tableView.tableHeaderView = searchController.searchBar

        // removed this because otherwise the segue back to the playlist screen doesn't work
        // definesPresentationContext = true
        
        if let path = self.firebasePath {
            self.playlistRef = Database.database().reference(withPath: path)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.playlistHandle = playlistRef?.observe(.value, with: { snapshot in
            self.latestPlaylist = Playlist(snapshot: snapshot)
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let playlistHandle = self.playlistHandle {
            playlistRef?.removeObserver(withHandle: playlistHandle)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if self.cachedResults[self.currentSearch] != nil {
            return 1
        }
        
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let trackResults = self.cachedResults[self.currentSearch] {
            return trackResults.tracks.count
        }
        
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("TrackTableViewCell", owner: nil, options: nil)?.first as! TrackTableViewCell

        if let trackResults = cachedResults[currentSearch] {
            if let track = trackResults.tracks[indexPath.row] {
                cell.track = track
            } else {
                cell.track = nil
                
                trackResults.deezerTracks.object(at: UInt(indexPath.row), with: DZRRequestManager.default(), callback: { (deezerTrack, getTrackError) in
                    if getTrackError == nil, let deezerTrack = deezerTrack as? DZRTrack {
                        // Now go and get the track information because of COURSE it's not stored in a DZRTrack
                        deezerTrack.playableInfos(with: DZRRequestManager.default(), callback: { (songInfo, error) in
                            if let name = songInfo?["DZRPlayableObjectInfoName"] as? String,
                                let creator = songInfo?["DZRPlayableObjectInfoCreator"] as? String,
                                let duration = songInfo?["DZRPlayableObjectInfoDuration"] as? Int {
                                trackResults.tracks[indexPath.row] = Track(deezerId: deezerTrack.identifier(), name: name, creator: creator, duration: duration)
                                
                                self.tableView.reloadRows(at: [indexPath], with: .fade)
                            }
                        })
                    } else {
                        print("Error grabbing DZRTrack object at index", indexPath.row)
                        print("Error:", getTrackError as Any)
                    }
                })
            }
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let track = cachedResults[currentSearch]?.tracks[indexPath.row], let path = firebasePath {
            let playlistRef = Database.database().reference(withPath: path + "/tracks")
            let newSongRef = playlistRef.childByAutoId()
            
            var trackDict = track.toDict()
            if self.from == "playlist" {
                if let highestOrderNumber = latestPlaylist?.sortedTracks().last?.orderNumber {
                    trackDict["orderNumber"] = highestOrderNumber + 1
                } else {
                    trackDict["orderNumber"] = 0
                }
            }
            
            newSongRef.setValue(trackDict)

            if self.from == "playlist" {
                self.performSegue(withIdentifier: "unwindToPlaylist", sender: self)
            } else {
                self.performSegue(withIdentifier: "unwindToEventTracklist", sender: self)
            }
        }
    }
}

extension SearchTableViewController: UISearchResultsUpdating {
    public func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
    
    func filterContentForSearchText(searchText: String) {
        if cachedResults[searchText] == nil {
            if searchText != "" {
                print("Searching for:", searchText)
                DZRObject.search(for: DZRSearchType.track, withQuery: searchText, requestManager: DZRRequestManager.default(), callback: { (_ results: DZRObjectList?, _ error: Error?) -> Void in
                    guard let results = results, error == nil else {
                        print("Error searching with text:", error as Any)
                        return
                    }
                    
                    print("Got", results.count(), "search results.", searchText)
                    
                    let tracks = [Track?](repeating: nil, count: Int(results.count()))
                    self.cachedResults[searchText] = TrackResults(deezerTracks: results, tracks: tracks)
                    
                    // NOTE: this removes the race condition which would cause the wrong cached results to be displayed if the search changes to a cached result before this callback executes
                    if let latestSearch = self.searchController.searchBar.text {
                        self.currentSearch = latestSearch
                    }
                    
                    self.tableView.reloadData()
                })
            }
        } else {
            self.currentSearch = searchText
            self.tableView.reloadData()
        }
    }
}
