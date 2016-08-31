//
//  CGRect+Center.swift
//  VisibleTapView
//
//  Created by Miles Hollingsworth on 8/29/16.
//  Copyright © 2016 Miles Hollingsworth. All rights reserved.
//

import Foundation

extension CGRect {
    var center: CGPoint {
        return CGPoint(x: width/2.0, y: height/2.0)
    }
}