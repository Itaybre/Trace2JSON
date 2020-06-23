//
//  ParserProtocol.swift
//  Trace2JSON
//
//  Created by Itay Brenner on 6/22/20.
//  Copyright © 2020 Itaysoft. All rights reserved.
//

import Foundation

protocol ParserProtocol {
    func parse(contexts: [XRContext], run: XRRun, instrument: XRInstrument) -> InstrumentRun
    
    func parse(contexts: [XRContext], run: XRRun, instrument: XRInstrument, pid: String) -> InstrumentRun
    
    func parse(contexts: [XRContext], run: XRRun, instrument: XRInstrument, process: String) -> InstrumentRun
}

extension ParserProtocol {
    func parse(contexts: [XRContext], run: XRRun, instrument: XRInstrument, pid: String) -> InstrumentRun {
        return parse(contexts: contexts, run: run, instrument: instrument)
    }
    
    func parse(contexts: [XRContext], run: XRRun, instrument: XRInstrument, process: String) -> InstrumentRun {
        return parse(contexts: contexts, run: run, instrument: instrument)
    }
}
