//
//  CoreAnimationParser.swift
//  Trace2JSON
//
//  Created by Itay Brenner on 6/22/20.
//  Copyright © 2020 Itaysoft. All rights reserved.
//

import Foundation

class CoreAnimationParser: ParserProtocol {
    func parseContext(_ contexts: [XRContext], run: XRRun) -> InstrumentRun {
        let coreRun = CoreAnimationRun()
        coreRun.run = Int(run.runNumber())
        coreRun.runName = run.displayName()
        
        let context = contexts[0]
        context.display()
        
        guard let container = context.container() as? XRAnalysisCoreDetailViewController,
            let controller: XRAnalysisCoreTableViewController = RuntimeHacks.getIvar(instance: container, name: "_tabularViewController"),
            let array = controller._currentResponse()?.content.rows(),
            let filter: XRAnalysisCoreTableQuery = RuntimeHacks.getIvar(instance: array.source()!, name: "_filter"),
            let formatter = filter.fullTextSearchSpec()!.formatter() else {
                return coreRun
        }
        
        array.access({ (accessor) in
            accessor?.readRowsStarting(at: 0, dimension: 0, block: { (cursor) in
                self.readRow(cursor, formatter, coreRun)
            })
        })
        
        return coreRun
    }
    
    fileprivate func readRow(_ cursor: UnsafeMutableRawPointer?, _ formatter: XREngineeringTypeFormatter, _ run: CoreAnimationRun) {
        while(XRAnalysisCoreReadCursorNext(cursor)) {
            var objectFound: Int32 = 0
            var object: XRAnalysisCoreValue? = nil
            
            objectFound = XRAnalysisCoreReadCursorGetValue(cursor, 0, &object)
            let time = objectFound != 0 ? formatter.string(for: object) : ""
            objectFound = XRAnalysisCoreReadCursorGetValue(cursor, 2, &object)
            let fps = objectFound != 0 ? (object?.objectValue())! as! NSNumber : 0
            objectFound = XRAnalysisCoreReadCursorGetValue(cursor, 3, &object)
            let gpu = objectFound != 0 ? (object?.objectValue())! as! NSNumber : 0

            let row = CoreAnimationRow(timestamp: time ?? "",
                                    fps: fps.intValue,
                                    gpuUsage: gpu.intValue)
            run.result.append(row)
        }
    }
}
