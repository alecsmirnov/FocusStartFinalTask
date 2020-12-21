//
//  MenuChatsViewController.swift
//  Messenger
//
//  Created by Admin on 18.12.2020.
//

import UIKit

final class MenuChatsViewController: UIViewController {
    // MARK: Properties
    
    private enum Constants {
        static let showAnimationDuration = 0.4
        static let hideAnimationDuration = 0.3
        
        static let rightOffset: CGFloat = 80
        
        static let chatsViewOpacity: CGFloat = 0.4
    }
    
    private var isExtend = false
    private var menuWidth: CGFloat = 0
    
    var chatsNavigationController: UINavigationController?
    var menuViewController: MenuViewController?
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAppearance()
        setupChatsNavigationController()
        setupMenuViewController()
    }
}

// MARK: - Public Methods

extension MenuChatsViewController {
    func extendMenu(completion: (() -> Void)? = nil) {
        if isExtend {
            hideMenu(completion: completion)
        } else {
            showMenu(completion: completion)
        }
        
        isExtend.toggle()
    }
}

// MARK: - Private Methods

private extension MenuChatsViewController {
    func showMenu(completion: (() -> Void)?) {
        guard let chatsNavigationController = chatsNavigationController,
              let menuViewController = menuViewController else { return }
        
        menuViewController.view.isHidden = false
        
        menuViewController.view.frame.origin.x = -menuWidth
        chatsNavigationController.view.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: Constants.showAnimationDuration,
                       delay: 0,
                       options: [.curveEaseOut]) {
            menuViewController.view.frame.origin.x = 0
            
            chatsNavigationController.view.frame.origin.x = self.menuWidth
            chatsNavigationController.view.alpha = Constants.chatsViewOpacity
            
            self.view.backgroundColor = .black
        } completion: { _ in
            completion?()
        }
    }
    
    func hideMenu(completion: (() -> Void)?) {
        guard let chatsNavigationController = chatsNavigationController,
              let menuViewController = menuViewController else { return }
        
        chatsNavigationController.view.isUserInteractionEnabled = true
        
        UIView.animate(withDuration: Constants.hideAnimationDuration,
                       delay: 0,
                       options: [.curveEaseOut]) {
            menuViewController.view.frame.origin.x = -self.menuWidth
            
            chatsNavigationController.view.frame.origin.x = 0
            chatsNavigationController.view.alpha = 1
        } completion: { _ in
            menuViewController.view.isHidden = true
            
            completion?()
        }
    }
}

// MARK: - Appearance

private extension MenuChatsViewController {
    func setupAppearance() {
        if let chatsNavigationController = chatsNavigationController {
            chatsNavigationController.navigationBar.isTranslucent = false
            
            menuWidth = chatsNavigationController.view.frame.size.width - Constants.rightOffset
        }
    }
}

// MARK: - Layout

private extension MenuChatsViewController {
    func setupChatsNavigationController() {
        if let chatsNavigationController = chatsNavigationController {
            view.addSubview(chatsNavigationController.view)
            addChild(chatsNavigationController)
            
            chatsNavigationController.didMove(toParent: self)
        }
    }
    
    func setupMenuViewController() {
        if let menuViewController = menuViewController {
            view.insertSubview(menuViewController.view, at: 0)
            addChild(menuViewController)
            
            menuViewController.didMove(toParent: self)
            
            setupMenuViewControllerLayout()
            setupMenuGestures()
        }
    }
    
    func setupMenuViewControllerLayout() {
        guard let menuViewController = menuViewController,
              let menuView = menuViewController.view else { return }
        
        menuView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            menuView.topAnchor.constraint(equalTo: view.topAnchor),
            menuView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            menuView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            menuView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.rightOffset)
        ])
    }
}

// MARK: - Touches

extension MenuChatsViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        if isExtend {
            guard let menuViewController = menuViewController,
                  let menuView = menuViewController.view,
                  let touchView = touches.first?.view else { return }

            if menuView != touchView && !menuView.subviews.contains(touchView) {
                extendMenu()
            }
        }
    }
}

// MARK: - Gestures

private extension MenuChatsViewController {
    func setupMenuGestures() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(didCommitSwipe))
        swipeLeft.direction = .left
        
        menuViewController?.view.addGestureRecognizer(swipeLeft)
    }
    
    @objc func didCommitSwipe(gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            extendMenu()
        }
    }
}
