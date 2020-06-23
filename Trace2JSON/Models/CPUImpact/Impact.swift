//
//  Impact.swift
//  trace2json
//
//  Created by Itay Brenner on 6/23/20.
//  Copyright © 2020 Itaysoft. All rights reserved.
//

import Foundation

enum Impact: String, Codable {
    case none = "None"
    case veryLow = "Very Low"
    case low = "Low"
    case high = "High"
    case veryHigh = "Very High"
}
