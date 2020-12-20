//
//  UIImageView+Download.swift
//  Messenger
//
//  Created by Admin on 19.12.2020.
//

import UIKit

extension UIImageView {
    func download(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        let dataTask = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, response != nil, error == nil,
                  let image = UIImage(data: data) else { return }
            
            DispatchQueue.main.async { [weak self] in
                self?.image = image
            }
        }
        
        dataTask.resume()
    }
}
