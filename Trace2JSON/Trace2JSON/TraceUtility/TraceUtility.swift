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
    
    init(path: String) throws {
        document = try PFTTraceDocument(contentsOf: URL(fileURLWithPath: path), ofType: "com.apple.instruments.trace")
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
                let standardController = XRAnalysisCoreStandardController(instrument: instrument, document: document)
                instrument.setViewController(standardController)
                standardController?.instrumentDidChangeSwitches()
                standardController?.instrumentChangedTableRequirements()
                
                guard let detailIvar = class_getInstanceVariable(standardController?.classForCoder,"_detailController"),
                    let detailController = object_getIvar(standardController, detailIvar) as? XRAnalysisCoreDetailViewController else {
                        continue
                }
                detailController.restoreViewState()
                
                guard let nodeIvar = class_getInstanceVariable(detailController.classForCoder,"_firstNode"),
                    var detailNode = object_getIvar(detailController, nodeIvar) as? XRAnalysisCoreDetailNode? else {
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
                result.runs.append(parser.parseContext(contexts, run: run))
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

//
//            NSString *instrumentID = instrument.type.uuid;
//            id<ParserProtocol> parser = [[ParserFactory new] parserForInstrument:instrumentID];
//            if (parser) {
//                NSDictionary *parserResult = @{
//                    @"run": @(run.runNumber),
//                    @"runName": run.displayName,
//                    @"result": [parser parseContext:contexts withRun:run]
//                };
//                [runsParsed addObject:parserResult];
//            } else {
//                NSDictionary *parserResult = @{
//                    @"run": @(run.runNumber),
//                    @"runName": run.displayName,
//                    @"result": @"unsupported instrument",
//                    @"unsupported": @(YES)
//                };
//                [runsParsed addObject:parserResult];
//                Print(@"Data processor has not been implemented for the instrument: %@", instrument.type.uuid);
//            }
//        }
//        [instrumentDictionary setObject:runsParsed forKey:@"runs"];
//
//        if (![instrument isKindOfClass:XRLegacyInstrument.class]) {
//            [instrument.viewController instrumentWillBecomeInvalid];
//            instrument.viewController = nil;
//        }
//
//        return instrumentDictionary;
//    }
//
//    @end
}
