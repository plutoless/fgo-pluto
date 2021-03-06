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
import SnapKit
import JGProgressHUD

typealias PlanItem = (Servant, [PlanRange])
typealias QuickPlanMaterialCount = (Material, Int64)

class QuickPlanAddCellVM : QuickPlanCellVM
{
    override var reuseIdentifier: String{
        return "QuickPlanAddCellVM"
    }
}

class QuickPlanServantCellVM : QuickPlanCellVM
{
    var plan_item:PlanItem?
    var servant:Servant?
    var servant_image:UIImage?
    var ad_from:Int = 0
    var ad_to:Int = 0
    var skill1_from:Int = 0
    var skill1_to:Int = 0
    var skill2_from:Int = 0
    var skill2_to:Int = 0
    var skill3_from:Int = 0
    var skill3_to:Int = 0
    
    
    override var reuseIdentifier: String{
        return "QuickPlanServantCellVM"
    }
    
    convenience init(plan:PlanItem) {
        self.init()
        self.setPlan(plan: plan)
    }
    
    func setPlan(plan:PlanItem){
        self.plan_item = plan
        let servant:Servant = plan.0
        let ranges:[PlanRange] = plan.1
        
        self.servant = servant
        self.servant_image = servant.image
        self.ad_from = ranges[0].0
        self.ad_to = ranges[0].1
        self.skill1_from = ranges[1].0
        self.skill1_to = ranges[1].1
        self.skill2_from = ranges[2].0
        self.skill2_to = ranges[2].1
        self.skill3_from = ranges[3].0
        self.skill3_to = ranges[3].1
    }
    
    override init() {
        super.init()
    }
}

class QuickPlanMaterialCellVM : QuickPlanCellVM
{
    override var reuseIdentifier: String{
        return "QuickPlanMaterialCellVM"
    }
    
    var material:Material?
    var quantity:Int64 = 0
    var material_image:UIImage?
    
    convenience init(count:QuickPlanMaterialCount) {
        self.init()
        self.material = count.0
        self.quantity = count.1
        self.material_image = self.material?.image
    }
    
