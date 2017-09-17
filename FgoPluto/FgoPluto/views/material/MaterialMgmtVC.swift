//
//  MaterialMgmtVC.swift
//  FgoPluto
//
//  Created by Zhang, Qianze on 17/09/2017.
//  Copyright © 2017 Plutoless Studio. All rights reserved.
//

import Foundation
import UIKit

class MaterialMgmtCellVM : BaseVM
{
    internal var material_image:UIImage?
    internal var material_number:Int64 = 0
    
    
    convenience init(material:Material) {
        self.init()
        
        self.material_image = material.image?.imageScaled(width: 64)
        self.material_number = material.quantity
    }
}

class MaterialMgmtSectionVM : BaseVM
{
    internal var cells:[MaterialMgmtCellVM] = []
    internal var kind:String = ""
    internal var kind_number:Int = -1
    
    convenience init(kind:String){
        self.init()
        
        self.kind = kind
    }
}

class MaterialMgmtVM : BaseVM
{
    internal var sections:[MaterialMgmtSectionVM] = []
    
    override init(){
        super.init()
        
        let materialsMap:[Int:[Material]] = ChaldeaManager.sharedInstance.materialsByClass()
        
        for kind:Int in materialsMap.keys{
            let section = MaterialMgmtSectionVM()
            section.kind = Material.kind_name(kind: kind)
            section.kind_number = kind
            guard let materials = materialsMap[kind] else {continue}
            for material:Material in materials{
                section.cells.append(MaterialMgmtCellVM(material: material))
            }
            sections.append(section)
        }
        
        sections.sort { (vm1, vm2) -> Bool in
            return vm1.kind_number < vm2.kind_number
        }
    }
}


class MaterialMgmtHeader : UICollectionReusableView
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


class MaterialMgmtCell : UICollectionViewCell
{
    lazy var material_image:UIImageView = {
        let view = UIImageView()
        view.contentMode = .top
        view.clipsToBounds = true
        return view
    }()
    
    lazy var material_number_label:UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = .font(size: 11)
        label.textColor = UIColor(hex: "#A4A4A4")
        return label
    }()
    
    lazy var holding_label:UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .font(size: 11)
        label.text = "持有"
        label.textColor = UIColor(hex: "#A4A4A4")
        return label
    }()
    
    internal var viewModel : MaterialMgmtCellVM? {
        willSet{
            guard let vm:MaterialMgmtCellVM = newValue else {return}
            self.material_image.image = vm.material_image
            self.material_number_label.text = "\(vm.material_number)个"
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.material_image)
        self.addSubview(self.material_number_label)
        self.addSubview(self.holding_label)
        
        self.material_image.snp.makeConstraints { maker in
            maker.size.equalTo(CGSize(width: 64, height: 72))
            maker.top.equalToSuperview()
            maker.centerX.equalToSuperview()
        }
        
        self.material_number_label.snp.makeConstraints {[weak self] maker in
            guard let weakself = self else {return}
            maker.right.equalTo(weakself.material_image.snp.right)
            maker.bottom.equalToSuperview().inset(5)
        }
        
        self.holding_label.snp.makeConstraints {[weak self] maker in
            guard let weakself = self else {return}
            maker.left.equalTo(weakself.material_image.snp.left)
            maker.bottom.equalTo(weakself.material_number_label.snp.bottom)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}


class MaterialMgmtVC : BaseVC, UICollectionViewDelegate, UICollectionViewDataSource
{
    static let REUSE_IDENTIFIER:String = "MaterialMgmtCell"
    static let HEADER_REUSE_IDENTIFIER:String = "MaterialMgmtHeader"
    
    lazy var materialCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: 68, height: 95)
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .white
        collection.register(MaterialMgmtCell.self, forCellWithReuseIdentifier: MaterialMgmtVC.REUSE_IDENTIFIER)
        collection.register(MaterialMgmtHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: HEADER_REUSE_IDENTIFIER)
        collection.delegate = self
        collection.dataSource = self
        collection.contentInset = UIEdgeInsetsMake(0, 5, 0, 5)
        layout.headerReferenceSize = CGSize(width: collection.frame.size.width, height: 32);
        return collection
    }()
    
    lazy var import_btn:UIButton = {
        let btn = UIButton(type: .roundedRect)
        let icon = UIImage.templateImage(name: "import", width: 44)
        btn.setImage(icon, for: .normal)
        btn.tintColor = UIColor(hex: "#252525")
        btn.addTarget(self, action: #selector(onImport), for: .touchUpInside)
        return btn
    }()
}

extension MaterialMgmtVC{
    internal override func create_contents() {
        super.create_contents()
        
        self.title = "素材"
        self.navigationBar.rightBarItems = [self.import_btn]
        
        self.view.addSubview(self.materialCollection)
    }
    
    internal override func set_constraints() {
        self.materialCollection.snp.makeConstraints { maker in
            maker.left.equalToSuperview()
            maker.right.equalToSuperview()
            maker.top.equalTo(self.navigationBar.snp.bottom)
            maker.bottom.equalToSuperview()
        }
    }
    
    internal override func preferredNavigationBarHidden() -> Bool {
        return false
    }
    
    internal func onImport() {
        let _ = ChaldeaManager.sharedInstance.decode_data()
    }
}

extension MaterialMgmtVC{
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let viewModel:MaterialMgmtVM = self.viewModel as? MaterialMgmtVM ?? MaterialMgmtVM()
        let sections:[MaterialMgmtSectionVM] = viewModel.sections
        let cellVMs:[MaterialMgmtCellVM] = sections[indexPath.section].cells
        let cell:MaterialMgmtCell = collectionView.dequeueReusableCell(withReuseIdentifier: MaterialMgmtVC.REUSE_IDENTIFIER, for: indexPath) as? MaterialMgmtCell ?? MaterialMgmtCell(frame: .zero)
        cell.viewModel = cellVMs[indexPath.row]
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let viewModel = self.viewModel as? MaterialMgmtVM else {return 0}
        return viewModel.sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let viewModel:MaterialMgmtVM = self.viewModel as? MaterialMgmtVM else {return 0}
        let sections:[MaterialMgmtSectionVM] = viewModel.sections
        let cells:[MaterialMgmtCellVM] = sections[section].cells
        return cells.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        //1
        switch kind {
        //2
        case UICollectionElementKindSectionHeader:
            //3
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                             withReuseIdentifier: MaterialMgmtVC.HEADER_REUSE_IDENTIFIER,
                                                                             for: indexPath) as? MaterialMgmtHeader ?? MaterialMgmtHeader(frame: .zero)
            let viewModel:MaterialMgmtVM = self.viewModel as? MaterialMgmtVM ?? MaterialMgmtVM()
            let sections:[MaterialMgmtSectionVM] = viewModel.sections
            headerView.kindlabel.text = sections[indexPath.section].kind
            return headerView
        default:
            break
        }
        return UICollectionReusableView(frame:.zero)
    }
}
