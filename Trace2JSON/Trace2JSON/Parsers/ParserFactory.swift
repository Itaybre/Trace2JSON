//
//  ParserFactory.swift
//  Trace2JSON
//
//  Created by Itay Brenner on 6/22/20.
//  Copyright © 2020 Itaysoft. All rights reserved.
//

import Foundation

protocol ParserProtocol {
    func parseContext(_ contexts: [XRContext], run: XRRun) -> InstrumentRun
}

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

//- (instancetype)init {
//    if (self = [super init]) {
//        self.parsers = @{
//            @"com.apple.xray.instrument-type.homeleaks": [LeaksParser new],
//            @"com.apple.xray.instrument-type.activity": [ActivityMonitorParser new],
//            @"com.apple.dt.coreanimation-fps": [CoreAnimationParser new],
//            @"com.apple.dt.network-connections": [ConnectionsParser new]
//        };
//    }
//    return self;
//}
