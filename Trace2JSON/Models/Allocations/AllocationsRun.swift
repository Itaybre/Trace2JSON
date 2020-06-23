//
//  AllocationsRun.swift
//  trace2json
//
//  Created by Itay Brenner on 6/23/20.
//  Copyright © 2020 Itaysoft. All rights reserved.
//

import Foundation

class AllocationsRun: InstrumentRun {
    var result: [AllocationsRow] = []
    
    override init() {
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(result, forKey: .result)
    }
    
    enum CodingKeys: String, CodingKey {
        case result
    }
}
