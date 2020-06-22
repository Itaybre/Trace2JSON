//
//  Trace.swift
//  Trace2JSON
//
//  Created by Itay Brenner on 6/22/20.
//  Copyright © 2020 Itaysoft. All rights reserved.
//

import Foundation

class Trace: Codable {
    var device: Device!
    var process: SelectedProcess!
    var instruments: [Instrument] = []
    
    init() {
        
    }
}
