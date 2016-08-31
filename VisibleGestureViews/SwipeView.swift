//
//  SwipeView.swift
//  VisibleTapView
//
//  Created by Miles Hollingsworth on 8/30/16.
//  Copyright © 2016 Miles Hollingsworth. All rights reserved.
//

import UIKit

public enum SwipeDirection {
    case Left
    case Right
    case Up
    case Down
}

private let velocity: CGFloat = 500.0

public class SwipeView: UIView {
    internal let circleLayer = CAShapeLayer()
    
    public var direction: SwipeDirection = .Left
    
    private var tapWidth: CGFloat {
        return min(bounds.height, bounds.width)
    }
    
    private lazy var duration: NSTimeInterval = {
        switch self.direction {
        case .Left:
            fallthrough
        case .Right:
            return NSTimeInterval(self.bounds.width/velocity)
            
        case .Up:
            fallthrough
        case .Down:
            return NSTimeInterval(self.bounds.height/velocity)
        }
    }()
    
    private var swipeAnimation: CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "path")
        
        animation.fromValue = self.circleLayer.path
        
        var transform = CGAffineTransformIdentity
        
        switch self.direction {
        case .Right:
            transform = CGAffineTransformMakeTranslation(bounds.width-tapWidth, 0)
            
        case .Down:
            transform = CGAffineTransformMakeTranslation(0, bounds.height-tapWidth)
            
        default:
            break
        }
        
        let tapRect = CGRect(x: 0, y: 0, width: self.tapWidth, height: self.tapWidth)
        animation.toValue = CGPathCreateWithEllipseInRect(tapRect, &transform)
        
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        
        return animation
    }
    
    private lazy var fadeAnimation: CABasicAnimation = { () -> CABasicAnimation in
        let animation = CABasicAnimation(keyPath: "opacity")
        
        animation.fromValue = 1.0
        animation.toValue = 0.0
        animation.duration = self.duration
        animation.fillMode = kCAFillModeForwards
        
        return animation
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureCircleLayer()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        configureCircleLayer()
    }
    
    internal func configureCircleLayer() {
        clipsToBounds = false
        
        var transform = CGAffineTransformIdentity
        
        switch self.direction {
        case .Left:
            transform = CGAffineTransformMakeTranslation(self.bounds.width-self.tapWidth, 0)
            
        case .Up:
            transform = CGAffineTransformMakeTranslation(0, self.bounds.height-self.tapWidth)
            
        default:
            break
        }
        
        let tapRect = CGRect(x: 0, y: 0, width: self.tapWidth, height: self.tapWidth)
        
        circleLayer.path = CGPathCreateWithEllipseInRect(tapRect, &transform)
        circleLayer.fillColor = tintColor?.CGColor ?? UIColor.whiteColor().CGColor
        
        layer.addSublayer(circleLayer)
        startAnimation()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        stopAnimation()
        configureCircleLayer()
    }
}

extension SwipeView: VisibleGestureView {
    @IBAction public func startAnimation() {
        circleLayer.hidden = false
        
        if let count = circleLayer.animationKeys()?.count where count > 0 {
            return
        }
        
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = duration + 1
        animationGroup.repeatCount = .infinity
        animationGroup.animations = [swipeAnimation, fadeAnimation]
        
        circleLayer.addAnimation(animationGroup, forKey: "swipe")
    }
    
    @IBAction public func stopAnimation() {
        guard let presentationLayer = circleLayer.presentationLayer() as? CAShapeLayer else {
            circleLayer.removeAllAnimations()
            circleLayer.hidden = true
            
            return
        }
        
        let remainingDuration = Double(presentationLayer.opacity)*duration-0.2
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(remainingDuration*Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            self.circleLayer.removeAllAnimations()
            self.circleLayer.hidden = true
        }
    }
}