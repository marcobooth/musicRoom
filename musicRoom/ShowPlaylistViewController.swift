//
//  ShowPlaylistViewController.swift
//  musicRoom
//
//  Created by Marco BOOTH on 6/12/17.
//  Copyright © 2017 Marco BOOTH. All rights reserved.
//

import UIKit

class ShowPlaylistViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func backToPlaylists(_ sender: UIButton) {
        self.performSegue(withIdentifier: "backToPlaylists", sender: self)
    }

}
