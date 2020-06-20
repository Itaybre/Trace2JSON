//
//  ShellCommand.m
//  Trace2JSON
//
//  Created by Itay Brenner on 6/20/20.
//  Copyright © 2020 Itaysoft. All rights reserved.
//

#import "ShellCommand.h"

@implementation ShellCommand

+ (NSString *) runCommand:(NSString *)cmd arguments:(NSArray<NSString *> *) arguments {
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = cmd;
    task.arguments = arguments;
    
    NSPipe *pipe = [[NSPipe alloc] init];
    task.standardOutput = pipe;
    
    [task launch];
    
    NSData *data = [pipe.fileHandleForReading readDataToEndOfFile];
    if([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] != nil) {
        [task terminate];
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    [task terminate];
    return @"error getting output";
}

@end
