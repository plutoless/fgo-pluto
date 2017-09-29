//
//  ServantEditor.swift
//  FgoPluto
//
//  Created by Zhang, Qianze on 21/09/2017.
//  Copyright © 2017 Plutoless Studio. All rights reserved.
//

import Foundation
import UIKit
import GMStepper

protocol ServantEditDelegate : class{
    func didFinishEdit(servant_id:Int, values:[Int], atIndexPath:IndexPath?)
}

class ServantEditorItem : BaseView
{
    lazy var titleLabel:UILabel = {
        let label = UILabel()
        label.font = .font(size:12)
        label.textColor = UIColor(hex: "#4A4A4A")
        return label
    }()
    
    lazy var stepper : GMStepper = {
        let stepper = GMStepper(frame: .zero)
        stepper.labelFont = .font(size:12)
        return stepper
    }()
    
    override func create_contents() {
        super.create_contents()
        
        self.addSubview(self.titleLabel)
        self.addSubview(self.stepper)
    }
    
    override func set_constraints() {
        super.set_constraints()
        
        self.titleLabel.snp.makeConstraints { maker in
            maker.top.equalToSuperview().inset(5)
            maker.centerX.equalToSuperview()
        }
        
        self.stepper.snp.makeConstraints {[weak self] maker in
            guard let weakself = self else {return}
            maker.bottom.equalToSuperview()
            maker.left.equalToSuperview().inset(10)
            maker.right.equalToSuperview().inset(10)
            maker.top.equalTo(weakself.titleLabel.snp.bottom).offset(5)
            maker.height.equalTo(32)
        }
    }
}


