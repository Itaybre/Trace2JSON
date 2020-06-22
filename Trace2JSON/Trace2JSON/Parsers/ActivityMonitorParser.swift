//
//  ActivityMonitorParser.swift
//  Trace2JSON
//
//  Created by Itay Brenner on 6/22/20.
//  Copyright © 2020 Itaysoft. All rights reserved.
//

import Foundation

class ActivityMonitorParser: ParserProtocol {
    func parseContext(_ contexts: [XRContext], run: XRRun) -> InstrumentRun {
        let activityRun = ActivityRun()
        activityRun.run = Int(run.runNumber())
        activityRun.runName = run.displayName()
        
        let context = contexts[0]
        context.display()
        
        guard let container = context.container() as? XRAnalysisCoreDetailViewController,
            let controller: XRAnalysisCoreTableViewController = RuntimeHacks.getIvar(instance: container, name: "_tabularViewController") else {
                return activityRun
        }
        
        let duration = run.timeRange().length
        for time in stride(from: 0, to: duration, by: UInt64.Stride(NSEC_PER_SEC)) {
            controller.setDocumentInspectionTime(time)
            controller._retrieveResponse()
            
            guard let content = controller._currentResponse().content,
                let array = content.rows(),
                let filter: XRAnalysisCoreTableQuery = RuntimeHacks.getIvar(instance: array.source()!, name: "_filter"),
                let formatter = filter.fullTextSearchSpec()!.formatter() else {
                    continue
            }
            
            array.access({ (accessor) in
                accessor?.readRowsStarting(at: 0, dimension: 0, block: { (cursor) in
                    self.readRow(cursor, formatter, activityRun)
                })
            })
        }
        
        return activityRun
    }
    
    fileprivate func readRow(_ cursor: UnsafeMutableRawPointer?, _ formatter: XREngineeringTypeFormatter, _ activityRun: ActivityRun) {
        while(XRAnalysisCoreReadCursorNext(cursor)) {
            var objectFound: Int32 = 0
            var object: XRAnalysisCoreValue? = nil
            
            objectFound = XRAnalysisCoreReadCursorGetValue(cursor, 0, &object)
            let time = objectFound != 0 ? formatter.string(for: object) : ""
            objectFound = XRAnalysisCoreReadCursorGetValue(cursor, 2, &object)
            let process = objectFound != 0 ? formatter.string(for: object) : ""
            objectFound = XRAnalysisCoreReadCursorGetValue(cursor, 6, &object)
            let cpu = objectFound != 0 ? formatter.string(for: object) : ""
            objectFound = XRAnalysisCoreReadCursorGetValue(cursor, 10, &object)
            let memory = objectFound != 0 ? formatter.string(for: object) : ""
            objectFound = XRAnalysisCoreReadCursorGetValue(cursor, 8, &object)
            let threads = objectFound != 0 ? formatter.string(for: object) : ""
            
            let row = ActivityRow(time: time ?? "",
                               process: process ?? "",
                               cpu: cpu ?? "",
                               memory: memory ?? "",
                               threads: threads ?? "")
            
            if let processActivity = activityRun.result[process!] {
                processActivity.activity[time!] = row
            } else {
                let processActivity = ProcessActivity()
                processActivity.activity[time!] = row
                
                activityRun.result[process!] = processActivity
            }
        }
    }
}
