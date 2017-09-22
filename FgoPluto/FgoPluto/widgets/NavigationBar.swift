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
        label.font = .med_font(size: 16)
        label.textColor = self.tintColor
        return label
    }()
    
    lazy var bottom_line:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#DCDCDC")
        return view
    }()
    
    var leftBarItems:[UIView] = [] {
        willSet{
            for item:UIView in self.leftBarItems{
                item.removeFromSuperview()
            }
            
            for i in 0..<newValue.count{
                let item = newValue[i]
                item.tintColor = self.tintColor
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
                item.tintColor = self.tintColor
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
        self.tintColor = UIColor(hex: "#474747")
        self.addSubview(self.bottom_line)
        self.addSubview(self.titleLabel)
    }
    
    override func set_constraints() {
        super.set_constraints()
        
        self.bottom_line.snp.makeConstraints { maker in
            maker.bottom.equalToSuperview()
            maker.left.equalToSuperview()
            maker.right.equalToSuperview()
            maker.height.equalTo(0.5)
        }
        
        self.titleLabel.snp.makeConstraints { maker in
            maker.bottom.equalToSuperview()
            maker.centerX.equalToSuperview()
            maker.height.equalTo(44)
        }
    }
}
