//
//  MenuViewController.swift
//  Messenger
//
//  Created by Admin on 07.12.2020.
//

import UIKit

protocol IMenuViewController: AnyObject {
    func setUserInfo(_ user: UserInfo)
    
    func hideMenu()
    func showMenu()
}

final class MenuViewController: UIViewController {
    // MARK: Properties
    
    var presenter: IMenuPresenter?
    
    private var menuView: MenuView {
        guard let view = view as? MenuView else {
            fatalError("view is not a MenuView instance")
        }
        
        return view
    }
    
    // MARK: Lifecycle
    
    override func loadView() {
        view = MenuView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter?.viewDidLoad()
        
        setupViewDelegate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupStatusBarColor()
    }
}

// MARK: - IMenuViewController

extension MenuViewController: IMenuViewController {
    func setUserInfo(_ user: UserInfo) {
        menuView.setUser(user)
    }
    
    func hideMenu() {
        menuView.hideOptions()
    }
    
    func showMenu() {
        menuView.showOptions()
    }
}

// MARK: - Private Methods

private extension MenuViewController {
    func setupViewDelegate() {
        menuView.delegate = self
    }
    
    func setupStatusBarColor() {
        setupStatusBarColor(Colors.themeColor)
    }
}

// MARK: - IMenuViewDelegate

extension MenuViewController: IMenuViewDelegate {
    func menuView(_ menuView: IMenuView, didSelectMenuOption menuOption: MenuView.MenuOptions) {
        presenter?.didSelectMenu(with: menuOption)
    }
}
