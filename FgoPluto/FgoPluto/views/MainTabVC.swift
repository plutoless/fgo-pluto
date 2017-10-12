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
    
    internal weak var currenct_vc:BaseVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.didSelectItem(idx: 0)
    }
}



extension MainTabVC
{
    override func create_contents() {
        super.create_contents()
        
        
        //tabbar
        let item = TabBarItem(name: "规划", icon: "menu_plan")
        let item2 = TabBarItem(name: "从者", icon: "menu_servant")
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
    
    internal func switchToVC(to_vc:BaseVC){
        if let vc = self.currenct_vc{
            vc.removeFromParentViewController()
            vc.view.removeFromSuperview()
            vc.didMove(toParentViewController: nil)
        }
        
        self.addChildViewController(to_vc)
        self.view.insertSubview(to_vc.view, belowSubview: self.tabBar)
        to_vc.didMove(toParentViewController: self)
        to_vc.view.snp.makeConstraints {[weak self] maker in
            guard let weakself = self else {return}
            maker.left.equalToSuperview()
            maker.top.equalToSuperview()
            maker.right.equalToSuperview()
            maker.bottom.equalTo(weakself.tabBar.snp.top)
        }
        
        self.currenct_vc = to_vc
    }
}


extension MainTabVC{
    internal func didSelectItem(idx: Int) {
        self.tabBar.items[idx].selected = true
        if(idx == 0){
            let vc = HomeVC(viewModel: HomeVM())
            self.switchToVC(to_vc: vc)
        } else if(idx == 1){
            let vc = ServantMgmtVC(viewModel: ServantMgmtVM())
            self.switchToVC(to_vc: vc)
        } else if(idx == 2){
            let vc = MaterialMgmtVC(viewModel: MaterialMgmtVM())
            self.switchToVC(to_vc: vc)
        }
    }
}
