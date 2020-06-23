//
//  LeaksParser.swift
//  Trace2JSON
//
//  Created by Itay Brenner on 6/22/20.
//  Copyright © 2020 Itaysoft. All rights reserved.
//

import Foundation

class LeaksParser: ParserProtocol {
    private let helper = LeaksParserHelper()
    
    func parseContext(_ contexts: [XRContext], run: XRRun) -> InstrumentRun {
        let result = LeakRun()
        result.run = Int(run.runNumber())
        result.runName = run.displayName()
        
        // Workaround because some classes are inside Instrument's plugins and not it's libraries
        result.result = helper.getLeaksFrom(run)
        
        return result
    }
}
