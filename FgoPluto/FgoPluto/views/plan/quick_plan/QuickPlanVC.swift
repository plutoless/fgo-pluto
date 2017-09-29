//
//  QuickPlanVC.swift
//  FgoPluto
//
//  Created by Zhang, Qianze on 26/09/2017.
//  Copyright © 2017 Plutoless Studio. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class QuickPlanAddCellVM : QuickPlanCellVM
{
    override var reuseIdentifier: String{
        return "QuickPlanAddCellVM"
    }
}

class QuickPlanServantCellVM : QuickPlanCellVM
{
    override var reuseIdentifier: String{
        return "QuickPlanServantCellVM"
    }
}

class QuickPlanMaterialCellVM : QuickPlanCellVM
{
    override var reuseIdentifier: String{
        return "QuickPlanMaterialCellVM"
    }
}

class QuickPlanCellVM : BaseVM
{
    var reuseIdentifier:String {
        return "QuickPlanCellVM"
    }
}

class QuickPlanSectionVM : BaseVM
{
    internal var cells:[QuickPlanCellVM] = []
    internal var title:String = ""
    
    convenience init(title:String){
        self.init()
        self.title = title
    }
}

class QuickPlanVM : BaseVM
{
    internal var sections:[QuickPlanSectionVM] = []
    
    override init(){
        super.init()
        
        let section = QuickPlanSectionVM(title: "选择从者")
        section.cells.append(QuickPlanAddCellVM())
        self.sections.append(section)
    }
}

class QuickPlanAddCell : QuickPlanCell
{
    lazy var icon_view:UIImageView = {
        let view = UIImageView()
        let icon = UIImage.templateImage(name: "add", width: 80)
        view.tintColor = UIColor(hex: "#AAAAAA")
        view.contentMode = .center
        view.image = icon
        return view
    }()
    override func create_contents() {
        super.create_contents()
        self.addSubview(self.icon_view)
    }
    
    override func set_constraints() {
        super.set_constraints()
        self.icon_view.snp.makeConstraints { maker in
            maker.left.equalToSuperview()
            maker.right.equalToSuperview()
            maker.top.equalToSuperview()
            maker.bottom.equalToSuperview()
        }
    }
}

class QuickPlanServantCell : QuickPlanCell
{
    
}

class QuickPlanMaterialCell : QuickPlanCell
{
    
}

class QuickPlanCell : UICollectionViewCell
{
    var viewModel:QuickPlanCellVM?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.create_contents()
        self.set_constraints()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func create_contents(){
        
    }
    
    func set_constraints(){
        
    }
}

class QuickPlanHeader : UICollectionReusableView
{
    lazy var title_label:UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .light_font(size: 13)
        label.textColor = UIColor(hex: "#9E9E9E")
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.title_label)
        self.title_label.snp.makeConstraints { maker in
            maker.top.equalToSuperview()
            maker.bottom.equalToSuperview().inset(10)
            maker.left.equalToSuperview()
            maker.right.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}


class QuickPlanVC : BaseVC, UICollectionViewDataSource, UICollectionViewDelegate, FgoLayoutDelegate
{
    static let HEADER_REUSE_IDENTIFIER:String = "QuickPlanHeader"
    static let MATERIAL_REUSE_IDENTIFIER:String = "QuickPlanMaterialCellVM"
    static let SERVANT_REUSE_IDENTIFIER:String = "QuickPlanServantCellVM"
    static let ADD_REUSE_IDENTIFIER:String = "QuickPlanAddCellVM"
    lazy var plan_collection:UICollectionView = {
        let layout = FgoLayout()
        layout.itemWidth = 80
        layout.itemSpace = 5
        layout.delegate = self
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = UIColor(hex: "#EFEFEF")
        collection.register(QuickPlanMaterialCell.self, forCellWithReuseIdentifier: MATERIAL_REUSE_IDENTIFIER)
        collection.register(QuickPlanServantCell.self, forCellWithReuseIdentifier: SERVANT_REUSE_IDENTIFIER)
        collection.register(QuickPlanAddCell.self, forCellWithReuseIdentifier: ADD_REUSE_IDENTIFIER)
        collection.register(QuickPlanHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: HEADER_REUSE_IDENTIFIER)
        collection.delegate = self
        collection.dataSource = self
//        collection.contentInset = UIEdgeInsetsMake(15, 10, 15, 10)
        layout.headerHeight = 32;
        return collection
    }()
    
    override func create_contents() {
        super.create_contents()
        self.navigationBar.titleLabel.text = "快速查询"
        self.view.addSubview(self.plan_collection)
    }
    
    override func set_constraints() {
        super.set_constraints()
        
        self.plan_collection.snp.makeConstraints {[weak self] maker in
            guard let weakself = self else {return}
            maker.top.equalTo(weakself.navigationBar.snp.bottom)
            maker.left.equalToSuperview()
            maker.right.equalToSuperview()
            maker.bottom.equalToSuperview()
        }
    }
    
    override func preferredNavigationBarHidden() -> Bool {
        return false
    }
}


extension QuickPlanVC
{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let vm = self.viewModel as? QuickPlanVM else {return 0}
        return vm.sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let vm = self.viewModel as? QuickPlanVM else {return 0}
        let sec = vm.sections[section]
        return sec.cells.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let vm = self.viewModel as? QuickPlanVM else {return UICollectionViewCell()}
        let section = vm.sections[indexPath.section]
        let cellVM = section.cells[indexPath.row]
        guard let cell:QuickPlanCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellVM.reuseIdentifier, for: indexPath) as? QuickPlanCell else {return UICollectionViewCell()}
        cell.viewModel = cellVM
        return cell
    }
    
    func heightAtIndexPath(indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 105
        default:
            return 105
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        //1
        switch kind {
        //2
        case UICollectionElementKindSectionHeader:
            //3
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                             withReuseIdentifier: QuickPlanVC.HEADER_REUSE_IDENTIFIER,
                                                                             for: indexPath) as? QuickPlanHeader ?? QuickPlanHeader(frame: .zero)
            let viewModel:QuickPlanVM = self.viewModel as? QuickPlanVM ?? QuickPlanVM()
            let sections:[QuickPlanSectionVM] = viewModel.sections
            headerView.title_label.text = sections[indexPath.section].title
            return headerView
        default:
            break
        }
        return UICollectionReusableView(frame:.zero)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let vm = self.viewModel as? QuickPlanVM else {return}
        let section = vm.sections[indexPath.section]
        let cellVM = section.cells[indexPath.row]
        
        if(cellVM.isKind(of: QuickPlanAddCellVM.self)){
            ServantPickerVC.pickFromVC(vc: self)
        }
    }
}
