//
//  Device.swift
//  Trace2JSON
//
//  Created by Itay Brenner on 6/22/20.
//  Copyright © 2020 Itaysoft. All rights reserved.
//

import Foundation

struct Device: Codable {
    let displayName: String?
    let productType: String?
    let productVersion: String?
    let buildVersion: String?
    
    init(device: XRDevice) {
        displayName = device.deviceDisplayName()
        productType = device.productType()
        productVersion = device.productVersion()
        buildVersion = device.buildVersion()
    }
}
