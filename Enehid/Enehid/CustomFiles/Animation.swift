//
//  AvatarAnimation.swift
//  Enehid
//
//  Created by Edom Belayneh on 11/25/25.
//

import Foundation
import QuartzCore
import UIKit

class Animation {
    
    static func startPulseAnimation(profilePicImage: UIImageView) {
        let pulseLayer = CAShapeLayer()
        let radius = profilePicImage.frame.width / 2
        let center = CGPoint(x: profilePicImage.bounds.midX, y: profilePicImage.bounds.midY)
        let circularPath = UIBezierPath(arcCenter: center, radius: radius + 6, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        
        pulseLayer.path = circularPath.cgPath
        pulseLayer.fillColor = UIColor.systemPurple.withAlphaComponent(0.3).cgColor
        pulseLayer.position = .zero
        profilePicImage.layer.insertSublayer(pulseLayer, below: profilePicImage.layer)
        
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 0.95
        scaleAnimation.toValue = 1.25
        
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 0.6
        opacityAnimation.toValue = 0.0
        
        let group = CAAnimationGroup()
        group.animations = [scaleAnimation, opacityAnimation]
        group.duration = 1.5
        group.timingFunction = CAMediaTimingFunction(name: .easeOut)
        group.repeatCount = .infinity
        
        pulseLayer.add(group, forKey: "pulse")
    }
    
    static func addPulseAnimationAroundAvatar(profilePicImage: UIImageView) {
        let pulseLayer = CAShapeLayer()
        let radius = profilePicImage.frame.width / 2 + 10
        let center = CGPoint(x: profilePicImage.bounds.midX, y: profilePicImage.bounds.midY)

        let circularPath = UIBezierPath(arcCenter: center,
                                        radius: radius,
                                        startAngle: 0,
                                        endAngle: 2 * .pi,
                                        clockwise: true)

        pulseLayer.path = circularPath.cgPath
        pulseLayer.fillColor = UIColor.clear.cgColor
        pulseLayer.strokeColor = UIColor.systemPurple.withAlphaComponent(0.5).cgColor
        pulseLayer.lineWidth = 3
        pulseLayer.frame = profilePicImage.bounds
        profilePicImage.layer.insertSublayer(pulseLayer, below: profilePicImage.layer)

        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 1
        scaleAnimation.toValue = 1.4

        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 0.8
        opacityAnimation.toValue = 0

        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [scaleAnimation, opacityAnimation]
        animationGroup.duration = 1.5
        animationGroup.repeatCount = .infinity

        pulseLayer.add(animationGroup, forKey: "pulse")
    }

}
