//
//  TraceUtility.m
//  Trace2JSON
//
//  Created by Itay Brenner on 6/20/20.
//  Copyright © 2020 Itaysoft. All rights reserved.
//

#import "TraceUtility.h"
#import "InstrumentsPrivateHeaders.h"
#import "ParserFactory.h"

@interface TraceUtility ()
@property (nonatomic, strong) PFTTraceDocument *document;
@end

@implementation TraceUtility

- (void) openDocument:(NSString *)path {
    NSError *error = nil;
    self.document = [[PFTTraceDocument alloc]initWithContentsOfURL:[NSURL fileURLWithPath:path] ofType:@"com.apple.instruments.trace" error:&error];
    if (error) {
        Print(@"Error: %@", error);
        exit(1);
    }
    Print(@"Trace: %@", path);
}

- (void) processDocument {
    // This logic was based on Qusic's TraceUtility (https://github.com/Qusic/TraceUtility)
    XRDevice *device = self.document.targetDevice;
    Print(@"Device: %@ (%@ %@ %@)", device.deviceDisplayName, device.productType, device.productVersion, device.buildVersion);
    PFTProcess *process = self.document.defaultProcess;
    Print(@"Process: %@ (%@)", process.displayName, process.bundleIdentifier);
    
    XRTrace *trace = self.document.trace;
    for (XRInstrument *instrument in trace.allInstrumentsList.allInstruments) {
        Print(@"\nInstrument: %@ (%@)", instrument.type.name, instrument.type.uuid);

        // Each instrument can have multiple runs.
        NSArray<XRRun *> *runs = instrument.allRuns;
        if (runs.count == 0) {
            Print(@"No data.");
            continue;
        }
        for (XRRun *run in runs) {
            Print(@"Run #%@: %@", @(run.runNumber), run.displayName);
            instrument.currentRun = run;

            // Common routine to obtain contexts for the instrument.
            NSMutableArray<XRContext *> *contexts = [NSMutableArray array];
            if (![instrument isKindOfClass:XRLegacyInstrument.class]) {
                XRAnalysisCoreStandardController *standardController = [[XRAnalysisCoreStandardController alloc]initWithInstrument:instrument document:self.document];
                instrument.viewController = standardController;
                [standardController instrumentDidChangeSwitches];
                [standardController instrumentChangedTableRequirements];
                XRAnalysisCoreDetailViewController *detailController = Ivar(standardController, _detailController);
                [detailController restoreViewState];
                XRAnalysisCoreDetailNode *detailNode = Ivar(detailController, _firstNode);
                while (detailNode) {
                    [contexts addObject:[self createContext:detailNode container:detailController]];
                    detailNode = detailNode.nextSibling;
                }
            }

            NSString *instrumentID = instrument.type.uuid;
            id<ParserProtocol> parser = [[ParserFactory new] parserForInstrument:instrumentID];
            if (parser) {
                [parser parseContext:contexts withRun:run];
            } else {
                Print(@"Data processor has not been implemented for this type of instrument.");
            }
        }
        
        if (![instrument isKindOfClass:XRLegacyInstrument.class]) {
            [instrument.viewController instrumentWillBecomeInvalid];
            instrument.viewController = nil;
        }
    }
    
    [self.document close];
}

- (XRContext *) createContext:(XRAnalysisCoreDetailNode *) detailNode container:(XRAnalysisCoreDetailViewController *) detailController {
    if (!detailNode)
        return nil;

    NSString *label = [detailNode label];
    XRAnalysisCoreDetailNode *parentNode = detailNode.parent;
    XRContext *parentContext = [self createContext:parentNode container: detailController];

    XRContext *context = [[XRContext alloc] initWithLabel:label
                                                    value:detailNode
                                               attributes:nil
                                                container:detailController
                                            parentContext:parentContext];

    return context;
}

@end
