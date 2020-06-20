//
//  ParserFactory.m
//  Trace2JSON
//
//  Created by Itay Brenner on 6/20/20.
//  Copyright © 2020 Itaysoft. All rights reserved.
//

#import "ParserFactory.h"

@interface ParserFactory ()
@property (nonatomic, strong) NSDictionary<NSString *,NSObject<ParserProtocol> *> *parsers;
@end

@implementation ParserFactory

- (instancetype)init {
    if (self = [super init]) {
        self.parsers = @{
        };
    }
    return self;
}

- (NSObject<ParserProtocol> *) parserForInstrument:(NSString *)instrument {
    if([self.parsers objectForKey:instrument]) {
        return [self.parsers objectForKey:instrument];
    }
    return nil;
}

@end
