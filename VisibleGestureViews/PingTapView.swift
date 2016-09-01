//
//  PingTapView.swift
//  PingTapView
//
//  Created by Miles Hollingsworth on 8/29/16.
//  Copyright © 2016 Miles Hollingsworth. All rights reserved.
//

import UIKit

private let duration = 2.0

open class PingTapView: UIView {
    internal let ringLayer = CAShapeLayer()
    
    fileprivate lazy var expansionAnimation: CABasicAnimation = { () -> CABasicAnimation in
        let animation = CABasicAnimation(keyPath: "path")
        let centerRect = CGRect(origin: self.bounds.center, size: CGSize.zero)
        
        animation.fromValue = CGPath(ellipseIn: centerRect, transform: nil)
        animation.toValue = CGPath(ellipseIn: centerRect.insetBy(dx: -40.0, dy: -40.0), transform: nil)
        animation.duration = duration
        
        return animation
    }()
    
    fileprivate lazy var fadeAnimation: CABasicAnimation = { () -> CABasicAnimation in
        let animation = CABasicAnimation(keyPath: "opacity")
        
        animation.fromValue = 1.0
        animation.toValue = 0.0
        animation.duration = duration
        
        return animation
    }()
    
    fileprivate lazy var thinningAnimation: CABasicAnimation = { () -> CABasicAnimation in
        let animation = CABasicAnimation(keyPath: "lineWidth")
        
        animation.fromValue = 4.0
        animation.toValue = 0.0
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        return animation
    }()
    
    public convenience init() {
        self.init(frame: CGRect.zero)
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

        ringLayer.fillColor = UIColor.clear.cgColor
        ringLayer.strokeColor = tintColor?.cgColor ?? UIColor.white.cgColor
        
        layer.addSublayer(ringLayer)
        startAnimation()
    }
}

extension PingTapView: VisibleGestureView {
    @IBAction public func startAnimation() {
        if let count = ringLayer.animationKeys()?.count , count > 0 {
            return
        }
        
        let animationGroup = CAAnimationGroup()
        animationGroup.repeatCount = .infinity
        animationGroup.duration = duration
        animationGroup.animations = [expansionAnimation, fadeAnimation, thinningAnimation]
        
        ringLayer.add(animationGroup, forKey: "ping")
    }
    
    @IBAction public func stopAnimation() {
        guard let count = ringLayer.animationKeys()?.count , count > 0 else {
            return
        }
        
        let presentationLayer = ringLayer.presentation()
        let remainingDuration = Double(presentationLayer!.opacity)*duration-0.2
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(remainingDuration*Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
            self.ringLayer.removeAllAnimations()
        }
    }
}
