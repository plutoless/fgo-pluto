//
//  MaterialMgmtVC.swift
//  FgoPluto
//
//  Created by Zhang, Qianze on 17/09/2017.
//  Copyright © 2017 Plutoless Studio. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import RealmSwift
import Realm

class MaterialMgmtCellVM : BaseVM
{
    internal var material:Material?
    internal var material_image:UIImage?
    internal var material_number:Int64 = 0{
        willSet{
            if let realm = try? Realm(){
                try? realm.write {
                    self.material?.quantity = newValue
                }
            }
        }
    }
    
    
    convenience init(material:Material) {
        self.init()
        self.material = material
        self.material_image = material.image?.imageScaled(width: 64)
        self.material_number = material.quantity
    }
    
    func formattedNumber() -> String{
        let input = Double(self.material_number)
        var output = input
        
        if(input >= 1*pow(10, 12)){
            output = input / (1*pow(10, 12))
        } else if(input >= 1*pow(10, 8)){
            output = input / (1*pow(10, 8))
        } else if(input >= 1*pow(10, 4)){
            output = input / (1*pow(10, 4))
        }
        
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: output)) ?? "\(self.material_number)"
    }
    
    func formattedUnit() -> String{
        let input = Double(self.material_number)
        
        if(input >= 1*pow(10, 12)){
            return "万亿"
        } else if(input >= 1*pow(10, 8)){
            return "亿"
        } else if(input >= 1*pow(10, 4)){
            return "万"
        }
        return "个"
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


class MaterialMgmtCell : UICollectionViewCell, UITextFieldDelegate
{
    weak var current_first_responder:UITextField?
    lazy var material_image:UIImageView = {
        let view = UIImageView()
        view.contentMode = .top
        view.clipsToBounds = true
        return view
    }()
    
    lazy var material_number_label:UITextField = {
        let label = UITextField()
        label.textAlignment = .right
        label.font = .font(size: 11)
        label.textColor = UIColor(hex: "#A4A4A4")
        label.keyboardType = .numberPad
        label.delegate = self
        label.textAlignment = .right
        
        let toolbar = UIToolbar()
        label.inputAccessoryView = toolbar
        var spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        var doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(MaterialMgmtCell.donePressed))
        toolbar.setItems([spaceButton, doneButton], animated: false)
        toolbar.sizeToFit()
        
        return label
    }()
    
    lazy var unit_number_label:UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = .font(size: 11)
        label.textColor = UIColor(hex: "#A4A4A4")
        return label
    }()
    
    internal var viewModel : MaterialMgmtCellVM? {
        willSet{
            guard let vm:MaterialMgmtCellVM = newValue else {return}
            self.material_image.image = vm.material_image
            self.material_number_label.text = "\(vm.formattedNumber())"
            self.unit_number_label.text = "\(vm.formattedUnit())"
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.material_image)
        self.addSubview(self.material_number_label)
        self.addSubview(self.unit_number_label)
        
        self.material_image.snp.makeConstraints { maker in
            maker.size.equalTo(CGSize(width: 64, height: 72))
            maker.top.equalToSuperview()
            maker.centerX.equalToSuperview()
        }
        
        self.material_number_label.snp.makeConstraints {[weak self] maker in
            guard let weakself = self else {return}
            maker.bottom.equalTo(weakself.unit_number_label)
            maker.right.equalTo(weakself.unit_number_label.snp.left)
            maker.left.equalTo(weakself.material_image.snp.left)
        }
        
        self.unit_number_label.snp.makeConstraints {[weak self] maker in
            guard let weakself = self else {return}
            maker.right.equalTo(weakself.material_image.snp.right)
            maker.bottom.equalToSuperview().inset(5)
            maker.width.equalTo(10)
        }
        
        self.unit_number_label.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .horizontal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    func donePressed(){
        current_first_responder?.resignFirstResponder()
    }
}

extension MaterialMgmtCell
{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let viewModel = self.viewModel else {return}
        textField.text = "\(viewModel.material_number)"
        current_first_responder = textField
        textField.selectAll(nil)
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let text = textField.text
        
        if let trimmed = text?.trimmingCharacters(in: CharacterSet.decimalDigits.inverted), let number = Int64(trimmed), let viewModel = self.viewModel{
            viewModel.material_number = number
            //update viewmodel
            self.viewModel = viewModel
        }
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
    
    var collection_bottom_constraint:Constraint?
    
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        self.registerForKeyboardNotifications()
    }
}

extension MaterialMgmtVC{
    internal override func create_contents() {
        super.create_contents()
        
        self.title = "素材"
        self.navigationBar.rightBarItems = [self.import_btn]
        
        self.view.addSubview(self.materialCollection)
    }
    
    internal override func set_constraints() {
        self.materialCollection.snp.makeConstraints {[weak self] maker in
            guard let weakself = self else {return}
            maker.left.equalToSuperview()
            maker.right.equalToSuperview()
            maker.top.equalTo(weakself.navigationBar.snp.bottom)
            weakself.collection_bottom_constraint = maker.bottom.equalTo(weakself.view).inset(0).constraint
        }
    }
    
    internal override func preferredNavigationBarHidden() -> Bool {
        return false
    }
    
    internal func onImport() {
        let _ = ChaldeaManager.sharedInstance.decode_data()
    }
    
    internal func registerForKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(MaterialMgmtVC.keyboardWillShow(_:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MaterialMgmtVC.keyboardWillHide(_:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(_ notification:Notification){
        if let info = notification.userInfo,
            let kb_size = (info[UIKeyboardFrameEndUserInfoKey] as? CGRect)?.size,
            let duration = info[UIKeyboardAnimationDurationUserInfoKey] as? Double,
            let curve = info[UIKeyboardAnimationCurveUserInfoKey] as? UInt {
            
            if let constraint = self.collection_bottom_constraint{
                constraint.update(inset: (kb_size.height - 56))
                
                UIView.animate(withDuration: duration, delay: 0.0, options: UIViewAnimationOptions(rawValue: curve), animations: {[weak self] _ in
                    self?.view.layoutIfNeeded()
                }, completion:nil)
            }
            
        }
    }
    
    func keyboardWillHide(_ notification:Notification){
        if let info = notification.userInfo,
            let duration = info[UIKeyboardAnimationDurationUserInfoKey] as? Double,
            let curve = info[UIKeyboardAnimationCurveUserInfoKey] as? UInt {
            
            if let constraint = self.collection_bottom_constraint{
                constraint.update(inset: 0)
                UIView.animate(withDuration: duration, delay: 0.0, options: UIViewAnimationOptions(rawValue: curve), animations: {[weak self] _ in
                    self?.view.layoutIfNeeded()
                }, completion:nil)
            }
            
        }
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell:MaterialMgmtCell = collectionView.cellForItem(at: indexPath) as? MaterialMgmtCell else {return}
        cell.material_number_label.becomeFirstResponder()
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
