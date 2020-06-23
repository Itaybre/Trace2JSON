//
//  AllocationsParserHelper.h
//  trace2json
//
//  Created by Itay Brenner on 6/23/20.
//  Copyright © 2020 Itaysoft. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class AllocationsRow;
@class XRInstrument;

@interface AllocationsParserHelper : NSObject

- (NSArray <AllocationsRow *> *) getAllocationsFromInstrument:(XRInstrument *)instrument;

@end

NS_ASSUME_NONNULL_END