class ServantEditor : BaseView
{
    lazy var bottom_line:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#DCDCDC")
        return view
    }()
    
    lazy var title_label:UILabel = {
        let label = UILabel()
        label.font = .font(size:14)
        label.textColor = UIColor(hex: "#4A4A4A")
        label.textAlignment = .center
        return label
    }()
    
    lazy var close_btn:UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("完成", for: .normal)
        btn.titleLabel?.font = .font(size:14)
        btn.backgroundColor = UIColor(hex: "#4A90E2")
        btn.addTarget(self, action: #selector(save), for: .touchUpInside)
        return btn
    }()
    
    var items:[ServantEditorItem] = []
    
    func setValues(values:[Int]){
        for i in 0..<values.count{
            let value = values[i]
            let item = self.items[i]
            item.stepper.value = Double(value)
        }
    }
    var indexPath:IndexPath?
    var servant_id:Int = 0
    weak var delegate:ServantEditDelegate?
    
    override func create_contents() {
        super.create_contents()
        self.backgroundColor = UIColor(hex: "#ffffff")
        
        self.addSubview(self.bottom_line)
        self.addSubview(self.title_label)
        self.addSubview(self.close_btn)
        
        
        let ad_item = ServantEditorItem(frame: .zero)
        ad_item.titleLabel.text = "灵基再临"
        ad_item.stepper.minimumValue = 0
        ad_item.stepper.maximumValue = 4
        self.addSubview(ad_item)
        
        let skill1_item = ServantEditorItem(frame: .zero)
        skill1_item.titleLabel.text = "技能1"
        skill1_item.stepper.minimumValue = 1
        skill1_item.stepper.maximumValue = 10
        self.addSubview(skill1_item)
        
        let skill2_item = ServantEditorItem(frame: .zero)
        skill2_item.titleLabel.text = "技能2"
        skill2_item.stepper.minimumValue = 1
        skill2_item.stepper.maximumValue = 10
        self.addSubview(skill2_item)
        
        let skill3_item = ServantEditorItem(frame: .zero)
        skill3_item.titleLabel.text = "技能3"
        skill3_item.stepper.minimumValue = 1
        skill3_item.stepper.maximumValue = 10
        self.addSubview(skill3_item)
        
        self.items = [ad_item, skill1_item, skill2_item, skill3_item]
    }
    
    override func set_constraints() {
        super.set_constraints()
        
        self.bottom_line.snp.makeConstraints { maker in
            maker.left.equalToSuperview()
            maker.right.equalToSuperview()
            maker.height.equalTo(0.5)
            maker.top.equalToSuperview().inset(44)
        }
        
        self.title_label.snp.makeConstraints {[weak self] maker in
            guard let weakself = self else {return}
            maker.left.equalToSuperview()
            maker.right.equalToSuperview()
            maker.top.equalToSuperview()
            maker.bottom.equalTo(weakself.bottom_line.snp.top)
        }
        
        for i in 0..<4{
            let item = self.items[i]
            item.snp.makeConstraints({[weak self] maker in
                guard let weakself = self else {return}
                maker.width.equalToSuperview().dividedBy(2)
                
                if(i % 2 == 0){
                    maker.left.equalToSuperview()
                } else {
                    maker.right.equalToSuperview()
                }
                
                if( i == 0){
                    maker.top.equalTo(weakself.bottom_line.snp.bottom).offset(10)
                } else {
                    if(i % 2 == 0){
                        maker.top.equalTo(weakself.items[i - 1].snp.bottom).offset(10)
                    } else {
                        maker.top.equalTo(weakself.items[i - 1].snp.top)
                    }
                }
            })
        }
        
        
        
        self.close_btn.snp.makeConstraints {[weak self] maker in
            guard let weakself = self else {return}
            maker.left.equalToSuperview()
            maker.right.equalToSuperview()
            maker.bottom.equalToSuperview()
            maker.height.equalTo(44)
            maker.top.equalTo(weakself.items[3].snp.bottom).offset(40)
        }
    }
    
    static func showFrom(parent:UIView, values: [Int], servant_id: Int, atIndexPath:IndexPath) -> ServantEditor{
        let editor = ServantEditor(frame: .zero)
        editor.setValues(values: values)
        editor.servant_id = servant_id
        editor.indexPath = atIndexPath
        
        let mask = UIView()
        let tap = UITapGestureRecognizer(target: editor, action: #selector(onTapMask(_:)))
        mask.tag = 1000
        mask.backgroundColor = UIColor(hex: "#000000")
        mask.addGestureRecognizer(tap)
        
        mask.alpha = 0
        parent.addSubview(mask)
        mask.snp.makeConstraints { maker in
            maker.top.equalToSuperview()
            maker.left.equalToSuperview()
            maker.right.equalToSuperview()
            maker.bottom.equalToSuperview()
        }
        
        parent.addSubview(editor)
        editor.tag = 1001
        editor.frame = CGRect(x: 0, y: parent.bounds.height, width: parent.bounds.width, height: 260)
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 5, options: .curveEaseInOut, animations: {
            mask.alpha = 0.4
            editor.frame.origin.y = parent.bounds.height - 260
        }, completion: nil)
        
        return editor
    }
    
    func onTapMask(_ tap:UITapGestureRecognizer){
        self.cancel()
    }
    
    func save(){
        self.close(true)
    }
    
    func cancel(){
        self.close(false)
    }
    
    func close(_ result:Bool){
        guard let parentView = self.superview, let maskView = parentView.viewWithTag(1000) else {return}

        var results:[Int] = [0,0,0,0]
        for i in 0..<self.items.count{
            let item = self.items[i]
            results[i] = Int(item.stepper.value)
        }
        
        self.delegate?.didFinishEdit(servant_id: self.servant_id, values: results, atIndexPath: self.indexPath)
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 5, options: .curveEaseInOut, animations: { [weak self] in
            maskView.alpha = 0
            self?.frame.origin.y = parentView.bounds.height
        }) {[weak self] finished in
            if(finished){
                maskView.removeFromSuperview()
                self?.removeFromSuperview()
            }
        }
        
    }
}
