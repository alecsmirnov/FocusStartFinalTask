//
//  UIImage+Resize.swift
//  Messenger
//
//  Created by Admin on 19.12.2020.
//

import UIKit

extension UIImage {
    enum ResizeContentMode {
        case aspectFill
        case aspectFit
    }
    
    func resize(withBounds bounds: CGSize, contentMode: ResizeContentMode) -> UIImage {
        let horizontalRatio = bounds.width / size.width
        let verticalRatio = bounds.height / size.height
        
        let ratio: CGFloat
        
        switch contentMode {
        case .aspectFill: ratio = max(horizontalRatio, verticalRatio)
        case .aspectFit: ratio = min(horizontalRatio, verticalRatio)
        }
        
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
        
        draw(in: CGRect(origin: CGPoint.zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
