//
//  ZoomAnimationController.swift
//  Messenger
//
//  Created by Admin on 24.11.2020.
//

import UIKit

final class ZoomAnimationController: BaseAnimationController {
    // MARK: Properties
    
    private enum Scales {
        static let min = CGPoint(x: 0, y: 0)
        static let max = CGPoint(x: 1, y: 1)
        
        static let bounce = CGPoint(x: 1.1, y: 1.1)
    }
    
    private enum Opacities {
        static let min: CGFloat = 0.6
        static let max: CGFloat = 1
    }
    
    // MARK: Methods
    
    override func startPresentAnimation(transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: .from),
              let toViewController = transitionContext.viewController(forKey: .to),
              let fromView = fromViewController.view,
              let toView = toViewController.view else { return }
        
        let containerView = transitionContext.containerView
        containerView.window?.backgroundColor = .systemBackground
        
        setupPresentationLayout(containerView: containerView, toView: toView)
        
        toView.transform = CGAffineTransform(scaleX: Scales.min.x, y: Scales.min.y)
        toView.alpha = Opacities.max
        
        UIView.animateKeyframes(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0,
            options: .calculationModeCubic
        ) {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.4) {
                fromView.transform = CGAffineTransform(scaleX: Scales.min.x, y: Scales.min.x)
                fromView.alpha = Opacities.min
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0.41, relativeDuration: 0.8) {
                toView.transform = CGAffineTransform(scaleX: Scales.bounce.x, y: Scales.bounce.x)
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0.81, relativeDuration: 1) {
                toView.transform = CGAffineTransform(scaleX: Scales.max.x, y: Scales.max.x)
            }
        } completion: { finished in
            transitionContext.completeTransition(finished)
        }
    }
    
    override func startDismissAnimation(transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: .from),
              let toViewController = transitionContext.viewController(forKey: .to),
              let fromView = fromViewController.view,
              let toView = toViewController.view else { return }
        
        toView.transform = CGAffineTransform(scaleX: Scales.min.x, y: Scales.min.y)
        toView.alpha = Opacities.max
        
        UIView.animateKeyframes(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0,
            options: .calculationModeCubic
        ) {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.4) {
                fromView.transform = CGAffineTransform(scaleX: Scales.min.x, y: Scales.min.x)
                fromView.alpha = Opacities.min
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0.41, relativeDuration: 0.8) {
                toView.transform = CGAffineTransform(scaleX: Scales.bounce.x, y: Scales.bounce.x)
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0.81, relativeDuration: 1) {
                toView.transform = CGAffineTransform(scaleX: Scales.max.x, y: Scales.max.x)
            }
        } completion: { finished in
            let containerView = transitionContext.containerView
            containerView.window?.backgroundColor = .clear
            
            fromView.removeFromSuperview()
            
            transitionContext.completeTransition(finished)
        }
    }
}

// MARK: - Layout

private extension ZoomAnimationController {
    func setupPresentationLayout(containerView: UIView, toView: UIView) {
        containerView.addSubview(toView)
        
        toView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            toView.topAnchor.constraint(equalTo: containerView.topAnchor),
            toView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            toView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            toView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
        ])
    }
}
