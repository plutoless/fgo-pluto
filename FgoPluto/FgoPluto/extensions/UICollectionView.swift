//
//  UICollectionView.swift
//  FgoPluto
//
//  Created by Zhang, Qianze on 29/09/2017.
//  Copyright © 2017 Plutoless Studio. All rights reserved.
//

import Foundation
import UIKit

extension UICollectionView{
    open func reloadItems(at indexPaths: [IndexPath], animated: Bool){
        if(animated){
            self.reloadItems(at: indexPaths)
        } else {
            UIView.performWithoutAnimation {
                self.reloadItems(at: indexPaths)
            }
        }
    }
}
