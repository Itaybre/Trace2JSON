//
//  Instruments.swift
//  Trace2JSON
//
//  Created by Itay Brenner on 6/22/20.
//  Copyright © 2020 Itaysoft. All rights reserved.
//

import Foundation

class Instruments {
    static func loadPlugins() {
        // Required. Each instrument is a plugin and we have to load them before we can process their data.
        DVTInitializeSharedFrameworks()
        DVTDeveloperPaths.initializeApplicationDirectoryName("Instruments")
        XRInternalizedSettingsStore.configure(withAdditionalURLs: nil)
        XRCapabilityRegistry.applicationCapabilities()?.registerCapability("com.apple.dt.instruments.track_pinning", versions: NSRange(location: 1, length: 1))
        PFTLoadPlugins()
        
        // Instruments has its own subclass of NSDocumentController without overriding sharedDocumentController method.
        // We have to call this eagerly to make sure the correct document controller is initialized.
        let _ = PFTDocumentController.shared
    }
    
    static func unloadPlugins() {
        PFTClosePlugins();
    }
}
