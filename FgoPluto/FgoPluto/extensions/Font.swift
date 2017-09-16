//
//  Font.swift
//  FgoPluto
//
//  Created by Zhang, Qianze on 16/09/2017.
//  Copyright © 2017 Plutoless Studio. All rights reserved.
//

import Foundation
import UIKit

extension UIFont{
    private static func font(name:String, size:CGFloat) -> UIFont{
        return .font(name: name, size: size)
    }
    
    internal static func font(size:CGFloat) -> UIFont{
        return .systemFont(ofSize: size)
    }
}
