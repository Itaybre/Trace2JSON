//
//  AllocationsRow.swift
//  trace2json
//
//  Created by Itay Brenner on 6/23/20.
//  Copyright © 2020 Itaysoft. All rights reserved.
//

import Foundation

@objc class AllocationsRow: NSObject, Codable {
    let time: Double
    let size: Int
    let formattedSize: String
    
    @objc init(time: Double, size: Int, formattedSize: String) {
        self.time = time
        self.size = size
        self.formattedSize = formattedSize
    }
}
