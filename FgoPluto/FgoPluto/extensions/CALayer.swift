//
//  CALayer.swift
//  FgoPluto
//
//  Created by Zhang, Qianze on 10/10/2017.
//  Copyright © 2017 Plutoless Studio. All rights reserved.
//

import Foundation
import UIKit

extension CALayer{
    func applyRoundedShadow(){
        self.cornerRadius = 5.0
        self.shadowOffset = CGSize(width: 0, height: 0)
        self.shadowRadius = 3.0
        self.shadowOpacity = 0.05
    }
    
    func toImage() -> UIImage?{
        UIGraphicsBeginImageContext(self.bounds.size)
        guard let context = UIGraphicsGetCurrentContext() else {return nil}
        self.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
