//
//  RuntimeHacks.swift
//  Trace2JSON
//
//  Created by Itay Brenner on 6/22/20.
//  Copyright © 2020 Itaysoft. All rights reserved.
//

import Foundation

class RuntimeHacks {
    static func getIvar<T>(instance: NSObject, name: String) -> T? {
        guard let ivar = class_getInstanceVariable(instance.classForCoder, name),
            let object = object_getIvar(instance, ivar) as? T else {
                return nil
        }
        return object
    }
}
