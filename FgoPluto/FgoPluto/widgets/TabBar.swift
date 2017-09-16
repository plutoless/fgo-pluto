//
//  TabBar.swift
//  FgoPluto
//
//  Created by Zhang, Qianze on 16/09/2017.
//  Copyright © 2017 Plutoless Studio. All rights reserved.
//

import Foundation
import UIKit
import SnapKit



class TabBarItem : BaseView {
    lazy var titleLabel:UILabel = {
        let label = UILabel()
        label.font = .font(size: 10)
        label.textColor = UIColor(hex: "#AEAEAE")
        return label
    }()
    
    lazy var iconImage:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .bottom
        imageView.tintColor = UIColor(hex: "#AEAEAE")
        return imageView
    }()
    
    internal var selected:Bool = false {
        willSet{
            if(newValue){
                self.titleLabel.textColor = UIColor(hex: "#4A90E2")
                self.iconImage.tintColor = UIColor(hex: "#4A90E2")
            } else {
                self.titleLabel.textColor = UIColor(hex: "#AEAEAE")
                self.iconImage.tintColor = UIColor(hex: "#AEAEAE")
            }
        }
    }
    
    convenience init(name: String, icon: String) {
        self.init(frame: .zero)
        self.titleLabel.text = name
        let iconImage = UIImage.templateImage(name: icon, width: 24)
        self.iconImage.image = iconImage
    }
    
    
    override func create_contents() {
        super.create_contents()
        
        self.addSubview(self.titleLabel)
        self.addSubview(self.iconImage)
    }
    
    override func set_constraints() {
        super.set_constraints()
        
        self.iconImage.snp.makeConstraints {[weak self] maker in
            guard let weakself = self else {return}
            maker.size.equalTo(CGSize(width: 32, height: 32))
            maker.top.equalTo(weakself)
            maker.centerX.equalTo(weakself)
        }
        
        self.titleLabel.snp.makeConstraints{[weak self] maker in
            guard let weakself = self else {return}
            maker.centerX.equalTo(weakself)
            maker.bottom.equalTo(weakself)
            maker.top.equalTo(weakself.iconImage.snp.bottom)
        }
    }
}


protocol TabBarDelegate : class{
    func didSelectItem(idx:Int)
}

class TabBar : BaseView {
    internal var items:[TabBarItem] = [] {
        willSet{
            for item:TabBarItem in self.items {
                item.removeFromSuperview()
            }
            
            let new_items_count = newValue.count
            let width = UIScreen.main.bounds.width, item_width = width / CGFloat(new_items_count)
            
            
            for i in 0..<newValue.count {
                let item:TabBarItem = newValue[i]
                let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.onTapItem(_:)))
                item.addGestureRecognizer(tap)
                self.addSubview(item)
                
                item.snp.makeConstraints{[weak self] maker in
                    guard let weakself = self else {return}
                    maker.width.equalTo(item_width)
                    maker.top.equalTo(weakself)
                    maker.bottom.equalTo(weakself)
                    
                    if(i == 0){
                        //first item
                        maker.left.equalTo(weakself)
                    } else {
                        if(i == new_items_count - 1){
                            maker.right.equalTo(weakself)
                        }
                        maker.left.equalTo(newValue[i - 1].snp.right)
                    }
                }
            }
        }
    }
    
    weak var delegate: TabBarDelegate?
}

extension TabBar {
    
    override func create_contents() {
        super.create_contents()
        
        self.backgroundColor = .white
        self.layer.shadowOffset = CGSize(width: 0, height: -1)
        self.layer.shadowRadius = 3.0
        self.layer.shadowOpacity = 0.2
    }
    
    override func set_constraints() {
        super.set_constraints()
        
        self.snp.makeConstraints { maker in
            maker.height.equalTo(56)
        }
    }
}

extension TabBar{
    internal func onTapItem(_ sender : UIGestureRecognizer){
        guard let selectedItem:TabBarItem = sender.view as? TabBarItem, let idx:Int = self.items.index(of: selectedItem) else {return}
        
        for item:TabBarItem in self.items{
            item.selected = false
        }
        
        selectedItem.selected = true
        
        self.delegate?.didSelectItem(idx: idx)
        
    }
}
