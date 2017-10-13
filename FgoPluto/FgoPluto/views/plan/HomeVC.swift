//
//  HomeVC.swift
//  FgoPluto
//
//  Created by Zhang, Qianze on 22/09/2017.
//  Copyright © 2017 Plutoless Studio. All rights reserved.
//

import Foundation
import UIKit

class HomeCellVM : BaseVM
{
    var reuseIdentifier:String{
        return ""
    }
    var height:CGFloat{
        return 0
    }
}

class HomePlanCellVM : HomeCellVM
{
    override var reuseIdentifier: String{
        return "HomePlanCell"
    }
    override var height:CGFloat{
        return 0
    }
}

class HomeMenuCellVM : HomeCellVM
{
    var bg:UIImage?
    var title:String = ""
    var desc:String = ""
    
    override var reuseIdentifier: String{
        return "HomeMenuCell"
    }
    override var height:CGFloat{
        return 180
    }
}

class HomeVM : BaseVM
{
    var cells:[HomeCellVM] = []
    
    override init(){
        super.init()
        
        let menu = HomeMenuCellVM()
        menu.bg = UIImage(named: "plan_quick")
        menu.title = "快速开始"
        menu.desc = "查询规划素材"
        self.cells.append(menu)
    }
}

class HomeCell : UITableViewCell
{
    var viewModel : HomeCellVM?
}

class HomePlanCell : HomeCell
{
    
}

class HomeMenuCell : HomeCell
{
    override var viewModel: HomeCellVM?{
        willSet{
            guard let vm = newValue as? HomeMenuCellVM else {return}
            self.bg_view.image = vm.bg
            self.title_label.text = vm.title
            self.desc_label.text = vm.desc
        }
    }
    
    lazy var bg_view:UIImageView = {
        let imageview = UIImageView()
        imageview.contentMode = .scaleAspectFit
        return imageview
    }()
    
    lazy var title_label:UILabel = {
        let label = UILabel()
        label.font = .heavy_font(size: 16)
        label.textColor = .white
        return label
    }()
    
    lazy var sep_line:UIView = {
        let line = UIView()
        line.backgroundColor = .white
        return line
    }()
    
    lazy var desc_label:UILabel = {
        let label = UILabel()
        label.font = .bold_font(size: 12)
        label.textColor = .white
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        
        self.contentView.addSubview(self.bg_view)
        self.bg_view.snp.makeConstraints {maker in
            maker.top.equalToSuperview().inset(10)
            maker.left.equalToSuperview().inset(20)
            maker.right.equalToSuperview().inset(20)
            maker.bottom.equalToSuperview().inset(10)
        }
        
        self.bg_view.addSubview(self.title_label)
        self.title_label.snp.makeConstraints {maker in
            maker.left.equalToSuperview().inset(20)
            maker.top.equalToSuperview().inset(30)
        }
        
        self.bg_view.addSubview(self.sep_line)
        self.sep_line.snp.makeConstraints {[weak self] maker in
            guard let weakself = self else {return}
            maker.left.equalTo(weakself.title_label.snp.left)
            maker.width.equalTo(30)
            maker.height.equalTo(1)
            maker.top.equalTo(weakself.title_label.snp.bottom).offset(5)
        }
        
        self.bg_view.addSubview(self.desc_label)
        self.desc_label.snp.makeConstraints {[weak self] maker in
            guard let weakself = self else {return}
            maker.left.equalTo(weakself.title_label.snp.left)
            maker.top.equalTo(weakself.sep_line.snp.bottom).offset(5)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}


class HomeVC : BaseVC, UITableViewDataSource, UITableViewDelegate
{
    lazy var plan_menu:UITableView = {
        let tbl = UITableView(frame: .zero, style: .grouped)
        tbl.dataSource = self
        tbl.delegate = self
        tbl.separatorStyle = .none
        tbl.register(HomePlanCell.self, forCellReuseIdentifier: "HomePlanCell")
        tbl.register(HomeMenuCell.self, forCellReuseIdentifier: "HomeMenuCell")
        return tbl
    }()
    
    override func create_contents() {
        super.create_contents()
        
        self.view.addSubview(self.plan_menu)
    }
    
    override func set_constraints() {
        super.set_constraints()
        
        self.plan_menu.snp.makeConstraints {maker in
            maker.top.equalToSuperview()
            maker.left.equalToSuperview()
            maker.right.equalToSuperview()
            maker.bottom.equalToSuperview()
        }
    }
}

extension HomeVC{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let vm:HomeVM = self.viewModel as? HomeVM else {return 0}
        return vm.cells.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let home_vm:HomeVM = self.viewModel as? HomeVM else {return 0}
        let cell_vm = home_vm.cells[indexPath.row]
        return cell_vm.height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let home_vm:HomeVM = self.viewModel as? HomeVM, let cell:HomeCell = tableView.dequeueReusableCell(withIdentifier: home_vm.cells[indexPath.row].reuseIdentifier) as? HomeCell else {return UITableViewCell()}
        let cell_vm = home_vm.cells[indexPath.row]
        
        cell.viewModel = cell_vm
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row == 0){
            let vc = QuickPlanVC(viewModel: QuickPlanVM())
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
