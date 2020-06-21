//
//  LeaksParser.m
//  Trace2JSON
//
//  Created by Itay Brenner on 6/20/20.
//  Copyright © 2020 Itaysoft. All rights reserved.
//

#import "LeaksParser.h"
#import "InstrumentsPrivateHeaders.h"

@implementation LeaksParser

- (NSString *) instrumentName {
    return @"Leaks";
}

- (NSDictionary *) parseContext:(NSArray<XRContext *> *) contexts withRun:(XRRun *)run {
    NSMutableArray *result = [NSMutableArray new];
    
    XRLeaksRun *leaksRun = (XRLeaksRun *)run;
    for (XRLeak *leak in leaksRun.allLeaks) {
        DVT_VMUClassInfo *dvt = Ivar(leak, _layout);
        
        NSDictionary *parsedLeak = @{
            @"name": leak.name != nil ? leak.name : @"",
            @"description": dvt != nil && dvt.description ? dvt.description : @"",
            @"size": @(leak.size),
            @"count": @(leak.count),
            @"isCycle": @(leak.inCycle),
            @"isRootLeak": @(leak.isRootLeak),
            @"allocationTimestamp": @(leak.allocationTimestamp),
            @"displayAddress": leak.displayAddress != nil ? leak.displayAddress : @"",
            @"debugDescription": dvt != nil && dvt.debugDescription ? dvt.debugDescription : @"",
        };
        
        [result addObject:parsedLeak];
    }
    
    NSDictionary *returnDictionary = @{
        @"type": [self instrumentName],
        @"result": result
    };
    return returnDictionary;
}

@end
