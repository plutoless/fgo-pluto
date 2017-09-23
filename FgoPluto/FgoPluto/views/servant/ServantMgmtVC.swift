//
//  ServantMgmtVC.swift
//  FgoPluto
//
//  Created by Zhang, Qianze on 16/09/2017.
//  Copyright © 2017 Plutoless Studio. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class ServantMgmtCellVM : BaseVM
{
    internal var servant_image:UIImage?
    internal var servant_evolve_level:Int = 1
    internal var servant_skill_1:Int = 1
    internal var servant_skill_2:Int = 1
    internal var servant_skill_3:Int = 1
    internal var servant_id:Int = 0
    
    
    convenience init(servant:Servant) {
        self.init()
        self.fillServant(servant: servant)
    }
    
    
    func fillServant(servant:Servant){
        self.servant_id = servant.id
        self.servant_evolve_level = servant.ad_level
        self.servant_skill_1 = servant.skill1_level
        self.servant_skill_2 = servant.skill2_level
        self.servant_skill_3 = servant.skill3_level
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
    lazy var collection_bg:UIImageView = {
        let view = UIImageView()
        view.contentMode = .center
        view.image = UIImage(named: "collection_bg")
        return view
    }()
    
    lazy var servant_image:UIImageView = {
        let view = UIImageView()
        view.contentMode = .top
        view.clipsToBounds = true
        return view
    }()
    
    lazy var servant_evolve_label:UILabel = {
        let label = UILabel()
        label.font = .font(size: 12)
        label.textColor = UIColor(hex: "#363636")
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
            self.servant_skills_label.text = "\(vm.servant_skill_1 + 1)/\(vm.servant_skill_2 + 1)/\(vm.servant_skill_3 + 1)"
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.collection_bg)
        self.addSubview(self.servant_image)
        self.addSubview(self.servant_evolve_label)
        self.addSubview(self.servant_skills_label)
        
        self.collection_bg.snp.makeConstraints {maker in
            maker.top.equalToSuperview()
            maker.bottom.equalToSuperview()
            maker.left.equalToSuperview()
            maker.right.equalToSuperview()
        }
        
        self.servant_image.snp.makeConstraints { maker in
            maker.size.equalTo(CGSize(width: 64, height: 72))
            maker.top.equalToSuperview().inset(10)
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


class ServantMgmtVC : BaseVC, UICollectionViewDelegate, UICollectionViewDataSource, ServantEditDelegate
{
    static let REUSE_IDENTIFIER:String = "ServantMgmtCell"
    static let HEADER_REUSE_IDENTIFIER:String = "ServantMgmtHeader"
    
    lazy var servantCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: 90, height: 120)
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
    
    lazy var import_btn:UIButton = {
        let btn = UIButton(type: .roundedRect)
        let icon = UIImage.templateImage(name: "import", width: 32)
        btn.setImage(icon, for: .normal)
        btn.titleLabel?.font = .font(size: 14)
        btn.tintColor = UIColor(hex: "#363636")
        btn.addTarget(self, action: #selector(onImport), for: .touchUpInside)
        return btn
    }()
}

extension ServantMgmtVC{
    internal override func create_contents() {
        super.create_contents()
        
        self.title = "从者"
        self.navigationBar.rightBarItems = [self.import_btn]
        
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
    
    internal func onImport() {
        let _ = ChaldeaManager.sharedInstance.decode_servant_data()
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let viewModel:ServantMgmtVM = self.viewModel as? ServantMgmtVM else {return}
        if let navVC:UINavigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController, let tabVC:MainTabVC = navVC.viewControllers[0] as? MainTabVC {
            let sections:[ServantMgmtSectionVM] = viewModel.sections
            let cells:[ServantMgmtCellVM] = sections[indexPath.section].cells
            let cell:ServantMgmtCellVM = cells[indexPath.row]
            let values = [cell.servant_evolve_level, cell.servant_skill_1 + 1, cell.servant_skill_2 + 1, cell.servant_skill_3 + 1]
            let editor = ServantEditor.showFrom(parent:tabVC.view, values: values, servant_id: cell.servant_id, atIndexPath: indexPath)
            editor.delegate = self
        }
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

extension ServantMgmtVC
{
    func didFinishEdit(servant_id: Int, values: [Int], atIndexPath: IndexPath?) {
        guard let viewModel:ServantMgmtVM = self.viewModel as? ServantMgmtVM, let indexPath:IndexPath = atIndexPath else {return}
        do{
            let realm = try Realm()
            let sections:[ServantMgmtSectionVM] = viewModel.sections
            let cells:[ServantMgmtCellVM] = sections[indexPath.section].cells
            let cell:ServantMgmtCellVM = cells[indexPath.row]
            if let servant = realm.object(ofType: Servant.self, forPrimaryKey: servant_id){
                try realm.write {
                    servant.ad_level = values[0]
                    servant.skill1_level = values[1] - 1
                    servant.skill2_level = values[2] - 1
                    servant.skill3_level = values[3] - 1
                }
                cell.fillServant(servant: servant)
                self.servantCollection.reloadItems(at: [indexPath])
            }
        }catch{
            print(error)
        }
    }
}
