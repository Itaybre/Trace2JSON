//
//  CPUActivityRow.swift
//  trace2json
//
//  Created by Itay Brenner on 6/23/20.
//  Copyright © 2020 Itaysoft. All rights reserved.
//

import Foundation

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
