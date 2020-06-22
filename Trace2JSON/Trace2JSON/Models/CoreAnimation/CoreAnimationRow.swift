//
//  CoreAnimationRow.swift
//  Trace2JSON
//
//  Created by Itay Brenner on 6/22/20.
//  Copyright © 2020 Itaysoft. All rights reserved.
//

import Foundation

struct CoreAnimationRow: Codable {
    let timestamp: String
    let fps: Int
    let gpuUsage: Int
}
