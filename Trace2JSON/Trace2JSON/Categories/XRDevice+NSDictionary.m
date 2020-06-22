//
//  XRDevice+NSDictionary.m
//  Trace2JSON
//
//  Created by Itay Brenner on 6/20/20.
//  Copyright © 2020 Itaysoft. All rights reserved.
//

#import "XRDevice+NSDictionary.h"

#define COULD_NOT_GET_VALUE @"Could not get value"

@implementation XRDevice (NSDictionary)

- (NSDictionary *) dictionary {
    return @{
        @"displayName": self.deviceDisplayName ? self.deviceDisplayName : COULD_NOT_GET_VALUE,
        @"productType": self.productType ? self.productType : COULD_NOT_GET_VALUE,
        @"productVersion": self.productVersion ? self.productVersion : COULD_NOT_GET_VALUE,
        @"buildVersion": self.buildVersion ? self.buildVersion : COULD_NOT_GET_VALUE
    };
}

@end
