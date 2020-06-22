//
//  Instrument.swift
//  Trace2JSON
//
//  Created by Itay Brenner on 6/22/20.
//  Copyright © 2020 Itaysoft. All rights reserved.
//

import Foundation

class Instrument: Codable {
    var runs: [InstrumentRun] = []
    var runsCount: Int = 0
    var type: String!
    
    init() {
    }
}
