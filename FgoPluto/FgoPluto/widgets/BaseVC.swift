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
    
    lazy var back_btn:UIButton = {
        let btn = UIButton(type: .roundedRect)
        let icon = UIImage.templateImage(name: "back", width: 32)
        btn.setImage(icon, for: .normal)
        btn.titleLabel?.font = .font(size: 14)
        btn.tintColor = UIColor(hex: "#363636")
        btn.addTarget(self, action: #selector(on_back), for: .touchUpInside)
        return btn
    }()
    
    override var title: String?{
        willSet{
            self.navigationBar.titleLabel.text = newValue
        }
    }
    
    override func loadView() {
        super.loadView()
        self.view.backgroundColor = UIColor(hex: "#EFEFEF")
        
        self.create_contents()
        
        if(!self.preferredNavigationBarHidden()){
            self.view.addSubview(self.navigationBar)
            self.navigationBar.snp.makeConstraints({ maker in
                maker.height.equalTo(64)
                maker.top.equalToSuperview()
                maker.left.equalToSuperview()
                maker.right.equalToSuperview()
            })
            
            if(self.navigationController?.viewControllers.count ?? 0 > 1){
                self.navigationBar.leftBarItems = [self.back_btn]
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.set_constraints()
    }
    
    func on_back(){
        self.navigationController?.popViewController(animated: true)
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
