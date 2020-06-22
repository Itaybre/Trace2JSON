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
    
    @Option(name: .shortAndLong, help: "Output path.")
    var output: String?

    @Argument(help: "Path to .trace to parse.")
    var path: String

    mutating func run() throws {
        Instruments.loadPlugins()
        
        let traceUtility = try TraceUtility(path: path)
        let trace = traceUtility.processDocument()
        
        let jsonData = try! JSONEncoder().encode(trace)
        if let output = output {
            do {
                try jsonData.write(to: URL(fileURLWithPath: output))
            } catch {
                let stderr = FileHandle.standardError
                let message = "Error saving file to \(output): \(error)"
                stderr.write(message.data(using: .utf8)!)
            }
        }
        
        Instruments.unloadPlugins()
    }
}

ParseTrace.main()
