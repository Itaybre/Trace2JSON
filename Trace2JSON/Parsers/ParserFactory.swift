//
//  ParserFactory.swift
//  Trace2JSON
//
//  Created by Itay Brenner on 6/22/20.
//  Copyright © 2020 Itaysoft. All rights reserved.
//

import Foundation

class ParserFactory {
    private let parsers: [String:ParserProtocol] = [
        "com.apple.xray.instrument-type.homeleaks" : LeaksParser(),
        "com.apple.xray.instrument-type.activity": ActivityMonitorParser(),
        "com.apple.dt.coreanimation-fps": CoreAnimationParser(),
        "com.apple.dt.network-connections": ConnectionsParser(),
        "com.apple.xray.instrument-type.oa": AllocationsParser(),
        "com.apple.dt.cpu-activity-log": CPUActivityLogParser()
    ]
    
    func parserForInstrument(instrument: String) -> ParserProtocol? {
        return parsers[instrument]
    }
}

class CPUActivityLogParser: ParserProtocol {
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

class CPUActivityRow: Codable {
    let time: Time
    var foregroundApp: CPUImpact?
    var graphics: CPUImpact?
    var media: CPUImpact?
    var other: CPUImpact?
    
    init(time: Time) {
        self.time = time
    }
    
    func setImpact(impact: CPUImpact, for activity: String) {
        switch activity {
        case "Media":
            media = impact
            return
        case "Foreground App":
            foregroundApp = impact
            return
        case "Other":
            other = impact
            return
        case "Graphics":
            graphics = impact
            return
        default:
            return
        }
    }
}

struct CPUImpact: Codable {
    let impact: Impact
    let cpuUsage: String
}

struct Time: Codable, Hashable {
    let time: String
    let duration: String
}

enum Impact: String, Codable {
    case none = "None"
    case veryLow = "Very Low"
    case low = "Low"
    case high = "High"
    case veryHigh = "Very High"
}

class CPUActivityRun: InstrumentRun {
    var result: [Time:CPUActivityRow] = [:]
    
    override init() {
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(result, forKey: .result)
    }
    
    enum CodingKeys: String, CodingKey {
        case result
    }
}
