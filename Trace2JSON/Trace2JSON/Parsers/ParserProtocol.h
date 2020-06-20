//
//  ParserProtocol.h
//  Trace2JSON
//
//  Created by Itay Brenner on 6/20/20.
//  Copyright © 2020 Itaysoft. All rights reserved.
//

#ifndef ParserProtocol_h
#define ParserProtocol_h

@class XRContext;
@class XRRun;
@class NSArray;

@protocol ParserProtocol <NSObject>

- (void) parseContext:(NSArray<XRContext *> *) contexts withRun:(XRRun *)run;

@end

#endif /* ParserProtocol_h */