    override init() {
        super.init()
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
    
    func servantCellVM(servant:Servant) -> QuickPlanServantCellVM?{
        for cell_vm:QuickPlanCellVM in self.sections[0].cells{
            guard let servant_cell_vm:QuickPlanServantCellVM = cell_vm as? QuickPlanServantCellVM, let cell_servant:Servant = servant_cell_vm.servant else {continue}
            
            if(cell_servant.id == servant.id){
                return servant_cell_vm
            }
        }
        return nil
    }
    
    private func skill_materials(servant:Servant, from: Int, to:Int) -> [Material]{
        var materials:[Material] = []
        for i in from..<to{
            switch(i){
            case 1:
                materials.append(contentsOf: servant.skill1)
                break;
            case 2:
                materials.append(contentsOf: servant.skill2)
                break;
            case 3:
                materials.append(contentsOf: servant.skill3)
                break;
            case 4:
                materials.append(contentsOf: servant.skill4)
                break;
            case 5:
                materials.append(contentsOf: servant.skill5)
                break;
            case 6:
                materials.append(contentsOf: servant.skill6)
                break;
            case 7:
                materials.append(contentsOf: servant.skill7)
                break;
            case 8:
                materials.append(contentsOf: servant.skill8)
                break;
            case 9:
                materials.append(contentsOf: servant.skill9)
                break;
            default:
                break;
            }
        }
        return materials
    }
    
    private func skill_qp(servant:Servant, from:Int, to:Int) -> Int64{
        var qp:Int64 = 0
        for i in from..<to{
            qp += ChaldeaManager.skill_qp[servant.rank][i - 1]
        }
        return qp
    }
    
    func calculate_cost(){
        var materials:[Material] = []
        var qp:Int64 = 0
        let material_map:[Int: Material] = ChaldeaManager.sharedInstance.materialsById()
        for cell_vm:QuickPlanCellVM in self.sections[0].cells{
            guard let servant_cell_vm:QuickPlanServantCellVM = cell_vm as? QuickPlanServantCellVM, let servant:Servant = servant_cell_vm.servant else {continue}
            
            //ad
            let ad_from = servant_cell_vm.ad_from, ad_to = servant_cell_vm.ad_to
            for i in ad_from..<ad_to{
                switch(i){
                case 0:
                    materials.append(contentsOf: servant.AdAgain1)
                    qp += ChaldeaManager.ad_qp[servant.rank][0]
                    break;
                case 1:
                    materials.append(contentsOf: servant.AdAgain2)
                    qp += ChaldeaManager.ad_qp[servant.rank][1]
                    break;
                case 2:
                    materials.append(contentsOf: servant.AdAgain3)
                    qp += ChaldeaManager.ad_qp[servant.rank][2]
                    break;
                case 3:
                    materials.append(contentsOf: servant.AdAgain4)
                    qp += ChaldeaManager.ad_qp[servant.rank][3]
                    break;
                default:
                    break;
                }
            }
            
            //skill1
            let skill1_from = servant_cell_vm.skill1_from, skill1_to = servant_cell_vm.skill1_to
            materials.append(contentsOf: self.skill_materials(servant: servant, from: skill1_from, to: skill1_to))
            qp += self.skill_qp(servant: servant, from: skill1_from, to: skill1_to)
            
            //skill2
            let skill2_from = servant_cell_vm.skill2_from, skill2_to = servant_cell_vm.skill2_to
            materials.append(contentsOf: self.skill_materials(servant: servant, from: skill2_from, to: skill2_to))
            qp += self.skill_qp(servant: servant, from: skill2_from, to: skill2_to)
            
            //skill3
            let skill3_from = servant_cell_vm.skill3_from, skill3_to = servant_cell_vm.skill3_to
            materials.append(contentsOf: self.skill_materials(servant: servant, from: skill3_from, to: skill3_to))
            qp += self.skill_qp(servant: servant, from: skill3_from, to: skill3_to)
        }
        
        
        //all materials
        var material_count_map:[Int:QuickPlanMaterialCount] = [:]
        
        for material:Material in materials{
            let mid:Int = material.id
            let count = material_count_map[mid]
            
            if(count == nil){
                material_count_map[mid] = (material, 0)
            }
            
            let quantity:Int64 = material_count_map[mid]!.1
            material_count_map[mid] = (material, quantity + 1)
        }
        
        var material_cell_vms:[QuickPlanMaterialCellVM] = []
        for count:QuickPlanMaterialCount in material_count_map.values{
            material_cell_vms.append(QuickPlanMaterialCellVM(count: count))
        }
        
        if(qp > 0){
            if let qp_material:Material = material_map[900]{
                let qp_count : QuickPlanMaterialCount = (qp_material, qp)
                material_cell_vms.append(QuickPlanMaterialCellVM(count: qp_count))
            }
        }
        
        
        
        //lacking materials
        var lacking_material_cell_vms:[QuickPlanMaterialCellVM] = []
        for count:QuickPlanMaterialCount in material_count_map.values{
            let required_no:Int64 = count.1
            let hold_no:Int64 = count.0.quantity
            let lacking_no:Int64 = required_no - hold_no
            if(lacking_no <= 0){
                continue
            }
            
            let lacking_count:QuickPlanMaterialCount = (count.0, lacking_no)
            lacking_material_cell_vms.append(QuickPlanMaterialCellVM(count: lacking_count))
        }
        
        //keep the first section only
        self.sections = [self.sections[0]]
        
        var section = QuickPlanSectionVM(title: "材料需求")
        section.cells = material_cell_vms
        self.sections.append(section)
        
        if(lacking_material_cell_vms.count > 0){
            section = QuickPlanSectionVM(title: "欠缺材料")
            section.cells = lacking_material_cell_vms
            self.sections.append(section)
        }
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
    lazy var bg:UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    override func create_contents() {
        super.create_contents()
        self.addSubview(self.bg)
        self.bg.addSubview(self.icon_view)
    }
    
    override func set_constraints() {
        super.set_constraints()
        self.bg.snp.makeConstraints {[weak self] maker in
            guard let weakself = self else {return}
            maker.top.equalToSuperview()
            maker.left.equalToSuperview()
            maker.right.equalToSuperview()
            maker.height.equalTo(weakself.bg.snp.width).offset(30)
        }
        self.icon_view.snp.makeConstraints { maker in
            maker.center.equalToSuperview()
        }
    }
}

protocol QuickPlanServantCellDelegate : class
{
    func onRemoveBtnPressed(cell:QuickPlanServantCell)
}

class QuickPlanServantCell : QuickPlanCell
{
    override var viewModel: QuickPlanCellVM?{
        willSet{
            guard let vm : QuickPlanServantCellVM = newValue as? QuickPlanServantCellVM else {return}
            self.servant_image.image = vm.servant_image
            self.plan_ad_desc.text = "再临 \(vm.ad_from)-\(vm.ad_to)"
            self.plan_skill_desc.text = "\(vm.skill1_from)-\(vm.skill1_to) \(vm.skill2_from)-\(vm.skill2_to) \(vm.skill3_from)-\(vm.skill3_to)"
        }
    }
    
    weak var delegate:QuickPlanServantCellDelegate?
    lazy var removeBtn:UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named:"remove")?.imageScaled(width: 18), for: .normal)
        btn.addTarget(self, action: #selector(self.remove), for: .touchUpInside)
        return btn
    }()
    
