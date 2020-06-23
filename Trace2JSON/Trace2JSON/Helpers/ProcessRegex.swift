//
//  ProcessRegex.swift
//  Trace2JSON
//
//  Created by Itay Brenner on 6/22/20.
//  Copyright © 2020 Itaysoft. All rights reserved.
//

import Foundation
import Regex

struct ProcessMatch {
    let process: String
    let pid: String
}

class ProcessRegex {
    private let pattern: StaticString = "([a-zA-Z]\\w+) \\((-?\\d+)\\)"
    
    func matchString(_ string: String) -> ProcessMatch {
        let regex = Regex(pattern)

        if let match = regex.firstMatch(in: string),
            let process = match.captures[0],
            let pid = match.captures[1] {
            return ProcessMatch(process: process, pid: pid)
        }
        
        return ProcessMatch(process: "", pid: "")
    }
}
