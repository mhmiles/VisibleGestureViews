//
//  CGColor+Equality.swift
//  VisibleTapView
//
//  Created by Miles Hollingsworth on 8/30/16.
//  Copyright © 2016 Miles Hollingsworth. All rights reserved.
//

import CoreGraphics

extension CGColor: Equatable {

}
public func ==(lhs: CGColor, rhs: CGColor) -> Bool {
    if CGColorGetNumberOfComponents(lhs) != CGColorGetNumberOfComponents(rhs) {
        return false
    }
    
    let leftComponents = CGColorGetComponents(lhs)
    let rightComponents = CGColorGetComponents(rhs)
    
    for _ in 1..<CGColorGetNumberOfComponents(lhs) {
        if leftComponents.memory != rightComponents.memory {
            return false
        }
        
        leftComponents.advancedBy(1)
        rightComponents.advancedBy(1)
    }
    
    return true
}