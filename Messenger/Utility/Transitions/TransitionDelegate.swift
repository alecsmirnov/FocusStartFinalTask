//
//  TransitionDelegate.swift
//  Messenger
//
//  Created by Admin on 23.11.2020.
//

import UIKit

final class TransitionDelegate: NSObject {
    // MARK: Properties
    
    private let presentAnimationController: UIViewControllerAnimatedTransitioning?
    private let dismissAnimationController: UIViewControllerAnimatedTransitioning?
    
    // MARK: Initialization
    
    init(
        presentAnimationController: UIViewControllerAnimatedTransitioning?,
        dismissAnimationController: UIViewControllerAnimatedTransitioning?
    ) {
        self.presentAnimationController = presentAnimationController
        self.dismissAnimationController = dismissAnimationController
    }
}

// MARK: - UIViewControllerTransitioningDelegate

extension TransitionDelegate: UIViewControllerTransitioningDelegate {
    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController, source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        return presentAnimationController
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return dismissAnimationController
    }
}
