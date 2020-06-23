//
//  main.swift
//  Trace2JSON
//
//  Created by Itay Brenner on 6/22/20.
//  Copyright © 2020 Itaysoft. All rights reserved.
//

import Foundation
import ArgumentParser

enum OptionsError: Error {
    case tooManyFilters(String)
}

struct Trace2JSON: ParsableCommand {
    static var configuration = CommandConfiguration(commandName: "trace2json")
    
    @Option(name: .long, help: "Process Name to filter when available.")
    var process: String?
    
    @Option(name: .long, help: "Process PID to filter when available.")
    var pid: String?
    
    @Flag(name: .long, help: "Enable JSON pretty print.")
    var pretty: Bool
    
    @Flag(name: .shortAndLong, help: "Show unsupported instruments in output JSON.")
    var showUnsupported: Bool
    
    @Option(name: .shortAndLong, help: "Output path.")
    var output: String?

    @Argument(help: "Path to .trace to parse.")
    var path: String

    mutating func run() throws {
        if process != nil && pid != nil {
            throw OptionsError.tooManyFilters("Please only set a proceess OR pid")
        }
        
        Instruments.loadPlugins()
        
        let traceUtility = try TraceUtility(path: path,
                                            process: process,
                                            pid: pid,
                                            showUnsupported: showUnsupported)
        let trace = traceUtility.processDocument()
        
        try showResults(trace)
        
        Instruments.unloadPlugins()
    }
    
    func showResults(_ trace: Trace) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = pretty ? .prettyPrinted : .sortedKeys
            
        let jsonData = try! encoder.encode(trace)
        if let output = output {
            try jsonData.write(to: URL(fileURLWithPath: output))
        } else {
            print(String(data: jsonData, encoding: .utf8)!)
        }
    }
}

Trace2JSON.main()
