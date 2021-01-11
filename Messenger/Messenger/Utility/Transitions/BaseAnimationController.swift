//
//  BaseAnimationController.swift
//  Messenger
//
//  Created by Admin on 24.11.2020.
//

import UIKit

class BaseAnimationController: NSObject {
    // MARK: Properties
    
    enum AnimationType {
        case present
        case dismiss
    }
    
    let duration: TimeInterval
    let animationType: AnimationType

    // MARK: Initialization
    
    init(duration: TimeInterval, animationType: AnimationType) {
        self.duration = duration
        self.animationType = animationType
    }
    
    // MARK: Overridden Methods
    
    func startPresentAnimation(transitionContext: UIViewControllerContextTransitioning) {
        fatalError("must be override")
    }

    func startDismissAnimation(transitionContext: UIViewControllerContextTransitioning) {
        fatalError("must be override")
    }
}

// MARK: - Private Methods

private extension BaseAnimationController {
    func selectAnimation(transitionContext: UIViewControllerContextTransitioning) {
        switch animationType {
        case .present: startPresentAnimation(transitionContext: transitionContext)
        case .dismiss: startDismissAnimation(transitionContext: transitionContext)
        }
    }
}

// MARK: - UIViewControllerAnimatedTransitioning

extension BaseAnimationController: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        selectAnimation(transitionContext: transitionContext)
    }
}
