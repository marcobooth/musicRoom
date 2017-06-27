//
//  TrackTableViewCell.swift
//  musicRoom
//
//  Created by Teo FLEMING on 6/27/17.
//  Copyright © 2017 Marco BOOTH. All rights reserved.
//

import UIKit

class TrackTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var creatorLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    
    var track: Track? {
        didSet {
            if let track = track {
                nameLabel.text = track.name
                creatorLabel.text = track.creator
                durationLabel.text = String(format: "%01d:%02d", track.duration / 60, track.duration % 60)
            } else {
                nameLabel.text = "Loading..."
                creatorLabel.text = ""
                durationLabel.text = ""
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
}
