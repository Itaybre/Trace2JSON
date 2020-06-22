//
//  Leak.swift
//  Trace2JSON
//
//  Created by Itay Brenner on 6/22/20.
//  Copyright © 2020 Itaysoft. All rights reserved.
//

import Foundation

@objc class LeakRow: NSObject, Codable {
    let name: String
    let size: Int
    let count: Int
    let isCycle: Bool
    let isRootLeak: Bool
    let allocationTimeStamp: Int
    
    @objc init(name: String, size: NSNumber, count: NSNumber, isCycle: Bool, isRootLeak: Bool, allocationTimeStamp: NSNumber) {
        self.name = name
        self.size = size.intValue
        self.count = count.intValue
        self.isCycle = isCycle
        self.isRootLeak = isRootLeak
        self.allocationTimeStamp = allocationTimeStamp.intValue
    }
}