    lazy var bg:UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    lazy var servant_image:UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    lazy var plan_ad_desc:UILabel = {
        let label = UILabel()
        label.font = .font(size: 12)
        label.textAlignment = .center
        label.textColor = UIColor(hex:"#363636")
        return label
    }()
    
    lazy var plan_skill_desc:UILabel = {
        let label = UILabel()
        label.font = .font(size: 10)
        label.textAlignment = .center
        label.textColor = UIColor(hex:"#363636")
        return label
    }()
    
    override func create_contents() {
        super.create_contents()
        self.addSubview(self.bg)
        self.bg.addSubview(self.servant_image)
        self.addSubview(self.plan_ad_desc)
        self.addSubview(self.plan_skill_desc)
        self.addSubview(self.removeBtn)
    }
    
    override func set_constraints() {
        super.set_constraints()
        self.removeBtn.snp.makeConstraints {maker in
            maker.top.equalToSuperview().inset(-5)
            maker.right.equalToSuperview().inset(-5)
            maker.size.equalTo(CGSize(width: 18, height: 18))
        }
        
        self.bg.snp.makeConstraints {[weak self] maker in
            guard let weakself = self else {return}
            maker.top.equalToSuperview()
            maker.left.equalToSuperview()
            maker.right.equalToSuperview()
            maker.height.equalTo(weakself.bg.snp.width).offset(30)
        }
        
        self.servant_image.snp.makeConstraints { maker in
            maker.size.equalTo(CGSize(width: 64, height: 72))
            maker.top.equalToSuperview().inset(5)
            maker.centerX.equalToSuperview()
        }
        self.plan_ad_desc.snp.makeConstraints {[weak self] maker in
            guard let weakself = self else {return}
            maker.left.equalTo(weakself.bg.snp.left)
            maker.right.equalTo(weakself.bg.snp.right)
            maker.top.equalTo(weakself.servant_image.snp.bottom).offset(3)
        }
        self.plan_skill_desc.snp.makeConstraints {[weak self] maker in
            guard let weakself = self else {return}
            maker.left.equalTo(weakself.bg.snp.left)
            maker.right.equalTo(weakself.bg.snp.right)
            maker.top.equalTo(weakself.plan_ad_desc.snp.bottom)
        }
    }
    
    func remove(){
        self.delegate?.onRemoveBtnPressed(cell:self)
    }
}

class QuickPlanMaterialCell : QuickPlanCell
{
    override var viewModel: QuickPlanCellVM?{
        willSet{
            guard let vm : QuickPlanMaterialCellVM = newValue as? QuickPlanMaterialCellVM else {return}
            self.material_image.image = vm.material_image
            let formattedValue = ValueFormatter.format_abbr_big_number(value: Double(vm.quantity))
            let formattedUnit = ValueFormatter.format_unit_big_number(value: Double(vm.quantity))
            self.material_count_label.text = "\(formattedValue)\(formattedUnit)"
        }
    }
    
