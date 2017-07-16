//
//  AddFriendsTableViewCell.swift
//  musicRoom
//
//  Created by Antoine LEBLANC on 6/28/17.
//  Copyright © 2017 Marco BOOTH. All rights reserved.
//

import UIKit

class AddFriendsTableViewCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var friend: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
