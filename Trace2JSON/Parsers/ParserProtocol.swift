//
//  ParserProtocol.swift
//  Trace2JSON
//
//  Created by Itay Brenner on 6/22/20.
//  Copyright © 2020 Itaysoft. All rights reserved.
//

import Foundation

protocol ParserProtocol {
    func parseContext(_ contexts: [XRContext], run: XRRun) -> InstrumentRun
    
    func parseContext(_ contexts: [XRContext], run: XRRun, pid: String) -> InstrumentRun
    
    func parseContext(_ contexts: [XRContext], run: XRRun, process: String) -> InstrumentRun
}

extension ParserProtocol {
    func parseContext(_ contexts: [XRContext], run: XRRun, pid: String) -> InstrumentRun {
        return parseContext(contexts, run: run)
    }
    
    func parseContext(_ contexts: [XRContext], run: XRRun, process: String) -> InstrumentRun {
        return parseContext(contexts, run: run)
    }
}
