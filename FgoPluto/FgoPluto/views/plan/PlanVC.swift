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
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        
        self.addSubview(self.bg_view)
        self.bg_view.snp.makeConstraints {maker in
            maker.top.equalToSuperview().inset(10)
            maker.left.equalToSuperview().inset(20)
            maker.right.equalToSuperview().inset(20)
            maker.bottom.equalToSuperview().inset(10)
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
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = PlanCell(style: .default, reuseIdentifier: nil)
        
        if(indexPath.row == 0){
            let bg = UIImage(named: "plan_quick")
            cell.bg_view.image = bg
        }
        
        return cell
    }
}
