//
//  PFTProcess+NSDicionary.m
//  Trace2JSON
//
//  Created by Itay Brenner on 6/20/20.
//  Copyright © 2020 Itaysoft. All rights reserved.
//

#import "PFTProcess+NSDicionary.h"

@implementation PFTProcess (NSDicionary)

- (NSDictionary *)dictionary {
    return @{
        @"name": self.displayName,
        @"bundleIdentifier": self.bundleIdentifier
    };
}

@end
