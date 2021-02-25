//
//  UIImageView+Download.swift
//  Messenger
//
//  Created by Admin on 19.12.2020.
//

import UIKit

private let imageCache = NSCache<NSString, AnyObject>()

extension UIImageView {
    func download(urlString: String) {
        image = nil
        
        if let image = imageCache.object(forKey: urlString as NSString) as? UIImage {
            self.image = image
        } else {
            guard let url = URL(string: urlString) else { return }
            
            let dataTask = URLSession.shared.dataTask(with: url) { data, response, error in
                guard
                    let data = data, response != nil, error == nil,
                    let image = UIImage(data: data)
                else {
                    return
                }
                
                imageCache.setObject(image, forKey: urlString as NSString)
                 
                 DispatchQueue.main.async() {
                     self.image = image
                 }
            }
            
            dataTask.resume()
        }
    }
}
