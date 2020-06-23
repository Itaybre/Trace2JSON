//
//  CPUActivityLogParser.swift
//  trace2json
//
//  Created by Itay Brenner on 6/23/20.
//  Copyright © 2020 Itaysoft. All rights reserved.
//

import Foundation

class CPUImpactParser: ParserProtocol {
    func parse(contexts: [XRContext], run: XRRun, instrument: XRInstrument) -> InstrumentRun {
        let activityRun = CPUActivityRun()
        activityRun.run = Int(run.runNumber())
        activityRun.runName = run.displayName()
        
        let context = contexts[2]
        context.display()
        
        guard let container = context.container() as? XRAnalysisCoreDetailViewController,
            let controller: XRAnalysisCoreTableViewController = RuntimeHacks.getIvar(instance: container, name: "_tabularViewController"),
            let array = controller._currentResponse()?.content.rows(),
            let analysisCoreTable: XRAnalysisCoreTableQuery = RuntimeHacks.getIvar(instance: array.source()!, name: "_filter"),
            let formatter = analysisCoreTable.fullTextSearchSpec()!.formatter() else {
                return activityRun
        }
        
        array.access({ (accessor) in
            accessor?.readRowsStarting(at: 0, dimension: 0, block: { (cursor) in
                self.readRow(cursor, formatter, activityRun)
            })
        })
        
        return activityRun
    }
    
    fileprivate func readRow(_ cursor: UnsafeMutableRawPointer?, _ formatter: XREngineeringTypeFormatter, _ run: CPUActivityRun) {
        while(XRAnalysisCoreReadCursorNext(cursor)) {
            var objectFound: Int32 = 0
            var object: XRAnalysisCoreValue? = nil
            
            objectFound = XRAnalysisCoreReadCursorGetValue(cursor, 0, &object)
            let time = objectFound != 0 ? formatter.string(for: object) ?? "" : ""
            objectFound = XRAnalysisCoreReadCursorGetValue(cursor, 1, &object)
            let duration = objectFound != 0 ? formatter.string(for: object) ?? "" : ""
            objectFound = XRAnalysisCoreReadCursorGetValue(cursor, 2, &object)
            let activity = objectFound != 0 ? formatter.string(for: object) ?? "" : ""
            objectFound = XRAnalysisCoreReadCursorGetValue(cursor, 4, &object)
            let usage = objectFound != 0 ? formatter.string(for: object) ?? "" : ""
            objectFound = XRAnalysisCoreReadCursorGetValue(cursor, 5, &object)
            let impact = objectFound != 0 ? formatter.string(for: object) ?? "" : ""
            
            if let valueImpact = Impact.init(rawValue: impact) {
                let cpuImpact = CPUImpact(impact: valueImpact, cpuUsage: usage)
                let timeRow = Time(time: time, duration: duration)
                
                if let activityRow = run.result[timeRow] {
                    activityRow.setImpact(impact: cpuImpact, for: activity)
                } else {
                    let activityRow = CPUActivityRow(time: timeRow)
                    activityRow.setImpact(impact: cpuImpact, for: activity)
                    run.result[timeRow] = activityRow
                }
            }
        }
    }
}
