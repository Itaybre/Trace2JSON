//
//  LeaksHeaders.h
//  Trace2JSON
//
//  Created by Itay Brenner on 6/22/20.
//  Copyright © 2020 Itaysoft. All rights reserved.
//

#import "InstrumentsPrivateHeaders.h"

#ifndef LeaksHeaders_h
#define LeaksHeaders_h

@interface DVT_VMUClassInfo : NSObject
- (NSString *)remoteClassName;
- (NSString *)genericInfo;
- (UInt32)instanceSize;
@end

@interface XRLeak : NSObject
- (NSString *) name;
- (unsigned long) size;
- (unsigned long) count;
- (BOOL) inCycle;
- (BOOL) isRootLeak;
- (unsigned long long) allocationTimestamp;
- (NSString *) displayAddress;
- (DVT_VMUClassInfo *) classInfo;
- (DVT_VMUClassInfo *) _layout;
@end

@interface XRLeaksRun : XRRun
- (NSArray <XRLeak *>*)allLeaks;
@end

#endif /* LeaksHeaders_h */
