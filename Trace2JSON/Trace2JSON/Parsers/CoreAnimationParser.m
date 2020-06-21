//
//  CoreAnimationParser.m
//  Trace2JSON
//
//  Created by Itay Brenner on 6/21/20.
//  Copyright © 2020 Itaysoft. All rights reserved.
//

#import "CoreAnimationParser.h"
#import "InstrumentsPrivateHeaders.h"

@implementation CoreAnimationParser

- (void)readRow:(XRAnalysisCoreReadCursor *)cursor formatter:(XREngineeringTypeFormatter *)formatter result:(NSMutableArray *)result {
    while (XRAnalysisCoreReadCursorNext(cursor)) {
        BOOL resultObject = NO;
        XRAnalysisCoreValue *object = nil;
        resultObject = XRAnalysisCoreReadCursorGetValue(cursor, 0, &object);
        NSString *timestamp = resultObject ? [formatter stringForObjectValue:object] : @"";
        resultObject = XRAnalysisCoreReadCursorGetValue(cursor, 2, &object);
        double fps = resultObject ? [object.objectValue doubleValue] : 0;
        resultObject = XRAnalysisCoreReadCursorGetValue(cursor, 3, &object);
        double gpu = resultObject ? [object.objectValue doubleValue] : 0;
        
        NSDictionary *rowValue = @{
            @"timestamp": timestamp,
            @"fps": @((int)fps),
            @"gpuUsage": @((int)gpu)
        };
        [result addObject:rowValue];
    }
}

- (id) parseContext:(NSArray<XRContext *> *) contexts withRun:(XRRun *)run {
    NSMutableArray *result = [NSMutableArray new];
    
    XRContext *context = contexts[0];
    [context display];
    XRAnalysisCoreTableViewController *controller = Ivar(context.container, _tabularViewController);
    XRAnalysisCorePivotArray *array = controller._currentResponse.content.rows;
    XREngineeringTypeFormatter *formatter = IvarCast(array.source, _filter, XRAnalysisCoreTableQuery * const).fullTextSearchSpec.formatter;
    [array access:^(XRAnalysisCorePivotArrayAccessor *accessor) {
        [accessor readRowsStartingAt:0 dimension:0 block:^(XRAnalysisCoreReadCursor *cursor) {
            [self readRow:cursor formatter:formatter result:result];
        }];
    }];
    
    return result;
}

@end
