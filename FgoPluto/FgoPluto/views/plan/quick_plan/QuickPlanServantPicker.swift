//
//  QuickPlanServantPicker.swift
//  FgoPluto
//
//  Created by Zhang, Qianze on 28/09/2017.
//  Copyright © 2017 Plutoless Studio. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import PromiseKit

typealias PlanItem = (Servant, [PlanRange])

class QuickPlanServantPickerCellVM : BaseVM
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

class QuickPlanServantPickerSectionVM : BaseVM
{
    internal var cells:[QuickPlanServantPickerCellVM] = []
    internal var kind:String = ""
    internal var kind_number:Int = -1
    
    convenience init(kind:String){
        self.init()
        
        self.kind = kind
    }
}

class QuickPlanServantPickerVM : BaseVM
{
    internal var sections:[QuickPlanServantPickerSectionVM] = []
    
    override init(){
        super.init()
        
        let servantsMap:[Int:[Servant]] = ChaldeaManager.sharedInstance.servantsByClass()
        
        for kind:Int in servantsMap.keys{
            let section = QuickPlanServantPickerSectionVM()
            section.kind = Servant.kind_name(kind: kind)
            section.kind_number = kind
            guard let servants = servantsMap[kind] else {continue}
            for servant:Servant in servants{
                section.cells.append(QuickPlanServantPickerCellVM(servant: servant))
            }
            sections.append(section)
        }
        
        sections.sort { (vm1, vm2) -> Bool in
            return vm1.kind_number < vm2.kind_number
        }
    }
}


class QuickPlanServantPickerHeader : UICollectionReusableView
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


