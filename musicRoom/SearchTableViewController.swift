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
        var tracks: DZRObjectList
        
        // NOTE: trackIds and songNames are populated when the cell is shown with tableView(... cellForRowAt)
        var trackIds: [String?]
        var songNames: [String?]
        
        init(tracks: DZRObjectList, trackIds: [String?], songNames: [String?]) {
            self.tracks = tracks
            self.trackIds = trackIds
            self.songNames = songNames
        }
    }
    
    let searchController = UISearchController(searchResultsController: nil)
    var currentSearch = ""
    var cachedResults: [String: TrackResults] = [:]
    var firebasePlaylistPath: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        tableView.tableHeaderView = searchController.searchBar

        // removed this because otherwise the segue back to the playlist screen doesn't work
        // definesPresentationContext = true
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
            return trackResults.songNames.count
        }
        
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        cell.detailTextLabel?.text = ""
        cell.textLabel?.text = "Loading..."

        if let trackResults = cachedResults[currentSearch] {
            if let songName = trackResults.songNames[indexPath.row] {
                cell.textLabel?.text = songName
            } else {
                
                
                trackResults.tracks.object(at: UInt(indexPath.row), with: DZRRequestManager.default(), callback: { (track, getTrackError) in
                    if getTrackError == nil, let track = track as? DZRTrack {
                        trackResults.trackIds[indexPath.row] = track.identifier()
                        
                        // Now go and get the track information because of COURSE it's not stored in a DZRTrack
                        track.playableInfos(with: DZRRequestManager.default(), callback: { (songInfo, error) in
                            if let songName = songInfo?["DZRPlayableObjectInfoName"] as? String {
                                trackResults.songNames[indexPath.row] = songName
                                
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let trackId = cachedResults[currentSearch]?.trackIds[indexPath.row], let path = firebasePlaylistPath {
            let playlistRef = Database.database().reference(withPath: path + "/deezerTrackIds")
            let newSongRef = playlistRef.childByAutoId()
            newSongRef.setValue(trackId)

            self.performSegue(withIdentifier: "unwindToPlaylist", sender: self)
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
                    
                    print("Got", results.count(), "search results. Now grabbing DZRTrack objects one by one...", searchText)
                    
                    let trackIds = [String?](repeating: nil, count: Int(results.count()))
                    let songNames = [String?](repeating: nil, count: Int(results.count()))
                    self.cachedResults[searchText] = TrackResults(tracks: results, trackIds: trackIds, songNames: songNames)
                    
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
