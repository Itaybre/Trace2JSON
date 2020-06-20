//
//  PrefixHeader.h
//  Trace2JSON
//
//  Created by Itay Brenner on 6/20/20.
//  Copyright © 2020 Itaysoft. All rights reserved.
//

#ifndef PrefixHeader_h
#define PrefixHeader_h

#import <objc/runtime.h>

#define Print(format, ...) CFShow((__bridge CFStringRef)[NSString stringWithFormat:format, ## __VA_ARGS__])
#define IvarCast(object, name, type) (*(type *)(void *)&((char *)(__bridge void *)object)[ivar_getOffset(class_getInstanceVariable(object_getClass(object), #name))])
#define Ivar(object, name) IvarCast(object, name, id const)

#endif /* PrefixHeader_h */
