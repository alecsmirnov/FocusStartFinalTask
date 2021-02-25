//
//  MenuViewController.swift
//  Messenger
//
//  Created by Admin on 07.12.2020.
//

import UIKit

protocol IMenuViewController: AnyObject {
    func setUserInfo(_ user: UserInfo)
    
    func showMenu()
    func hideMenu()
}

final class MenuViewController: MyStatusBarViewController {
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
        
        setupView()
    }
}

// MARK: - IMenuViewController

extension MenuViewController: IMenuViewController {
    func setUserInfo(_ user: UserInfo) {
        menuView.setUser(user)
    }
    
    func showMenu() {
        menuView.showOptions()
    }
    
    func hideMenu() {
        menuView.hideOptions()
    }
}

// MARK: - Private Methods

private extension MenuViewController {
    func setupView() {
        menuView.delegate = self
    }
}

// MARK: - IMenuViewDelegate

extension MenuViewController: MenuViewDelegate {
    func menuView(_ menuView: MenuView, didSelectMenuOption menuOption: MenuView.MenuOptions) {
        presenter?.didSelectMenu(with: menuOption)
    }
}
