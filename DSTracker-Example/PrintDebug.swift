//
//  PrintDebug.swift
//  DriveSmart
//
//  Created by David Jardon on 8/6/17.
//  Copyright © 2017 DriveSmart. All rights reserved.
//
//  Override print method to log only in debug mode
//

import Foundation

func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
        Swift.print(items, separator:separator, terminator: terminator)
    #endif
}
