//
//  XRDevice+NSDictionary.m
//  Trace2JSON
//
//  Created by Itay Brenner on 6/20/20.
//  Copyright © 2020 Itaysoft. All rights reserved.
//

#import "XRDevice+NSDictionary.h"

@implementation XRDevice (NSDictionary)

- (NSDictionary *) dictionary {
    return @{
        @"displayName": self.deviceDisplayName,
        @"productType": self.productType,
        @"productVersion": self.productVersion,
        @"buildVersion": self.buildVersion
    };
}

@end
