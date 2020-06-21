//
//  ActivityMonitorParser.m
//  Trace2JSON
//
//  Created by Itay Brenner on 6/20/20.
//  Copyright © 2020 Itaysoft. All rights reserved.
//

#import "ActivityMonitorParser.h"
#import "InstrumentsPrivateHeaders.h"

@implementation ActivityMonitorParser

- (NSString *) instrumentName {
    return @"Activity Monitor";
}

- (void)readRow:(XRAnalysisCoreReadCursor *)cursor formatter:(XREngineeringTypeFormatter *)formatter result:(NSMutableDictionary *)result {
    while (XRAnalysisCoreReadCursorNext(cursor)) {
        BOOL objectFound = NO;
        XRAnalysisCoreValue *object = nil;
        objectFound = XRAnalysisCoreReadCursorGetValue(cursor, 0, &object);
        NSString *time = objectFound ? [formatter stringForObjectValue:object] : @"";
        objectFound = XRAnalysisCoreReadCursorGetValue(cursor, 2, &object);
        NSString *process = objectFound ? [formatter stringForObjectValue:object] : @"";
        objectFound = XRAnalysisCoreReadCursorGetValue(cursor, 6, &object);
        NSString *cpu = objectFound ? [formatter stringForObjectValue:object] : @"";
        objectFound = XRAnalysisCoreReadCursorGetValue(cursor, 10, &object);
        NSString *memory = objectFound ? [formatter stringForObjectValue:object] : @"";
        objectFound = XRAnalysisCoreReadCursorGetValue(cursor, 8, &object);
        NSString *threads = objectFound ? [formatter stringForObjectValue:object] : @"";
        
        NSMutableDictionary *processDictionary = nil;
        if([result objectForKey:process]) {
            processDictionary = [result objectForKey:process];
        } else {
            processDictionary = [NSMutableDictionary new];
        }
        
        NSDictionary *rowDict = @{
            @"cpu": cpu,
            @"threads": threads,
            @"memory": memory
        };
        [processDictionary setObject:rowDict forKey:time];
        
        [result setObject:processDictionary forKey:process];
    }
}

- (id) parseContext:(NSArray<XRContext *> *) contexts withRun:(XRRun *)run {
    NSMutableDictionary *result = [NSMutableDictionary new];
    
    XRContext *context = contexts[0];
    [context display];
    XRAnalysisCoreTableViewController *controller = Ivar(context.container, _tabularViewController);
    XRTime duration = run.timeRange.length;
    for (XRTime time = 0; time < duration; time += NSEC_PER_SEC) {
        [controller setDocumentInspectionTime:time];
        [controller _retrieveResponse];
        XRAnalysisCorePivotArray *array = controller._currentResponse.content.rows;
        if (array) {
            XREngineeringTypeFormatter *formatter = IvarCast(array.source, _filter, XRAnalysisCoreTableQuery * const).fullTextSearchSpec.formatter;
            [array access:^(XRAnalysisCorePivotArrayAccessor *accessor) {
                [accessor readRowsStartingAt:0 dimension:0 block:^(XRAnalysisCoreReadCursor *cursor) {
                    [self readRow:cursor formatter:formatter result:result];
                }];
            }];
        }
    }
    
    
    
    return result;
}

@end
