//
//  SearchInteractor.swift
//  Messenger
//
//  Created by Admin on 27.11.2020.
//

import Dispatch

protocol ISearchInteractor: AnyObject {
    func searchCompanions(to userIdentifier: String, by name: String)
}

protocol ISearchInteractorOutput: AnyObject {
    func receiveCompanions(_ companions: [SearchCompanion]?)
}

final class SearchInteractor {
    weak var presenter: ISearchInteractorOutput?
}

// MARK: - ISearchInteractor

extension SearchInteractor: ISearchInteractor {
    func searchCompanions(to userIdentifier: String, by name: String) {
        FirebaseDatabaseService.getUsers(by: name, key: .name) { users in
            guard let users = users else {
                self.presenter?.receiveCompanions(nil)

                return
            }

            FirebaseDatabaseService.getCompanions(to: userIdentifier) { companions in
                guard let companions = companions else {
                    let searchCompanions = users.map { firebaseUser -> SearchCompanion in
                        let companionIdentifier = firebaseUser.key
                        let companion = firebaseUser.value
                        
                        return SearchCompanion(userIdentifier: companionIdentifier,
                                               firstName: companion.firstName,
                                               lastName: companion.lastName,
                                               profilePhotoURL: companion.profilePhotoURL,
                                               chat: nil)
                    }
                    
                    self.presenter?.receiveCompanions(searchCompanions)
                    
                    return
                }
                
                let dispatchGroup = DispatchGroup()
                var companionsChats = [String: SearchChat]()
                
                companions.forEach { companionIdentifier, chatIdentifier in
                    dispatchGroup.enter()
                    
                    FirebaseDatabaseService.getLatestMessage(from: chatIdentifier) { message in
                        guard let message = message else { return }
                        companionsChats[companionIdentifier] = SearchChat(chatIdentifier: chatIdentifier,
                                                                          latestMessages: message)
                        
                        dispatchGroup.leave()
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    let searchCompanions = users.map { firebaseUser -> SearchCompanion in
                        let companionIdentifier = firebaseUser.key
                        let companion = firebaseUser.value
                        
                        return SearchCompanion(userIdentifier: companionIdentifier,
                                               firstName: companion.firstName,
                                               lastName: companion.lastName,
                                               profilePhotoURL: companion.profilePhotoURL,
                                               chat: companionsChats[companionIdentifier])
                    }

                    self.presenter?.receiveCompanions(searchCompanions)
                }
            }
        }
    }
}
