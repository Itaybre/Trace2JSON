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
#import "XRDevice+NSDictionary.h"
#import "PFTProcess+NSDicionary.h"

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
}

- (void) processDocument {
    NSMutableDictionary *resultDictionary = [NSMutableDictionary new];
    
    // This logic was based on Qusic's TraceUtility (https://github.com/Qusic/TraceUtility)
    XRDevice *device = self.document.targetDevice;
    [resultDictionary setObject:[device dictionary] forKey:@"device"];

    PFTProcess *process = self.document.defaultProcess;
    [resultDictionary setObject:[process dictionary] forKey:@"process"];
    
    
    NSMutableDictionary *instruments = [NSMutableDictionary new];
    XRTrace *trace = self.document.trace;
    for (XRInstrument *instrument in trace.allInstrumentsList.allInstruments) {
        NSDictionary *instrumentResult = [self processInstrument:instrument];
        
        if(instrumentResult) {
            [instruments setObject:instrumentResult forKey:instrument.type.uuid];
        }
    }
    
    [resultDictionary setObject:instruments forKey:@"instruments"];
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:resultDictionary options:NSJSONWritingPrettyPrinted error:&error];
    if(!error) {
        Print(@"%@", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
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

- (NSDictionary *) processInstrument: (XRInstrument *) instrument {
    // Each instrument can have multiple runs.
    NSArray<XRRun *> *runs = instrument.allRuns;
    if (runs.count == 0) {
        return nil;
    }
    
    NSMutableDictionary *instrumentDictionary = [NSMutableDictionary new];
    [instrumentDictionary setObject:instrument.type.uuid forKey:@"type"];
    [instrumentDictionary setObject:@(runs.count) forKey:@"runsCount"];
    
    NSMutableArray *runsParsed = [NSMutableArray new];
    for (XRRun *run in runs) {
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
            NSDictionary *parserResult = @{
                @"run": @(run.runNumber),
                @"runName": run.displayName,
                @"result": [parser parseContext:contexts withRun:run]
            };
            [runsParsed addObject:parserResult];
        } else {
            NSDictionary *parserResult = @{
                @"run": @(run.runNumber),
                @"runName": run.displayName,
                @"result": @"unsupported instrument",
                @"unsupported": @(YES)
            };
            [runsParsed addObject:parserResult];
            Print(@"Data processor has not been implemented for the instrument: %@", instrument.type.uuid);
        }
    }
    [instrumentDictionary setObject:runsParsed forKey:@"runs"];
    
    if (![instrument isKindOfClass:XRLegacyInstrument.class]) {
        [instrument.viewController instrumentWillBecomeInvalid];
        instrument.viewController = nil;
    }
    
    return instrumentDictionary;
}

@end