    lazy var bg:UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    lazy var material_image:UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    lazy var material_count_label:UILabel = {
        let label = UILabel()
        label.font = .font(size: 12)
        label.textAlignment = .center
        label.textColor = UIColor(hex:"#363636")
        return label
    }()
    
    override func create_contents() {
        super.create_contents()
        self.addSubview(self.bg)
        self.bg.addSubview(self.material_image)
        self.addSubview(self.material_count_label)
    }
    
    override func set_constraints() {
        super.set_constraints()
        self.bg.snp.makeConstraints {[weak self] maker in
            guard let weakself = self else {return}
            maker.top.equalToSuperview()
            maker.left.equalToSuperview()
            maker.right.equalToSuperview()
            maker.height.equalTo(weakself.bg.snp.width).offset(18)
        }
        
        self.material_image.snp.makeConstraints { maker in
            maker.size.equalTo(CGSize(width: 64, height: 72))
            maker.top.equalToSuperview().inset(5)
            maker.centerX.equalToSuperview()
        }
        self.material_count_label.snp.makeConstraints {[weak self] maker in
            guard let weakself = self else {return}
            maker.left.equalTo(weakself.bg.snp.left)
            maker.right.equalTo(weakself.bg.snp.right)
            maker.top.equalTo(weakself.material_image.snp.bottom).offset(3)
        }
    }
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


class QuickPlanVC : BaseVC, UICollectionViewDataSource, UICollectionViewDelegate, FgoLayoutDelegate, PlanEditDelegate, QuickPlanServantCellDelegate
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
        collection.contentInset = UIEdgeInsetsMake(15, 10, 15, 10)
        layout.headerHeight = 32;
        return collection
    }()
    
    lazy var plan_btn:UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("素材不足，马上添加素材计划", for: .normal)
        btn.tintColor = .white
        btn.layer.cornerRadius = 3.0
        btn.titleLabel?.font = .bold_font(size: 14)
        btn.addTarget(self, action: #selector(on_plan), for: .touchUpInside)
        btn.applyShadow()
        return btn
    }()
    
    lazy var cost_btn:UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("消耗素材升级从者", for: .normal)
        btn.tintColor = .white
        btn.titleLabel?.font = .bold_font(size: 14)
        btn.addTarget(self, action: #selector(on_deduct), for: .touchUpInside)
        btn.applyShadow()
        return btn
    }()
    
    var action_btm_constraint:Constraint?
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        var gradient = self.plan_btn.applyGradient(withColours: [UIColor(hex:"#5594fe"),UIColor(hex:"#3A80F2")])
        gradient.applyRoundedShadow()
        self.plan_btn.setBackgroundImage(gradient.toImage(), for: .normal)
        gradient = self.cost_btn.applyGradient(withColours: [UIColor(hex:"#F85866"),UIColor(hex:"#FF0026")])
        gradient.applyRoundedShadow()
        self.cost_btn.setBackgroundImage(gradient.toImage(), for: .normal)
    }
    
    override func create_contents() {
        super.create_contents()
        self.navigationBar.titleLabel.text = "快速查询"
        self.view.addSubview(self.plan_collection)
        self.view.addSubview(self.plan_btn)
        self.view.addSubview(self.cost_btn)
    }
    
    override func set_constraints() {
        super.set_constraints()
        
        self.cost_btn.snp.makeConstraints {[weak self] maker in
            guard let weakself = self else {return}
            maker.height.equalTo(44)
            maker.left.equalToSuperview().inset(20)
            maker.right.equalToSuperview().inset(20)
            weakself.action_btm_constraint = maker.bottom.equalToSuperview().inset(-50).constraint
        }
        
        self.plan_btn.snp.makeConstraints {[weak self] maker in
            guard let weakself = self else {return}
            maker.height.equalTo(44)
            maker.left.equalTo(weakself.cost_btn.snp.left)
            maker.right.equalTo(weakself.cost_btn.snp.right)
            maker.bottom.equalTo(weakself.cost_btn.snp.bottom)
        }
        
        self.plan_collection.snp.makeConstraints {[weak self] maker in
            guard let weakself = self else {return}
            maker.top.equalTo(weakself.navigationBar.snp.bottom)
            maker.left.equalToSuperview()
            maker.right.equalToSuperview()
            maker.bottom.equalTo(weakself.plan_btn.snp.top)
        }
    }
    
    override func preferredNavigationBarHidden() -> Bool {
        return false
    }
    
    func toggleAction(visible:Bool){
        if let constraint = self.action_btm_constraint{
            if(visible){
                constraint.update(inset: 10)
            } else {
                constraint.update(inset: -50)
            }
            
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut, animations: {[weak self] _ in
                self?.cost_btn.layoutIfNeeded()
                self?.plan_btn.layoutIfNeeded()
            }, completion:nil)
        }
    }
    
    func updateActionVisibility(){
        guard let plan_vm:QuickPlanVM  = self.viewModel as? QuickPlanVM else {return}
        for cell_vm:QuickPlanCellVM in plan_vm.sections[0].cells{
            if(cell_vm.isKind(of: QuickPlanServantCellVM.self)){
                //set visible, return
                self.toggleAction(visible: true)
                
                //show corresponding buttons
                if(plan_vm.sections.count > 2){
                    self.cost_btn.isHidden = true
                    self.plan_btn.isHidden = false
                } else {
                    self.cost_btn.isHidden = false
                    self.plan_btn.isHidden = true
                }
                return
            }
        }
        
        self.toggleAction(visible: false)
    }
    
    func on_deduct(){
        let alert = UIAlertController(title: "扣除素材", message: "查询的从者等级会被设定到目标等级，同时对应的素材也会被从素材库中扣除，是否确认？", preferredStyle: .alert)
        let confirm = UIAlertAction(title: "确认", style: .destructive) {[weak self] action in
            self?.deductMaterials()
            self?.navigationController?.popViewController(animated: true)
        }
    
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alert.addAction(cancel)
        alert.addAction(confirm)
        self.present(alert, animated: true, completion: nil)
    }
    
    func deductMaterials(){
        guard let plan_vm:QuickPlanVM = self.viewModel as? QuickPlanVM else {return}
        
        do{
            let realm = try Realm()
            //update servant
            for cellvm:QuickPlanCellVM in plan_vm.sections[0].cells{
                guard let servant_vm:QuickPlanServantCellVM = cellvm as? QuickPlanServantCellVM, let plan_item:PlanItem = servant_vm.plan_item else {continue}
                let servant:Servant = plan_item.0
                let plan:[PlanRange] = plan_item.1
                try realm.write {
                    servant.ad_level = plan[0].1
                    servant.skill1_level = plan[1].1 - 1
                    servant.skill2_level = plan[2].1 - 1
                    servant.skill3_level = plan[3].1 - 1
                }
            }
            
            //update materials
            for cellvm:QuickPlanCellVM in plan_vm.sections[1].cells{
                guard let material_vm:QuickPlanMaterialCellVM = cellvm as? QuickPlanMaterialCellVM, let material:Material = material_vm.material else {continue}
                let quantity:Int64 = material_vm.quantity
                try realm.write {
                    material.quantity = material.quantity - quantity
                }
            }
            
            
            let hud = JGProgressHUD(style: .dark)
            hud.indicatorView = JGProgressHUDSuccessIndicatorView()
            hud.textLabel.text = "升级成功"
            hud.show(in: self.navigationController!.view)
            hud.dismiss(afterDelay: 2.0)
        }catch{
            print(error)
        }
    }
    
    func on_plan(){
        self.planMaterials()
        self.navigationController?.popViewController(animated: true)
    }
    
    func planMaterials(){
        guard let plan_vm:QuickPlanVM = self.viewModel as? QuickPlanVM else {return}
        do{
            let realm = try Realm()
            //create plan
            var servants:[Servant] = []
            var plans:[String] = []
            for cellvm:QuickPlanCellVM in plan_vm.sections[0].cells{
                guard let servant_vm:QuickPlanServantCellVM = cellvm as? QuickPlanServantCellVM, let plan_item:PlanItem = servant_vm.plan_item else {continue}
                let servant:Servant = plan_item.0
                let plan:[PlanRange] = plan_item.1
                servants.append(servant)
                plans.append("\(plan[0].0),\(plan[0].1),\(plan[1].0),\(plan[1].1),\(plan[2].0),\(plan[2].1),\(plan[3].0),\(plan[3].1),")
            }
            
            let plans_str:String = plans.joined(separator: ";")
            
            try realm.write{
                let stored_plan:Plan = Plan()
                stored_plan.servants.append(objectsIn: servants)
                stored_plan.archived_plan = plans_str
                realm.add(stored_plan)
            }
            
            let hud = JGProgressHUD(style: .dark)
            hud.indicatorView = JGProgressHUDSuccessIndicatorView()
            hud.textLabel.text = "计划添加成功"
            hud.show(in: self.navigationController!.view)
            hud.dismiss(afterDelay: 2.0)
        }catch{
            print(error)
        }
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
        if let servant_cell:QuickPlanServantCell = cell as? QuickPlanServantCell{
            servant_cell.delegate = self
        }
        return cell
    }
    
    func heightAtIndexPath(indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 130
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
            var selectedItems : [Servant] = []
            for cell:QuickPlanCellVM in vm.sections[0].cells{
                guard let c:QuickPlanServantCellVM = cell as? QuickPlanServantCellVM, let item:PlanItem = c.plan_item else {continue}
                selectedItems.append(item.0)
            }
            
            QuickPlanServantPickerVC.pickFromVC(vc: self, selectedItems: selectedItems).then{[weak self] item -> Void in
                guard let servant:Servant = item else {return}
                //once finished picking servant, add to view,provide plan
                if let navVC:UINavigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController, let topVC:UIViewController = navVC.topViewController {
                    let plan_item:PlanItem = (servant, PlanEditor.defaultRanges(servant: servant))
                    let editor = PlanEditor.showFrom(parent:topVC.view, plan: plan_item)
                    editor.title_label.text = "设定目标"
                    editor.delegate = self
                    
                    let vm = QuickPlanServantCellVM(plan: plan_item)
                    guard let plan_vm:QuickPlanVM = self?.viewModel as? QuickPlanVM else {return}
                    plan_vm.sections[0].cells.insert(vm, at: 0)
                    self?.plan_collection.reloadFgoLayout()
                }
            }.catch{error in
                
            }
        } else if(cellVM.isKind(of: QuickPlanServantCellVM.self)){
            if let c:QuickPlanServantCellVM = cellVM as? QuickPlanServantCellVM, let plan:PlanItem = c.plan_item, let navVC:UINavigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController, let topVC:UIViewController = navVC.topViewController{
                let editor = PlanEditor.showFrom(parent:topVC.view, plan: plan)
                editor.title_label.text = "设定目标"
                editor.delegate = self
            }
        }
    }
}

extension QuickPlanVC{
    func didFinishEdit(servant: Servant, values: [PlanRange]) {
        guard let plan_vm:QuickPlanVM = self.viewModel as? QuickPlanVM, let cell_vm = plan_vm.servantCellVM(servant: servant) else {return}
        cell_vm.setPlan(plan: (servant, values))
        plan_vm.calculate_cost()
        self.plan_collection.reloadFgoLayout()
        self.updateActionVisibility()
    }
    
    func onRemoveBtnPressed(cell: QuickPlanServantCell) {
        guard let cell_vm:QuickPlanServantCellVM = cell.viewModel as? QuickPlanServantCellVM, let plan_vm:QuickPlanVM = self.viewModel as? QuickPlanVM else {return}
        guard let idx:Int = plan_vm.sections[0].cells.index(of: cell_vm) else {return}
        plan_vm.sections[0].cells.remove(at: idx)
        plan_vm.calculate_cost()
        self.plan_collection.reloadFgoLayout()
        self.updateActionVisibility()
    }
}
