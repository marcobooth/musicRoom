//
//  EventCellTableViewCell.swift
//  musicRoom
//
//  Created by Antoine LEBLANC on 6/26/17.
//  Copyright © 2017 Marco BOOTH. All rights reserved.
//

import UIKit

class EventCellTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var artist: UILabel!
    @IBOutlet weak var nbVote: UILabel!
    @IBOutlet weak var upVote: UIButton!
    @IBOutlet weak var downVote: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
