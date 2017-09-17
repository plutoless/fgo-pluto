//
//  ServantMgmtVC.swift
//  FgoPluto
//
//  Created by Zhang, Qianze on 16/09/2017.
//  Copyright © 2017 Plutoless Studio. All rights reserved.
//

import Foundation
import UIKit

class ServantMgmtCellVM : BaseVM
{
    internal var servant_image:UIImage?
    internal var servant_evolve_level:Int = 0
    internal var servant_skills_level:String = "10/6/8"
    
    
    convenience init(servant:Servant) {
        self.init()
        
        self.servant_image = servant.image?.imageScaled(width: 64)
    }
}

class ServantMgmtSectionVM : BaseVM
{
    internal var cells:[ServantMgmtCellVM] = []
    internal var kind:String = ""
    internal var kind_number:Int = -1
    
    convenience init(kind:String){
        self.init()
        
        self.kind = kind
    }
}

class ServantMgmtVM : BaseVM
{
    internal var sections:[ServantMgmtSectionVM] = []
    
    override init(){
        super.init()
        
        let servantsMap:[Int:[Servant]] = ChaldeaManager.sharedInstance.servantsByClass()
        
        for kind:Int in servantsMap.keys{
            let section = ServantMgmtSectionVM()
            section.kind = Servant.kind_name(kind: kind)
            section.kind_number = kind
            guard let servants = servantsMap[kind] else {continue}
            for servant:Servant in servants{
                section.cells.append(ServantMgmtCellVM(servant: servant))
            }
            sections.append(section)
        }
        
        sections.sort { (vm1, vm2) -> Bool in
            return vm1.kind_number < vm2.kind_number
        }
    }
}


class ServantMgmtHeader : UICollectionReusableView
{
    lazy var kindlabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .light_font(size: 13)
        label.textColor = UIColor(hex: "#9E9E9E")
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.kindlabel)
        self.kindlabel.snp.makeConstraints { maker in
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


class ServantMgmtCell : UICollectionViewCell
{
    lazy var servant_image:UIImageView = {
        let view = UIImageView()
        view.contentMode = .top
        view.clipsToBounds = true
        return view
    }()
    
    lazy var servant_evolve_label:UILabel = {
        let label = UILabel()
        label.font = .font(size: 12)
        label.textColor = UIColor(hex: "#252525")
        return label
    }()
    
    lazy var servant_skills_label:UILabel = {
        let label = UILabel()
        label.font = .font(size: 12)
        label.textColor = UIColor(hex: "#A4A4A4")
        return label
    }()
    
    internal var viewModel : ServantMgmtCellVM? {
        willSet{
            guard let vm:ServantMgmtCellVM = newValue else {return}
            self.servant_image.image = vm.servant_image
            self.servant_evolve_label.text = "灵基再临(\(vm.servant_evolve_level))"
            self.servant_skills_label.text = vm.servant_skills_level
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.servant_image)
        self.addSubview(self.servant_evolve_label)
        self.addSubview(self.servant_skills_label)
        
        self.servant_image.snp.makeConstraints { maker in
            maker.size.equalTo(CGSize(width: 64, height: 72))
            maker.top.equalToSuperview()
            maker.centerX.equalToSuperview()
        }
        
        self.servant_evolve_label.snp.makeConstraints {[weak self] maker in
            guard let weakself = self else {return}
            maker.left.equalTo(weakself.servant_image.snp.left)
            maker.top.equalTo(weakself.servant_image.snp.bottom)
        }
        
        self.servant_skills_label.snp.makeConstraints {[weak self] maker in
            guard let weakself = self else {return}
            maker.left.equalTo(weakself.servant_image.snp.left)
            maker.top.equalTo(weakself.servant_evolve_label.snp.bottom)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}


class ServantMgmtVC : BaseVC, UICollectionViewDelegate, UICollectionViewDataSource
{
    static let REUSE_IDENTIFIER:String = "ServantMgmtCell"
    static let HEADER_REUSE_IDENTIFIER:String = "ServantMgmtHeader"
    
    lazy var servantCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: 68, height: 110)
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .white
        collection.register(ServantMgmtCell.self, forCellWithReuseIdentifier: ServantMgmtVC.REUSE_IDENTIFIER)
        collection.register(ServantMgmtHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: HEADER_REUSE_IDENTIFIER)
        collection.delegate = self
        collection.dataSource = self
        collection.contentInset = UIEdgeInsetsMake(0, 5, 0, 5)
        layout.headerReferenceSize = CGSize(width: collection.frame.size.width, height: 64);
        return collection
    }()
}

extension ServantMgmtVC{
    internal override func create_contents() {
        super.create_contents()
        
        self.title = "从者"
        
        self.view.addSubview(self.servantCollection)
    }
    
    internal override func set_constraints() {
        self.servantCollection.snp.makeConstraints { maker in
            maker.left.equalToSuperview()
            maker.right.equalToSuperview()
            maker.top.equalTo(self.navigationBar.snp.bottom)
            maker.bottom.equalToSuperview()
        }
    }
    
    internal override func preferredNavigationBarHidden() -> Bool {
        return false
    }
}

extension ServantMgmtVC{
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let viewModel:ServantMgmtVM = self.viewModel as? ServantMgmtVM ?? ServantMgmtVM()
        let sections:[ServantMgmtSectionVM] = viewModel.sections
        let cellVMs:[ServantMgmtCellVM] = sections[indexPath.section].cells
        let cell:ServantMgmtCell = collectionView.dequeueReusableCell(withReuseIdentifier: ServantMgmtVC.REUSE_IDENTIFIER, for: indexPath) as? ServantMgmtCell ?? ServantMgmtCell(frame: .zero)
        cell.viewModel = cellVMs[indexPath.row]
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let viewModel = self.viewModel as? ServantMgmtVM else {return 0}
        return viewModel.sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let viewModel:ServantMgmtVM = self.viewModel as? ServantMgmtVM else {return 0}
        let sections:[ServantMgmtSectionVM] = viewModel.sections
        let cells:[ServantMgmtCellVM] = sections[section].cells
        return cells.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        //1
        switch kind {
        //2
        case UICollectionElementKindSectionHeader:
            //3
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                             withReuseIdentifier: ServantMgmtVC.HEADER_REUSE_IDENTIFIER,
                                                                             for: indexPath) as? ServantMgmtHeader ?? ServantMgmtHeader(frame: .zero)
            let viewModel:ServantMgmtVM = self.viewModel as? ServantMgmtVM ?? ServantMgmtVM()
            let sections:[ServantMgmtSectionVM] = viewModel.sections
            headerView.kindlabel.text = sections[indexPath.section].kind
            return headerView
        default:
            break
        }
        return UICollectionReusableView(frame:.zero)
    }
}
