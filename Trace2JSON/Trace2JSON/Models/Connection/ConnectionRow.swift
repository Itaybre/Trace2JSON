//
//  ConnectionRow.swift
//  Trace2JSON
//
//  Created by Itay Brenner on 6/22/20.
//  Copyright © 2020 Itaysoft. All rights reserved.
//

import Foundation

struct ConnectionRow: Codable {
    let time: String
    let process: String
    let interface: String
    let connectionProtocol: String
    let local: String
    let remote: String
    let packetsIn: String
    let bytesIn: String
    let packetsOut: String
    let bytesOut: String
    let minRTT: String
    let avgRTT: String
}
