//
//  TraceUtility.swift
//  Trace2JSON
//
//  Created by Itay Brenner on 6/22/20.
//  Copyright © 2020 Itaysoft. All rights reserved.
//

import Foundation

class TraceUtility {
    private var document: PFTTraceDocument
    private var parserFactory = ParserFactory()
    private var process: String?
    private var pid: String?
    private var showUnsupported: Bool
    
    struct TraceConstants {
        static let instrumentsTrace = "com.apple.instruments.trace"
        static let detailController = "_detailController"
        static let firstNode = "_firstNode"
    }
    
    init(path: String, process: String?, pid: String?, showUnsupported: Bool) throws {
        document = try PFTTraceDocument(contentsOf: URL(fileURLWithPath: path), ofType: TraceConstants.instrumentsTrace)
        self.process = process
        self.pid = pid
        self.showUnsupported = showUnsupported
    }
    
    func processDocument() -> Trace {
        let trace = Trace()
        
        trace.device = Device(device: document.targetDevice())
        trace.process = SelectedProcess(process: document.defaultProcess())
        
        guard let xrtrace = document.trace(),
            let instruments = xrtrace.allInstrumentsList() else {
            return trace
        }
        
        for instrument in instruments.allInstruments() {
            if let result = processInstrument(instrument) {
                trace.instruments.append(result)
            }
        }
        
        return trace
    }
    
    private func processInstrument(_ instrument: XRInstrument) -> Instrument? {
        guard let runs = instrument.allRuns(),
            let instrumentId = instrument.type()?.uuid() else {
            return nil
        }
        
        let result = Instrument()
        result.runsCount = runs.count
        result.type = instrument.type()?.uuid()
        
        if let parser = parserFactory.parserForInstrument(instrument: instrumentId) {
            processRuns(runs, instrument, parser, result)
        } else if !showUnsupported {
            return nil
        }
        
        return result
    }
    
    private func createContext(_ detailNode: XRAnalysisCoreDetailNode?, _ detailController: XRAnalysisCoreDetailViewController) -> XRContext? {
        guard let detailNode = detailNode else {
            return nil
        }
        
        return XRContext(label: detailNode.label,
                         value: detailNode,
                         attributes: nil,
                         container: detailController,
                         parentContext: createContext(detailNode.parent, detailController))
    }
    
    private func parseContexts(_ contexts: [XRContext], run: XRRun, parser: ParserProtocol, instrument: XRInstrument) -> InstrumentRun {
        if let process = process {
            return parser.parse(contexts: contexts, run: run, instrument: instrument, process: process)
        } else if let pid = pid {
            return parser.parse(contexts: contexts, run: run, instrument: instrument, pid: pid)
        } else {
            return parser.parse(contexts: contexts, run: run, instrument: instrument)
        }
    }

    private func processRuns(_ runs: [XRRun], _ instrument: XRInstrument, _ parser: ParserProtocol, _ result: Instrument) {
        for run in runs {
            instrument.setCurrentRun(run)
            
            var contexts: [XRContext] = []
            if let _ = instrument as? XRLegacyInstrument {}
            else {
                guard let standardController = XRAnalysisCoreStandardController(instrument: instrument,
                                                                                document: document) else {
                                                                                    continue
                }
                instrument.setViewController(standardController)
                standardController.instrumentDidChangeSwitches()
                standardController.instrumentChangedTableRequirements()
                
                guard let detailController: XRAnalysisCoreDetailViewController = RuntimeHacks.getIvar(instance: standardController,
                                                                                                      name: TraceConstants.detailController) else {
                                                                                                        continue
                }
                detailController.restoreViewState()
                
                guard var detailNode: XRAnalysisCoreDetailNode? = RuntimeHacks.getIvar(instance: detailController,
                                                                                       name: TraceConstants.firstNode) else {
                                                                                        continue
                }
                
                while(detailNode != nil) {
                    if let resultContext = createContext(detailNode!, detailController) {
                        contexts.append(resultContext)
                    }
                    detailNode = detailNode?.nextSibling()
                }
            }
            
            result.runs.append(parseContexts(contexts, run: run, parser: parser, instrument: instrument))
            
            if let _ = instrument as? XRLegacyInstrument {}
            else {
                instrument.viewController()?.instrumentWillBecomeInvalid()
                instrument.setViewController(nil)
            }
        }
    }
}
