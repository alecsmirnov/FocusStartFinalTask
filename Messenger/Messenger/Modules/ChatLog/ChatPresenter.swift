//
//  ChatPresenter.swift
//  Messenger
//
//  Created by Admin on 26.11.2020.
//

protocol IChatPresenter: AnyObject {
    var sectionsCount: Int { get }
    var messagesCount: Int { get }
    
    func viewDidAppear()
}

final class ChatPresenter {
    weak var viewController: IChatViewController?
    var interactor: IChatInteractor?
    var router: IChatRouter?
}

// MARK: - IChatPresenter

extension ChatPresenter: IChatPresenter {
    var sectionsCount: Int {
        return 1
    }
    
    var messagesCount: Int {
        return 5
    }
    
    func viewDidAppear() {
        
    }
}
