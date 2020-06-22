//
//  PFTProcess+NSDicionary.m
//  Trace2JSON
//
//  Created by Itay Brenner on 6/20/20.
//  Copyright © 2020 Itaysoft. All rights reserved.
//

#import "PFTProcess+NSDicionary.h"

#define COULD_NOT_GET_VALUE @"Could not get value"

@implementation PFTProcess (NSDicionary)

- (NSDictionary *)dictionary {
    return @{
        @"name": self.displayName ? self.displayName : COULD_NOT_GET_VALUE,
        @"bundleIdentifier": self.bundleIdentifier ? self.bundleIdentifier : COULD_NOT_GET_VALUE
    };
}

@end
