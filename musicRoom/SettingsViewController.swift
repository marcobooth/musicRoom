//
//  SettingsViewController.swift
//  musicRoom
//
//  Created by Marco BOOTH on 6/13/17.
//  Copyright © 2017 Marco BOOTH. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func search(_ sender: UIButton) {
        print("beginning search")
        DeezerSession.sharedInstance.player?.play()
//        DeezerSession.sharedInstance.player?.play(
        
//        DZRObject.search(for: DZRSearchType.track, withQuery: "californication", requestManager: DZRRequestManager.default(), callback: {(_ results: DZRObjectList?, _ error: Error?) -> Void in
//            results!.allObjects(with: DZRRequestManager.default(), callback: {(_ objs: [Any]?, _ error: Error?) -> Void in
//                print(objs?[0])
//                print(type(of: objs?[0]))
//                DeezerSession.sharedInstance.player?.play(objs?[0] as! DZRPlayable!, at: 0)
//                //                for obj in objs! {
//                //                    print(obj)
//                //                }
//            })
//        })
    }
    
    @IBAction func loginToDeezer(_ sender: UIButton) {
        print("pressed login to deezer")
        DeezerSession.sharedInstance.deezerConnect?.authorize(["DeezerConnectPermissionBasicAccess"])
    }

}
