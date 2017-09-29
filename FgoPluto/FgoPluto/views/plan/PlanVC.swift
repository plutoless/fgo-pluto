//
//  PlanVC.swift
//  FgoPluto
//
//  Created by Zhang, Qianze on 22/09/2017.
//  Copyright © 2017 Plutoless Studio. All rights reserved.
//

import Foundation
import UIKit

class PlanCell : UITableViewCell
{
    lazy var bg_view:UIImageView = {
        let imageview = UIImageView()
        imageview.layer.cornerRadius = 8
        imageview.contentMode = .right
        imageview.clipsToBounds = true
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

class PlanVC : BaseVC, UITableViewDataSource, UITableViewDelegate
{
    lazy var plan_menu:UITableView = {
        let tbl = UITableView(frame: .zero, style: .grouped)
        tbl.dataSource = self
        tbl.delegate = self
        tbl.separatorStyle = .none
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

extension PlanVC{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        default:
            return 148
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = PlanCell(style: .default, reuseIdentifier: nil)
        
        if(indexPath.row == 0){
            let bg = UIImage(named: "plan_quick")
            cell.bg_view.image = bg
            cell.title_label.text = "快速查询"
            cell.desc_label.text = "查询从者升级材料"
        } else if(indexPath.row == 1){
            let bg = UIImage(named: "plan_plan")
            cell.bg_view.image = bg
            cell.title_label.text = "素材规划"
            cell.desc_label.text = "规划从者材料使用"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row == 0){
            let vc = QuickPlanVC(viewModel: QuickPlanVM())
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
