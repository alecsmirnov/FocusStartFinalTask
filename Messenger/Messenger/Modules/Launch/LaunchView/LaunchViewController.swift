//
//  LaunchViewController.swift
//  Messenger
//
//  Created by Admin on 06.12.2020.
//

import UIKit

protocol ILaunchViewController: AnyObject {}

final class LaunchViewController: UIViewController {
    // MARK: Properties
    
    var presenter: ILaunchPresenter?
    
    // MARK: Lifecycle
    
    override func loadView() {
        view = LaunchView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        hideNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        presenter?.viewDidAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        showNavigationBar()
    }
}

// MARK: - ILaunchViewController

extension LaunchViewController: ILaunchViewController {}

// MARK: - Appearance

private extension LaunchViewController {
    func hideNavigationBar() {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func showNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
}
