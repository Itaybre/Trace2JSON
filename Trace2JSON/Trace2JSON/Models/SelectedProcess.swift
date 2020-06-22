//
//  SelectedProcess.swift
//  Trace2JSON
//
//  Created by Itay Brenner on 6/22/20.
//  Copyright © 2020 Itaysoft. All rights reserved.
//

import Foundation

struct SelectedProcess: Codable {
    let name: String?
    let bundleIdentifier: String?
    
    init(process: PFTProcess) {
        name = process.displayName()
        bundleIdentifier = process.bundleIdentifier()
    }
}
