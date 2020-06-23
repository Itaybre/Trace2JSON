//
//  AllocationsParser.swift
//  trace2json
//
//  Created by Itay Brenner on 6/23/20.
//  Copyright © 2020 Itaysoft. All rights reserved.
//

import Foundation

class AllocationsParser: ParserProtocol {
    private let helper = AllocationsParserHelper()
    
    func parse(contexts: [XRContext], run: XRRun, instrument: XRInstrument) -> InstrumentRun {
        let allocationsRun = AllocationsRun()
        allocationsRun.run = Int(run.runNumber())
        allocationsRun.runName = run.displayName()
        
        // Workaround because some classes are inside Instrument's plugins and not it's libraries
        allocationsRun.result = helper.getAllocationsFrom(instrument)
        
        return allocationsRun
    }
}
