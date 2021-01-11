//
//  ChatLogPresenter.swift
//  Messenger
//
//  Created by Admin on 26.11.2020.
//

protocol IChatPresenter: AnyObject {
    var sectionsCount: Int { get }
    var messagesCount: Int { get }
    
    func viewDidAppear()
}

final class ChatLogPresenter {
    weak var viewController: IChatLogViewController?
    var interactor: IChatLogInteractor?
    var router: IChatRouter?
}

// MARK: - IChatPresenter

extension ChatLogPresenter: IChatPresenter {
    var sectionsCount: Int {
        return 1
    }
    
    var messagesCount: Int {
        return 5
    }
    
    func viewDidAppear() {
        
    }
}
