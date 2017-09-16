//
//  BaseView.swift
//  FgoPluto
//
//  Created by Zhang, Qianze on 16/09/2017.
//  Copyright © 2017 Plutoless Studio. All rights reserved.
//

import Foundation
import UIKit

class BaseView : UIView{
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.create_contents()
        self.set_constraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}


extension BaseView {
    internal func create_contents(){
        //for override
    }
    internal func set_constraints(){
        //for override
    }
}
