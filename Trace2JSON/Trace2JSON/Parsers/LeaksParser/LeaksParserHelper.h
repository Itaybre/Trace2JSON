//
//  LeaksParser.h
//  Trace2JSON
//
//  Created by Itay Brenner on 6/20/20.
//  Copyright © 2020 Itaysoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InstrumentsPrivateHeaders.h"

NS_ASSUME_NONNULL_BEGIN

@class LeakRow;

@interface LeaksParserHelper : NSObject

- (NSArray <LeakRow *> *) getLeaksFromRun:(XRRun *)run;

@end

NS_ASSUME_NONNULL_END
