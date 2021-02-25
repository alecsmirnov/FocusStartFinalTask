//
//  SlideAnimationController.swift
//  Messenger
//
//  Created by Admin on 23.11.2020.
//

import UIKit

final class SlideAnimationController: BaseAnimationController {
    override func startPresentAnimation(transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromViewController = transitionContext.viewController(forKey: .from),
            let toViewController = transitionContext.viewController(forKey: .to),
            let fromView = fromViewController.view,
            let toView = toViewController.view
        else {
            return
        }
        
        let containerView = transitionContext.containerView
        let containerViewHeight = containerView.bounds.size.height

        setupPresentationLayout(containerView: containerView, toView: toView)
        
        containerView.window?.backgroundColor = .systemBackground
        toView.center.y = containerView.center.y - containerViewHeight
        
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0,
            options: [.curveEaseInOut]) {
            fromView.center.y -= containerViewHeight
            toView.center.y -= containerViewHeight
        } completion: { finished in
            transitionContext.completeTransition(finished)
        }
    }
    
    override func startDismissAnimation(transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromViewController = transitionContext.viewController(forKey: .from),
            let toViewController = transitionContext.viewController(forKey: .to),
            let fromView = fromViewController.view,
            let toView = toViewController.view
        else {
            return
        }
        
        let containerView = transitionContext.containerView
        let containerViewHeight = containerView.bounds.size.height
        containerView.window?.backgroundColor = .clear
        
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0,
            options: [.curveEaseInOut]) {
            fromView.center.y += containerViewHeight
            toView.center.y += containerViewHeight
        } completion: { finished in
            containerView.window?.backgroundColor = .clear
            
            fromView.removeFromSuperview()
            
            transitionContext.completeTransition(finished)
        }
    }
}

// MARK: - Layout

private extension SlideAnimationController {
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
