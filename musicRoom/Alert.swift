//
//  Alert.swift
//  musicRoom
//
//  Created by Marco BOOTH on 6/28/17.
//  Copyright © 2017 Marco BOOTH. All rights reserved.
//

import Foundation

extension UIViewController {
    func showBasicAlert(title : String, message : String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok, noted", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
