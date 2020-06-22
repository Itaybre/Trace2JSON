//
//  main.swift
//  Trace2JSON
//
//  Created by Itay Brenner on 6/22/20.
//  Copyright © 2020 Itaysoft. All rights reserved.
//

import Foundation
import ArgumentParser

struct ParseTrace: ParsableCommand {
//    @Option(name: .long, help: "Process Name to filter when available.")
//    var process: String?
//    
//    @Option(name: .long, help: "Process PID to filter when available.")
//    var pid: String?
    
    @Flag(name: .long, help: "Enable JSON pretty print.")
    var pretty: Bool
    
    @Option(name: .shortAndLong, help: "Output path.")
    var output: String?

    @Argument(help: "Path to .trace to parse.")
    var path: String

    mutating func run() throws {
        Instruments.loadPlugins()
        
        let traceUtility = try TraceUtility(path: path)
        let trace = traceUtility.processDocument()
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = pretty ? .prettyPrinted : .sortedKeys
            
        let jsonData = try! encoder.encode(trace)
        if let output = output {
            try jsonData.write(to: URL(fileURLWithPath: output))
        } else {
            print(String(data: jsonData, encoding: .utf8)!)
        }
        
        Instruments.unloadPlugins()
    }
}

ParseTrace.main()
