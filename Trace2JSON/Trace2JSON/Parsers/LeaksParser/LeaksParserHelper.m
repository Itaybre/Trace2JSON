//
//  LeaksParser.m
//  Trace2JSON
//
//  Created by Itay Brenner on 6/20/20.
//  Copyright © 2020 Itaysoft. All rights reserved.
//

#import "LeaksParserHelper.h"
#import "LeaksHeaders.h"
#import "Trace2JSON-Swift.h"

@implementation LeaksParserHelper

- (NSArray <LeakRow *> *) getLeaksFromRun:(XRRun *)run {
    NSMutableArray<LeakRow *> *result = [NSMutableArray new];
    
    XRLeaksRun *leaksRun = (XRLeaksRun *)run;
    for (XRLeak *leak in leaksRun.allLeaks) {
        LeakRow *leakObject = [[LeakRow alloc] initWithName:leak.name != nil ? leak.name : @""
                                                 size:@(leak.size)
                                                count:@(leak.count)
                                              isCycle:leak.inCycle
                                           isRootLeak:leak.isRootLeak
                                  allocationTimeStamp:@(leak.allocationTimestamp)];
        
        [result addObject:leakObject];
    }
    
    return result;
}

@end
