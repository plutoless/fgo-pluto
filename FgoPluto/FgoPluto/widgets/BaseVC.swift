//
//  BaseVC.swift
//  FgoPluto
//
//  Created by Zhang, Qianze on 16/09/2017.
//  Copyright © 2017 Plutoless Studio. All rights reserved.
//

import Foundation
import UIKit

class BaseVC : UIViewController{
    override func loadView() {
        super.loadView()
        self.view.backgroundColor = .white
        
        self.create_contents()
        self.set_constraints()
    }
}


extension BaseVC{
    internal func create_contents() {
        
    }
    
    
    internal func set_constraints() {
        
    }
}
