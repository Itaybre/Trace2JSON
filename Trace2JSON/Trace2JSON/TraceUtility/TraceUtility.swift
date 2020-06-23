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
    
    struct TraceConstants {
        static let instrumentsTrace = "com.apple.instruments.trace"
        static let detailController = "_detailController"
        static let firstNode = "_firstNode"
    }
    
    init(path: String, process: String?, pid: String?) throws {
        document = try PFTTraceDocument(contentsOf: URL(fileURLWithPath: path), ofType: TraceConstants.instrumentsTrace)
        self.process = process
        self.pid = pid
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
    
    func processInstrument(_ instrument: XRInstrument) -> Instrument? {
        guard let runs = instrument.allRuns() else {
            return nil
        }
        
        let result = Instrument()
        result.runsCount = runs.count
        result.type = instrument.type()?.uuid()
        
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
            
            if let instrumentId = instrument.type()?.uuid(),
                let parser = parserFactory.parserForInstrument(instrument: instrumentId) {
                result.runs.append(parseContexts(contexts, run: run, parser: parser))
            }
            
            if let _ = instrument as? XRLegacyInstrument {}
            else {
                instrument.viewController()?.instrumentWillBecomeInvalid()
                instrument.setViewController(nil)
            }
        }
        
        
        return result
    }
    
    func createContext(_ detailNode: XRAnalysisCoreDetailNode?, _ detailController: XRAnalysisCoreDetailViewController) -> XRContext? {
        guard let detailNode = detailNode else {
            return nil
        }
        
        return XRContext(label: detailNode.label,
                         value: detailNode,
                         attributes: nil,
                         container: detailController,
                         parentContext: createContext(detailNode.parent, detailController))
    }
    
    func parseContexts(_ contexts: [XRContext], run: XRRun, parser: ParserProtocol) -> InstrumentRun {
        if let process = process {
            return parser.parseContext(contexts, run: run, process: process)
        } else if let pid = pid {
            return parser.parseContext(contexts, run: run, pid: pid)
        } else {
            return parser.parseContext(contexts, run: run)
        }
    }
}
