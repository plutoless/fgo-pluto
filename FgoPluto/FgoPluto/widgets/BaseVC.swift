//
//  BaseVC.swift
//  FgoPluto
//
//  Created by Zhang, Qianze on 16/09/2017.
//  Copyright © 2017 Plutoless Studio. All rights reserved.
//

import Foundation
import UIKit


class BaseVM : NSObject{
    
}


class BaseVC : UIViewController{
    lazy var navigationBar:NavigationBar = {
        let bar = NavigationBar(frame: .zero)
        return bar
    }()
    
    internal var viewModel:BaseVM
    
    init(viewModel: BaseVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.viewModel = BaseVM()
        super.init(coder: aDecoder)
    }
    
    override var title: String?{
        willSet{
            self.navigationBar.titleLabel.text = newValue
        }
    }
    
    override func loadView() {
        super.loadView()
        self.view.backgroundColor = .white
        
        self.create_contents()
        
        if(!self.preferredNavigationBarHidden()){
            self.view.addSubview(self.navigationBar)
            self.navigationBar.snp.makeConstraints({ maker in
                maker.height.equalTo(64)
                maker.top.equalToSuperview()
                maker.left.equalToSuperview()
                maker.right.equalToSuperview()
            })
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.set_constraints()
    }
}


extension BaseVC{
    internal func create_contents() {
        
    }
    
    
    internal func set_constraints() {
        
    }
    
    
    internal func preferredNavigationBarHidden() -> Bool{
        return true
    }
}
