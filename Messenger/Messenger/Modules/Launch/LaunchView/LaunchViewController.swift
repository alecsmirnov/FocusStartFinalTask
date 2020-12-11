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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        presenter?.viewDidAppear()
    }
}

// MARK: - ILaunchViewController

extension LaunchViewController: ILaunchViewController {}
