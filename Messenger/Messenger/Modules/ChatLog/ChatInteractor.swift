//
//  ChatInteractor.swift
//  Messenger
//
//  Created by Admin on 26.11.2020.
//

protocol IChatInteractor: AnyObject {}

final class ChatInteractor {
    weak var presenter: IChatPresenter?
}

// MARK: - IChatInteractor

extension ChatInteractor: IChatInteractor {}

