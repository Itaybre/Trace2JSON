//
//  ConnectionsParser.m
//  Trace2JSON
//
//  Created by Itay Brenner on 6/21/20.
//  Copyright © 2020 Itaysoft. All rights reserved.
//

#import "ConnectionsParser.h"
#import "InstrumentsPrivateHeaders.h"

@implementation ConnectionsParser

- (void)readRow:(XRAnalysisCoreReadCursor *)cursor formatter:(XREngineeringTypeFormatter *)formatter result:(NSMutableArray *)result {
    while (XRAnalysisCoreReadCursorNext(cursor)) {
        BOOL resultObject = NO;
        XRAnalysisCoreValue *object = nil;
        resultObject = XRAnalysisCoreReadCursorGetValue(cursor, 0, &object);
        NSString *time = resultObject ? [formatter stringForObjectValue:object] : @"";
        resultObject = XRAnalysisCoreReadCursorGetValue(cursor, 3, &object);
        NSString *process = resultObject ? [formatter stringForObjectValue:object] : @"";
        resultObject = XRAnalysisCoreReadCursorGetValue(cursor, 4, &object);
        NSString *interface = resultObject ? [formatter stringForObjectValue:object] : @"";
        resultObject = XRAnalysisCoreReadCursorGetValue(cursor, 5, &object);
        NSString *protocol = resultObject ? [formatter stringForObjectValue:object] : @"";
        resultObject = XRAnalysisCoreReadCursorGetValue(cursor, 6, &object);
        NSString *local = resultObject ? [formatter stringForObjectValue:object] : @"";
        resultObject = XRAnalysisCoreReadCursorGetValue(cursor, 7, &object);
        NSString *remote = resultObject ? [formatter stringForObjectValue:object] : @"";
        resultObject = XRAnalysisCoreReadCursorGetValue(cursor, 9, &object);
        NSString *packetsIn = resultObject ? [formatter stringForObjectValue:object] : @"";
        resultObject = XRAnalysisCoreReadCursorGetValue(cursor, 10, &object);
        NSString *bytesIn = resultObject ? [formatter stringForObjectValue:object] : @"";
        resultObject = XRAnalysisCoreReadCursorGetValue(cursor, 11, &object);
        NSString *packetsOut = resultObject ? [formatter stringForObjectValue:object] : @"";
        resultObject = XRAnalysisCoreReadCursorGetValue(cursor, 12, &object);
        NSString *bytesOut = resultObject ? [formatter stringForObjectValue:object] : @"";
        resultObject = XRAnalysisCoreReadCursorGetValue(cursor, 16, &object);
        NSString *minRTT = resultObject ? [formatter stringForObjectValue:object] : @"";
        resultObject = XRAnalysisCoreReadCursorGetValue(cursor, 17, &object);
        NSString *avgRTT = resultObject ? [formatter stringForObjectValue:object] : @"";
        
        NSDictionary *rowValue = @{
            @"timestamp": time,
            @"process": process,
            @"interface": interface,
            @"protocol": protocol,
            @"local": local,
            @"remote": remote,
            @"packetsIn": packetsIn,
            @"bytesIn": bytesIn,
            @"packetsOut": packetsOut,
            @"bytesOut": bytesOut,
            @"minRTT": minRTT,
            @"avgRTT": avgRTT,
        };
        [result addObject:rowValue];
    }
}

- (id) parseContext:(NSArray<XRContext *> *) contexts withRun:(XRRun *)run {
    XRContext *context = contexts[2];
    [context display];
    XRAnalysisCoreTableViewController *controller = Ivar(context.container, _tabularViewController);
    XRAnalysisCorePivotArray *array = controller._currentResponse.content.rows;
    if (!array) {
        return nil;
    }
    
    NSMutableArray *result = [NSMutableArray new];
    
    XREngineeringTypeFormatter *formatter = IvarCast(array.source, _filter, XRAnalysisCoreTableQuery * const).fullTextSearchSpec.formatter;
    [array access:^(XRAnalysisCorePivotArrayAccessor *accessor) {
        [accessor readRowsStartingAt:0 dimension:0 block:^(XRAnalysisCoreReadCursor *cursor) {
            [self readRow:cursor formatter:formatter result:result];
        }];
    }];
    
    return result;
}

@end
