//
//  ConnectionsParser.swift
//  Trace2JSON
//
//  Created by Itay Brenner on 6/22/20.
//  Copyright © 2020 Itaysoft. All rights reserved.
//

import Foundation

class ConnectionsParser: ParserProtocol {
    private let regexHelper = ProcessRegex()
    
    func parseContext(_ contexts: [XRContext], run: XRRun) -> InstrumentRun {
        return parseContext(contexts, run: run, filter: Filter.noFilter, filterString: nil)
    }
    
    func parseContext(_ contexts: [XRContext], run: XRRun, pid: String) -> InstrumentRun {
        return parseContext(contexts, run: run, filter: Filter.filterPid, filterString: pid)
    }
    
    func parseContext(_ contexts: [XRContext], run: XRRun, process: String) -> InstrumentRun {
        return parseContext(contexts, run: run, filter: Filter.filterProcess, filterString: process)
    }
    
    private func parseContext(_ contexts: [XRContext], run: XRRun, filter: Filter, filterString: String?) -> InstrumentRun {
        let connectionRun = ConnectionsRun()
        connectionRun.run = Int(run.runNumber())
        connectionRun.runName = run.displayName()
        
        let context = contexts[2]
        context.display()
        
        guard let container = context.container() as? XRAnalysisCoreDetailViewController,
            let controller: XRAnalysisCoreTableViewController = RuntimeHacks.getIvar(instance: container, name: "_tabularViewController"),
            let array = controller._currentResponse()?.content.rows(),
            let analysisCoreTable: XRAnalysisCoreTableQuery = RuntimeHacks.getIvar(instance: array.source()!, name: "_filter"),
            let formatter = analysisCoreTable.fullTextSearchSpec()!.formatter() else {
                return connectionRun
        }
        
        array.access({ (accessor) in
            accessor?.readRowsStarting(at: 0, dimension: 0, block: { (cursor) in
                self.readRow(cursor, formatter, connectionRun, filter, filterString)
            })
        })
        
        return connectionRun
    }
    
    fileprivate func readRow(_ cursor: UnsafeMutableRawPointer?, _ formatter: XREngineeringTypeFormatter, _ run: ConnectionsRun, _ filter: Filter, _ filterString: String?) {
        while(XRAnalysisCoreReadCursorNext(cursor)) {
            var objectFound: Int32 = 0
            var object: XRAnalysisCoreValue? = nil
            
            objectFound = XRAnalysisCoreReadCursorGetValue(cursor, 0, &object)
            let time = objectFound != 0 ? formatter.string(for: object) ?? "" : ""
            objectFound = XRAnalysisCoreReadCursorGetValue(cursor, 3, &object)
            let process = objectFound != 0 ? formatter.string(for: object) ?? "" : ""
            objectFound = XRAnalysisCoreReadCursorGetValue(cursor, 4, &object)
            let interface = objectFound != 0 ? formatter.string(for: object) ?? "" : ""
            objectFound = XRAnalysisCoreReadCursorGetValue(cursor, 5, &object)
            let protocolUsed = objectFound != 0 ? formatter.string(for: object) ?? "" : ""
            objectFound = XRAnalysisCoreReadCursorGetValue(cursor, 6, &object)
            let local = objectFound != 0 ? formatter.string(for: object) ?? "" : ""
            objectFound = XRAnalysisCoreReadCursorGetValue(cursor, 7, &object)
            let remote = objectFound != 0 ? formatter.string(for: object) ?? "" : ""
            objectFound = XRAnalysisCoreReadCursorGetValue(cursor, 9, &object)
            let packetsIn = objectFound != 0 ? formatter.string(for: object) ?? "" : ""
            objectFound = XRAnalysisCoreReadCursorGetValue(cursor, 10, &object)
            let bytesIn = objectFound != 0 ? formatter.string(for: object) ?? "" : ""
            objectFound = XRAnalysisCoreReadCursorGetValue(cursor, 11, &object)
            let packetsOut = objectFound != 0 ? formatter.string(for: object) ?? "" : ""
            objectFound = XRAnalysisCoreReadCursorGetValue(cursor, 12, &object)
            let bytesOut = objectFound != 0 ? formatter.string(for: object) ?? "" : ""
            objectFound = XRAnalysisCoreReadCursorGetValue(cursor, 16, &object)
            let minRTT = objectFound != 0 ? formatter.string(for: object) ?? "" : ""
            objectFound = XRAnalysisCoreReadCursorGetValue(cursor, 17, &object)
            let avgRTT = objectFound != 0 ? formatter.string(for: object) ?? "" : ""
            
            let processMatch = regexHelper.matchString(process)
            if filter == .filterProcess && processMatch.process != filterString {
                continue
            } else if filter == .filterPid && processMatch.pid != filterString {
                continue
            }

            let row = ConnectionRow(time: time, process: processMatch.process, pid: processMatch.pid,
                                    interface: interface, connectionProtocol: protocolUsed, local: local,
                                    remote: remote, packetsIn: packetsIn, bytesIn: bytesIn,
                                    packetsOut: packetsOut, bytesOut: bytesOut, minRTT: minRTT, avgRTT: avgRTT)
            run.result.append(row)
        }
    }
}
