//
//  main.m
//  Trace2JSON
//
//  Created by Itay Brenner on 6/20/20.
//  Copyright © 2020 Itaysoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "ShellCommand.h"
#import "Instruments.h"
#import "TraceUtility.h"

// Workaround to fix search paths for Instruments plugins and packages.
static NSBundle *(*NSBundle_mainBundle_original)(id self, SEL _cmd);
static NSBundle *NSBundle_mainBundle_replaced(id self, SEL _cmd) {
    // Get Xcode Path
    NSString *path = [ShellCommand runCommand:@"/usr/bin/xcode-select" arguments:@[@"-p"]];
    path = [path stringByDeletingLastPathComponent];
    path = [path stringByAppendingString:@"/Applications/Instruments.app"];
    return [NSBundle bundleWithPath:path];
}

static void __attribute__((constructor)) hook() {
    Method NSBundle_mainBundle = class_getClassMethod(NSBundle.class, @selector(mainBundle));
    NSBundle_mainBundle_original = (void *)method_getImplementation(NSBundle_mainBundle);
    method_setImplementation(NSBundle_mainBundle, (IMP)NSBundle_mainBundle_replaced);
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        [Instruments loadPlugins];
        
        NSArray<NSString *> *arguments = NSProcessInfo.processInfo.arguments;
        if (arguments.count < 2) {
            Print(@"Usage: %@ [%@]\n", arguments.firstObject.lastPathComponent, @"trace document");
            return 1;
        }
        
        NSString *tracePath = arguments[1];
        TraceUtility *utility = [[TraceUtility alloc] init];
        // Open Trace Document
        [utility openDocument:tracePath];
        // Process it
        [utility processDocument];
        
        [Instruments unloadPlugins];
    }
    return 0;
}
