//
//  PingTapView.swift
//  PingTapView
//
//  Created by Miles Hollingsworth on 8/29/16.
//  Copyright © 2016 Miles Hollingsworth. All rights reserved.
//

import UIKit

private let duration = 2.0

public class PingTapView: UIView {
    internal let ringLayer = CAShapeLayer()
    
    private lazy var expansionAnimation: CABasicAnimation = { () -> CABasicAnimation in
        let animation = CABasicAnimation(keyPath: "path")
        let centerRect = CGRect(origin: self.bounds.center, size: CGSizeZero)
        
        animation.fromValue = CGPathCreateWithEllipseInRect(centerRect, nil)
        animation.toValue = CGPathCreateWithEllipseInRect(CGRectInset(centerRect, -40.0, -40.0), nil)
        animation.duration = duration
        
        return animation
    }()
    
    private lazy var fadeAnimation: CABasicAnimation = { () -> CABasicAnimation in
        let animation = CABasicAnimation(keyPath: "opacity")
        
        animation.fromValue = 1.0
        animation.toValue = 0.0
        animation.duration = duration
        
        return animation
    }()
    
    private lazy var thinningAnimation: CABasicAnimation = { () -> CABasicAnimation in
        let animation = CABasicAnimation(keyPath: "lineWidth")
        
        animation.fromValue = 4.0
        animation.toValue = 0.0
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        return animation
    }()
    
    public convenience init() {
        self.init(frame: CGRectZero)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    
        configureRingLayer()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        configureRingLayer()
    }
    
    internal func configureRingLayer() {
        clipsToBounds = false

        ringLayer.fillColor = UIColor.clearColor().CGColor
        ringLayer.strokeColor = tintColor?.CGColor ?? UIColor.whiteColor().CGColor
        
        layer.addSublayer(ringLayer)
        startAnimation()
    }
}

extension PingTapView: VisibleGestureView {
    @IBAction public func startAnimation() {
        if let count = ringLayer.animationKeys()?.count where count == 0 {
            return
        }
        
        let animationGroup = CAAnimationGroup()
        animationGroup.repeatCount = .infinity
        animationGroup.duration = duration
        animationGroup.animations = [expansionAnimation, fadeAnimation, thinningAnimation]
        
        ringLayer.addAnimation(animationGroup, forKey: "ping")
    }
    
    @IBAction public func stopAnimation() {
        guard let count = ringLayer.animationKeys()?.count where count > 0 else {
            return
        }
        
        let presentationLayer = ringLayer.presentationLayer() as! CAShapeLayer
        let remainingDuration = Double(presentationLayer.opacity)*duration-0.2
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(remainingDuration*Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            self.ringLayer.removeAllAnimations()
        }
        
        print("Stop")
    }
}