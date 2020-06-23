//
//  Activity.swift
//  Trace2JSON
//
//  Created by Itay Brenner on 6/22/20.
//  Copyright © 2020 Itaysoft. All rights reserved.
//

import Foundation

struct ActivityRow: Codable {
    let time: String
    let process: String
    let pid: String
    let cpu: String
    let memory: String
    let threads: String
}
