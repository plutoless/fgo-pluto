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
        
        let servantsMap:[String:[Servant]] = ChaldeaManager.sharedInstance.servantsByClass()
        
        for kind:String in servantsMap.keys{
            let section = ServantMgmtSectionVM()
            guard let servants = servantsMap[kind] else {continue}
            for servant:Servant in servants{
                section.cells.append(ServantMgmtCellVM(servant: servant))
            }
            sections.append(section)
        }
        
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
            maker.size.equalTo(CGSize(width: 64, height: 64))
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
    
    lazy var servantCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: 68, height: 100)
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .white
        collection.register(ServantMgmtCell.classForCoder(), forCellWithReuseIdentifier: ServantMgmtVC.REUSE_IDENTIFIER)
        collection.delegate = self
        collection.dataSource = self
        collection.contentInset = UIEdgeInsetsMake(0, 5, 0, 5)
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
}
