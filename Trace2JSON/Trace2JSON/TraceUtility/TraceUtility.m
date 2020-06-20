//
//  TraceUtility.m
//  Trace2JSON
//
//  Created by Itay Brenner on 6/20/20.
//  Copyright © 2020 Itaysoft. All rights reserved.
//

#import "TraceUtility.h"
#import "InstrumentsPrivateHeaders.h"

@interface TraceUtility ()
@property (nonatomic, strong) PFTTraceDocument *document;
@end

@implementation TraceUtility

- (void) openDocument:(NSString *)path {
    NSError *error = nil;
    self.document = [[PFTTraceDocument alloc]initWithContentsOfURL:[NSURL fileURLWithPath:path] ofType:@"com.apple.instruments.trace" error:&error];
    if (error) {
        NSLog(@"Error: %@\n", error);
        exit(1);
    }
    NSLog(@"Trace: %@\n", path);
}

- (void) processDocument {
    
}

@end
