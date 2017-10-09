//
//  UIImage.swift
//  FgoPluto
//
//  Created by Zhang, Qianze on 16/09/2017.
//  Copyright © 2017 Plutoless Studio. All rights reserved.
//

import Foundation
import UIKit

extension UIImage{
    internal static func templateImage(name:String, width: CGFloat) -> UIImage?{
        var image = UIImage(named: name, in: nil, compatibleWith: nil)
        image = image?.imageScaled(width: width)
        image = image?.withRenderingMode(.alwaysTemplate)
        return image
    }
    
    internal func imageScaled(width: CGFloat) -> UIImage{
        let oldWidth = self.size.width
        let scaleFactor = width / oldWidth
        
        if (scaleFactor >= 1) {
            return self
        }
        
        let newHeight = self.size.height * scaleFactor
        let newWidth = oldWidth * scaleFactor
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: newWidth, height: newHeight), false, 2.0)
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return image ?? self;
    }
}
