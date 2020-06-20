//
//  TraceUtility.h
//  Trace2JSON
//
//  Created by Itay Brenner on 6/20/20.
//  Copyright © 2020 Itaysoft. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TraceUtility : NSObject

- (void) openDocument:(NSString *)path;
- (void) processDocument;


@end

NS_ASSUME_NONNULL_END
