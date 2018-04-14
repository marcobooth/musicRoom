//
//  SnapshotHandler.swift
//  musicRoom
//
//  Created by Teo FLEMING on 7/20/17.
//  Copyright © 2017 Marco BOOTH. All rights reserved.
//

import Foundation

protocol SnapshotHandler {
    func snapshotChanged(snapshot: DataSnapshot)
}
