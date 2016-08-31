//
//  VisibleTapViewTests.swift
//  VisibleTapViewTests
//
//  Created by Miles Hollingsworth on 8/29/16.
//  Copyright © 2016 Miles Hollingsworth. All rights reserved.
//

import XCTest
@testable import VisibleGestureViews

class PingTapViewTests: XCTestCase {
    let tapView = PingTapView(frame: CGRectZero)
    
    func testAnimations() {
        XCTAssertGreaterThan(tapView.ringLayer.animationKeys()!.count, 0)
    }
    
    func testTintColor() {
        XCTAssertEqual(tapView.ringLayer.strokeColor, tapView.tintColor.CGColor)
    }
    
    func testPathCenter() {
        XCTAssertEqual(tapView.ringLayer.frame.center, tapView.bounds.center)
    }
}
