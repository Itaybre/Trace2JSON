//
//  ParserFactory.swift
//  Trace2JSON
//
//  Created by Itay Brenner on 6/22/20.
//  Copyright © 2020 Itaysoft. All rights reserved.
//

import Foundation

class ParserFactory {
    private let parsers: [String:ParserProtocol] = [
        "com.apple.xray.instrument-type.homeleaks" : LeaksParser(),
        "com.apple.xray.instrument-type.activity": ActivityMonitorParser(),
        "com.apple.dt.coreanimation-fps": CoreAnimationParser(),
        "com.apple.dt.network-connections": ConnectionsParser()
    ]
    
    func parserForInstrument(instrument: String) -> ParserProtocol? {
        return parsers[instrument]
    }
}
