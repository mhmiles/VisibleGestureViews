//
//  SwipeView.swift
//  VisibleTapView
//
//  Created by Miles Hollingsworth on 8/30/16.
//  Copyright © 2016 Miles Hollingsworth. All rights reserved.
//

import UIKit

public enum SwipeDirection {
    case left
    case right
    case up
    case down
}

private let velocity: CGFloat = 500.0

open class SwipeView: UIView {
    internal let circleLayer = CAShapeLayer()
    
    open var direction: SwipeDirection = .left
    
    fileprivate var tapWidth: CGFloat {
        return min(bounds.height, bounds.width)
    }
    
    fileprivate lazy var duration: TimeInterval = {
        switch self.direction {
        case .left:
            fallthrough
        case .right:
            return TimeInterval(self.bounds.width/velocity)
            
        case .up:
            fallthrough
        case .down:
            return TimeInterval(self.bounds.height/velocity)
        }
    }()
    
    fileprivate var swipeAnimation: CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "path")
        
        animation.fromValue = self.circleLayer.path
        
        var transform = CGAffineTransform.identity
        
        switch self.direction {
        case .right:
            transform = CGAffineTransform(translationX: bounds.width-tapWidth, y: 0)
            
        case .down:
            transform = CGAffineTransform(translationX: 0, y: bounds.height-tapWidth)
            
        default:
            break
        }
        
        let tapRect = CGRect(x: 0, y: 0, width: self.tapWidth, height: self.tapWidth)
        animation.toValue = CGPath(ellipseIn: tapRect, transform: &transform)
        
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        
        return animation
    }
    
    fileprivate lazy var fadeAnimation: CABasicAnimation = { () -> CABasicAnimation in
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
        
        var transform = CGAffineTransform.identity
        
        switch self.direction {
        case .left:
            transform = CGAffineTransform(translationX: self.bounds.width-self.tapWidth, y: 0)
            
        case .up:
            transform = CGAffineTransform(translationX: 0, y: self.bounds.height-self.tapWidth)
            
        default:
            break
        }
        
        let tapRect = CGRect(x: 0, y: 0, width: self.tapWidth, height: self.tapWidth)
        
        circleLayer.path = CGPath(ellipseIn: tapRect, transform: &transform)
        circleLayer.fillColor = tintColor?.cgColor ?? UIColor.white.cgColor
        
        layer.addSublayer(circleLayer)
        startAnimation()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        stopAnimation()
        configureCircleLayer()
    }
}

extension SwipeView: VisibleGestureView {
    @IBAction public func startAnimation() {
        circleLayer.isHidden = false
        
        if let count = circleLayer.animationKeys()?.count , count > 0 {
            return
        }
        
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = duration + 1
        animationGroup.repeatCount = .infinity
        animationGroup.animations = [swipeAnimation, fadeAnimation]
        
        circleLayer.add(animationGroup, forKey: "swipe")
    }
    
    @IBAction public func stopAnimation() {
        guard let count = circleLayer.animationKeys()?.count , count > 0 else {
            return
        }
        
        guard let presentationLayer = circleLayer.presentation() else {
            circleLayer.removeAllAnimations()
            circleLayer.isHidden = true
            
            return
        }
        
        let remainingDuration = Double(presentationLayer.opacity)*duration-0.2
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(remainingDuration*Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
            self.circleLayer.removeAllAnimations()
            self.circleLayer.isHidden = true
        }
    }
}
