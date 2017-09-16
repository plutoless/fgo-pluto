//
//  NavigationBar.swift
//  FgoPluto
//
//  Created by Zhang, Qianze on 16/09/2017.
//  Copyright © 2017 Plutoless Studio. All rights reserved.
//

import Foundation
import UIKit

class NavigationBar:BaseView{
    lazy var titleLabel:UILabel = {
        let label = UILabel()
        label.font = .bold_font(size: 18)
        return label
    }()
    
    var leftBarItems:[UIView] = [] {
        willSet{
            for item:UIView in self.leftBarItems{
                item.removeFromSuperview()
            }
            
            for i in 0..<newValue.count{
                let item = newValue[i]
                self.addSubview(item)
                
                item.snp.makeConstraints({ maker in
                    maker.width.greaterThanOrEqualTo(44)
                    maker.height.equalTo(44)
                    maker.bottom.equalToSuperview()
                    if(i == 0){
                        maker.left.equalToSuperview()
                    } else {
                        maker.left.equalTo(newValue[i - 1].snp.right)
                    }
                })
            }
        }
    }
    var rightBarItems:[UIView] = [] {
        willSet{
            for item:UIView in self.rightBarItems{
                item.removeFromSuperview()
            }
            
            for i in 0..<newValue.count{
                let item = newValue[i]
                self.addSubview(item)
                
                item.snp.makeConstraints({ maker in
                    maker.width.greaterThanOrEqualTo(44)
                    maker.height.equalTo(44)
                    maker.bottom.equalToSuperview()
                    if(i == 0){
                        maker.right.equalToSuperview()
                    } else {
                        maker.right.equalTo(newValue[i - 1].snp.left)
                    }
                })
            }
        }
    }
    
    
    override func create_contents() {
        super.create_contents()
        self.addSubview(self.titleLabel)
    }
    
    override func set_constraints() {
        super.set_constraints()
        
        self.titleLabel.snp.makeConstraints { maker in
            maker.bottom.equalToSuperview()
            maker.centerX.equalToSuperview()
            maker.height.equalTo(44)
        }
    }
}
