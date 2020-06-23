//
//  AllocationsParserHelper.m
//  trace2json
//
//  Created by Itay Brenner on 6/23/20.
//  Copyright © 2020 Itaysoft. All rights reserved.
//

#import "AllocationsParserHelper.h"
#import "AllocationsHeaders.h"
#import <objc/runtime.h>
#import "trace2json-Swift.h"

#define IvarCast(object, name, type) (*(type *)(void *)&((char *)(__bridge void *)object)[ivar_getOffset(class_getInstanceVariable(object_getClass(object), #name))])
#define Ivar(object, name) IvarCast(object, name, id const)

@implementation AllocationsParserHelper

- (NSArray <AllocationsRow *> *) getAllocationsFromInstrument:(XRInstrument *)instrument {
    NSMutableArray<AllocationsRow *> *result = [NSMutableArray new];
    
    XRObjectAllocInstrument *allocInstrument = (XRObjectAllocInstrument *)instrument;
    // 4 contexts: Statistics, Call Trees, Allocations List, Generations.
    [allocInstrument._topLevelContexts[2] display];
    XRManagedEventArrayController *arrayController = Ivar(Ivar(allocInstrument, _objectListController), _ac);
    NSMutableDictionary<NSNumber *, NSNumber *> *sizeGroupedByTime = [NSMutableDictionary dictionary];
    for (XRObjectAllocEvent *event in arrayController.arrangedObjects) {
        NSNumber *time = @(event.timestamp / NSEC_PER_SEC);
        NSNumber *size = @(sizeGroupedByTime[time].integerValue + event.size);
        sizeGroupedByTime[time] = size;
    }
    NSSortDescriptor *highestToLowest = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
    NSArray<NSNumber *> *sortedTime = [sizeGroupedByTime.allKeys sortedArrayUsingDescriptors:@[highestToLowest]];
    
    NSByteCountFormatter *byteFormatter = [[NSByteCountFormatter alloc]init];
    byteFormatter.countStyle = NSByteCountFormatterCountStyleBinary;
    for (NSNumber *time in sortedTime) {
        NSString *size = [byteFormatter stringForObjectValue:sizeGroupedByTime[time]];
        
        AllocationsRow *row = [[AllocationsRow alloc] initWithTime:time.doubleValue
                                                              size:sizeGroupedByTime[time].integerValue
                                                     formattedSize:size];
        [result addObject:row];
    }
    
    return result;
}

@end
