//
//  SearchPresenter.swift
//  Messenger
//
//  Created by Admin on 27.11.2020.
//

protocol ISearchPresenter: AnyObject {
    var companionsCount: Int { get }
    
    func companion(forRowAt index: Int) -> SearchCompanion?
    
    func didChangeText(_ text: String)
    func didSelectCompanionAt(index: Int)
}

protocol ISearchPresenterDelegate: AnyObject {
    func iSearchPresenter(_ searchPresenter: ISearchPresenter, didSelectCompanion companion: SearchCompanion)
}

final class SearchPresenter {
    // MARK: Properties
    
    weak var viewController: ISearchViewController?
    var interactor: ISearchInteractor?
    var router: ISearchRouter?
    
    var userIdentifier: String?
    weak var delegate: ISearchPresenterDelegate?
    
    private var companions: [SearchCompanion]?
}

// MARK: - ISearchPresenter

extension SearchPresenter: ISearchPresenter {
    var companionsCount: Int {
        return companions?.count ?? 0
    }
    
    func companion(forRowAt index: Int) -> SearchCompanion? {
        return companions?[index]
    }
    
    func didChangeText(_ text: String) {
        search(by: text.lowercased())
    }
    
    func didSelectCompanionAt(index: Int) {
        if let companion = companions?[index] {
            router?.closeSearchViewController()
            delegate?.iSearchPresenter(self, didSelectCompanion: companion)
        }
    }
}

// MARK: - Helper Methods

private extension SearchPresenter {
    func search(by name: String) {
        companions?.removeAll()
        
        viewController?.noResultLabelIsHidden = true
       
        if !name.isEmpty {
            viewController?.activityIndicatorViewIsHidden = false
            
            if let userIdentifier = userIdentifier {
                interactor?.searchCompanions(to: userIdentifier, by: name)
            }
        } else {
            viewController?.reloadData()
        }
    }
}

// MARK: - ISearchInteractorOutput

extension SearchPresenter: ISearchInteractorOutput {
    func receiveCompanions(_ companions: [SearchCompanion]?) {
        self.companions = companions
        
        viewController?.activityIndicatorViewIsHidden = true
           
        if companions == nil {
            viewController?.noResultLabelIsHidden = false
        }
        
        viewController?.reloadData()
    }
}
