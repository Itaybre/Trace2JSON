//
//  ShellCommand.swift
//  Trace2JSON
//
//  Created by Itay Brenner on 6/22/20.
//  Copyright © 2020 Itaysoft. All rights reserved.
//

import Foundation

class ShellCommand {
    func runCommand(cmd: String, arguments: [String]) -> String {
        let task = Process()
        task.launchPath = cmd
        task.arguments = arguments
        
        let pipe = Pipe()
        task.standardOutput = pipe
        
        task.launch()
        defer {
            task.terminate()
        }
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        if let result = String(data: data, encoding: .utf8) {
            return result
        }
        
        return "error getting output"
    }
}