class QuickPlanServantPickerCell : UICollectionViewCell
{
    lazy var collection_bg:UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    lazy var servant_image:UIImageView = {
        let view = UIImageView()
        view.contentMode = .center
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
    
    internal var viewModel : QuickPlanServantPickerCellVM? {
        willSet{
            guard let vm:QuickPlanServantPickerCellVM = newValue else {return}
            self.servant_image.image = vm.servant_image
            self.servant_evolve_label.text = "灵基再临(\(vm.servant_evolve_level))"
            self.servant_skills_label.text = "\(vm.servant_skill_1 + 1)/\(vm.servant_skill_2 + 1)/\(vm.servant_skill_3 + 1)"
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.collection_bg)
        self.collection_bg.addSubview(self.servant_image)
        self.addSubview(self.servant_evolve_label)
        self.addSubview(self.servant_skills_label)
        
        self.collection_bg.snp.makeConstraints {[weak self] maker in
            guard let weakself = self else {return}
            maker.top.equalToSuperview()
            maker.left.equalToSuperview()
            maker.right.equalToSuperview()
            maker.height.equalTo(weakself.collection_bg.snp.width)
        }
        
        self.servant_image.snp.makeConstraints { maker in
            maker.size.equalTo(CGSize(width: 64, height: 72))
            maker.center.equalToSuperview()
        }
        
        self.servant_evolve_label.snp.makeConstraints {[weak self] maker in
            guard let weakself = self else {return}
            maker.left.equalTo(weakself.servant_image.snp.left)
            maker.top.equalTo(weakself.collection_bg.snp.bottom).offset(3)
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

class QuickPlanServantPickerVC : BaseVC, UICollectionViewDelegate, UICollectionViewDataSource, PlanEditDelegate, FgoLayoutDelegate
{
    static let REUSE_IDENTIFIER:String = "QuickPlanServantPickerCell"
    static let HEADER_REUSE_IDENTIFIER:String = "QuickPlanServantPickerHeader"
    fileprivate let promiseTuple : Promise<PlanItem?>.PendingTuple = Promise<PlanItem?>.pending()
    
    lazy var servantCollection: UICollectionView = {
        let layout = FgoLayout()
        layout.itemSpace = 5
        layout.itemWidth = 80
        layout.delegate = self
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = UIColor(hex: "#EFEFEF")
        collection.register(QuickPlanServantPickerCell.self, forCellWithReuseIdentifier: QuickPlanServantPickerVC.REUSE_IDENTIFIER)
        collection.register(QuickPlanServantPickerHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: HEADER_REUSE_IDENTIFIER)
        collection.delegate = self
        collection.dataSource = self
        collection.contentInset = UIEdgeInsetsMake(0, 20, 0, 20)
        layout.headerHeight = 44;
        return collection
    }()
    
    static func pickFromVC(vc:UIViewController) -> Promise<PlanItem?>{
        let picker = QuickPlanServantPickerVC(viewModel: QuickPlanServantPickerVM())
        vc.navigationController?.pushViewController(picker, animated: true)
        
        return picker.promiseTuple.promise
    }
    
    
    internal override func create_contents() {
        super.create_contents()
        
        self.title = "选择从者"
        
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
    
    internal override func on_back() {
        super.on_back()
        self.promiseTuple.fulfill(nil)
    }
    
    
    internal override func preferredNavigationBarHidden() -> Bool {
        return false
    }
}

extension QuickPlanServantPickerVC{
    
    internal func onImport() {
        let _ = ChaldeaManager.sharedInstance.decode_servant_data()
    }
}

extension QuickPlanServantPickerVC{
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let viewModel:QuickPlanServantPickerVM = self.viewModel as? QuickPlanServantPickerVM ?? QuickPlanServantPickerVM()
        let sections:[QuickPlanServantPickerSectionVM] = viewModel.sections
        let cellVMs:[QuickPlanServantPickerCellVM] = sections[indexPath.section].cells
        let cell:QuickPlanServantPickerCell = collectionView.dequeueReusableCell(withReuseIdentifier: QuickPlanServantPickerVC.REUSE_IDENTIFIER, for: indexPath) as? QuickPlanServantPickerCell ?? QuickPlanServantPickerCell(frame: .zero)
        cell.viewModel = cellVMs[indexPath.row]
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let viewModel = self.viewModel as? QuickPlanServantPickerVM else {return 0}
        return viewModel.sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let viewModel:QuickPlanServantPickerVM = self.viewModel as? QuickPlanServantPickerVM else {return 0}
        let sections:[QuickPlanServantPickerSectionVM] = viewModel.sections
        let cells:[QuickPlanServantPickerCellVM] = sections[section].cells
        return cells.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let viewModel:QuickPlanServantPickerVM = self.viewModel as? QuickPlanServantPickerVM else {return}
        if let navVC:UINavigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController, let topVC:UIViewController = navVC.topViewController {
            let sections:[QuickPlanServantPickerSectionVM] = viewModel.sections
            let cells:[QuickPlanServantPickerCellVM] = sections[indexPath.section].cells
            let cell:QuickPlanServantPickerCellVM = cells[indexPath.row]
            let values = [cell.servant_evolve_level, cell.servant_skill_1 + 1, cell.servant_skill_2 + 1, cell.servant_skill_3 + 1]
            let editor = PlanEditor.showFrom(parent:topVC.view, values: values, servant_id: cell.servant_id, atIndexPath: indexPath)
            editor.title_label.text = "设定目标"
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
                                                                             withReuseIdentifier: QuickPlanServantPickerVC.HEADER_REUSE_IDENTIFIER,
                                                                             for: indexPath) as? QuickPlanServantPickerHeader ?? QuickPlanServantPickerHeader(frame: .zero)
            let viewModel:QuickPlanServantPickerVM = self.viewModel as? QuickPlanServantPickerVM ?? QuickPlanServantPickerVM()
            let sections:[QuickPlanServantPickerSectionVM] = viewModel.sections
            headerView.kindlabel.text = sections[indexPath.section].kind
            return headerView
        default:
            break
        }
        return UICollectionReusableView(frame:.zero)
    }
}

extension QuickPlanServantPickerVC
{
    func didFinishEdit(servant_id: Int, values: [PlanRange], atIndexPath: IndexPath?) {
        do{
            let realm = try Realm()
            if let servant:Servant = realm.object(ofType: Servant.self, forPrimaryKey: servant_id){
                let plan_item:PlanItem = (servant, values)
                self.promiseTuple.fulfill(plan_item)
                self.navigationController?.popViewController(animated: true)
            }
        }catch{
            print(error)
        }
    }
}

extension QuickPlanServantPickerVC
{
    func heightAtIndexPath(indexPath: IndexPath) -> CGFloat {
        return 120
    }
}
