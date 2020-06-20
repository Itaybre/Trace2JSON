//
//  Instruments.m
//  Trace2JSON
//
//  Created by Itay Brenner on 6/20/20.
//  Copyright © 2020 Itaysoft. All rights reserved.
//

#import "Instruments.h"
#import "InstrumentsPrivateHeaders.h"
#import <AppKit/AppKit.h>

@implementation Instruments

+ (void) loadPlugins {
    // Required. Each instrument is a plugin and we have to load them before we can process their data.
    DVTInitializeSharedFrameworks();
    [DVTDeveloperPaths initializeApplicationDirectoryName:@"Instruments"];
    [XRInternalizedSettingsStore configureWithAdditionalURLs:nil];
    [[XRCapabilityRegistry applicationCapabilities]registerCapability:@"com.apple.dt.instruments.track_pinning" versions:NSMakeRange(1, 1)];
    PFTLoadPlugins();

    // Instruments has its own subclass of NSDocumentController without overriding sharedDocumentController method.
    // We have to call this eagerly to make sure the correct document controller is initialized.
    [PFTDocumentController sharedDocumentController];
}

+ (void) unloadPlugins {
    PFTClosePlugins();
}

@end
