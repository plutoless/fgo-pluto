//
//  MainTabVC.swift
//  FgoPluto
//
//  Created by Zhang, Qianze on 16/09/2017.
//  Copyright © 2017 Plutoless Studio. All rights reserved.
//

import Foundation

class MainTabVC : BaseVC, TabBarDelegate
{
    lazy var tabBar:TabBar = {
        let bar = TabBar(frame: .zero)
        bar.delegate = self
        return bar
    }()
}



extension MainTabVC
{
    override func create_contents() {
        super.create_contents()
        
        
        //tabbar
        let item = TabBarItem(name: "规划", icon: "menu_plan")
        let item2 = TabBarItem(name: "英灵", icon: "menu_servant")
        let item3 = TabBarItem(name: "素材", icon: "menu_item")
        self.tabBar.items = [item, item2, item3]
        self.view.addSubview(self.tabBar)
    }
    
    override func set_constraints() {
        super.set_constraints()
        self.tabBar.snp.makeConstraints {[weak self] maker in
            guard let weakself = self else {return}
            maker.bottom.equalTo(weakself.view)
            maker.left.equalTo(weakself.view)
            maker.right.equalTo(weakself.view)
        }
    }
}


extension MainTabVC{
    internal func didSelectItem(idx: Int) {
        
    }
}
