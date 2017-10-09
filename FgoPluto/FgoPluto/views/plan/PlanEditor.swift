//
//  TargetEditor.swift
//  FgoPluto
//
//  Created by Zhang, Qianze on 29/09/2017.
//  Copyright © 2017 Plutoless Studio. All rights reserved.
//

import Foundation
import UIKit
import RangeSeekSlider

typealias PlanRange = (Int, Int)

protocol PlanEditDelegate : class{
    func didFinishEdit(servant:Servant, values:[PlanRange])
}

class PlanEditorItem : BaseView
{
    lazy var titleLabel:UILabel = {
        let label = UILabel()
        label.font = .font(size:14)
        label.textColor = UIColor(hex: "#4A4A4A")
        return label
    }()
    
    lazy var stepper : RangeSeekSlider = {
        let stepper = RangeSeekSlider()
        stepper.lineHeight = 10
        stepper.tintColor = UIColor(hex: "#E6E6E6")
        stepper.colorBetweenHandles = UIColor(hex: "#3C91E6")
        stepper.handleImage = UIImage(named: "slider_handler")
        stepper.labelPadding = 0.0
        stepper.minLabelColor = UIColor(hex: "#AAAAAA")
        stepper.maxLabelColor = UIColor(hex: "#AAAAAA")
        stepper.selectedHandleDiameterMultiplier = 1.2
        stepper.step = 1
//        stepper
//        stepper.labelFont = .font(size:12)
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
            maker.left.equalToSuperview().inset(20)
            maker.bottom.equalToSuperview()
            maker.top.equalToSuperview()
        }
        
        self.stepper.snp.makeConstraints { maker in
            maker.right.equalToSuperview().inset(20)
            maker.width.equalToSuperview().dividedBy(2)
            maker.top.equalToSuperview()
            maker.bottom.equalToSuperview()
        }
    }
}


class PlanEditor : BaseView
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
    
    var items:[PlanEditorItem] = []
    
    func setValues(values:[PlanRange]){
        for i in 0..<values.count{
            let value:PlanRange = values[i]
            let item = self.items[i]
            item.stepper.selectedMinValue = CGFloat(value.0)
            item.stepper.selectedMaxValue = CGFloat(value.1)
        }
    }
    var servant:Servant?
    weak var delegate:PlanEditDelegate?
    
    convenience init(servant:Servant) {
        self.init(frame: .zero)
        self.servant = servant
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func create_contents() {
        super.create_contents()
        self.backgroundColor = UIColor(hex: "#ffffff")
        
        self.addSubview(self.bottom_line)
        self.addSubview(self.title_label)
        self.addSubview(self.close_btn)
        
        
        let ad_item = PlanEditorItem(frame: .zero)
        ad_item.titleLabel.text = "灵基再临"
        ad_item.stepper.minValue = 0
        ad_item.stepper.maxValue = 4
        self.addSubview(ad_item)
        
        let skill1_item = PlanEditorItem(frame: .zero)
        skill1_item.titleLabel.text = "技能1"
        skill1_item.stepper.minValue = 1
        skill1_item.stepper.maxValue = 10
        self.addSubview(skill1_item)
        
        let skill2_item = PlanEditorItem(frame: .zero)
        skill2_item.titleLabel.text = "技能2"
        skill2_item.stepper.minValue = 1
        skill2_item.stepper.maxValue = 10
        self.addSubview(skill2_item)
        
        let skill3_item = PlanEditorItem(frame: .zero)
        skill3_item.titleLabel.text = "技能3"
        skill3_item.stepper.minValue = 1
        skill3_item.stepper.maxValue = 10
        self.addSubview(skill3_item)
        
        self.items = [ad_item, skill1_item, skill2_item, skill3_item]
    }
    
    override func set_constraints() {
        super.set_constraints()
        
        self.bottom_line.snp.makeConstraints { maker in
            maker.left.equalToSuperview()
            maker.right.equalToSuperview()
            maker.height.equalTo(0.5)
            maker.top.equalToSuperview().inset(54)
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
                maker.left.equalToSuperview()
                maker.right.equalToSuperview()
                maker.height.equalTo(44)
                
                if( i == 0){
                    maker.top.equalTo(weakself.bottom_line.snp.bottom).offset(10)
                } else {
                    maker.top.equalTo(weakself.items[i - 1].snp.bottom).offset(10)
                }
            })
        }
        
        
        
        self.close_btn.snp.makeConstraints {maker in
            maker.left.equalToSuperview()
            maker.right.equalToSuperview()
            maker.bottom.equalToSuperview()
            maker.height.equalTo(44)
        }
    }
    
    static func defaultRanges(servant:Servant) -> [PlanRange]{
        return [
            (servant.ad_level, servant.ad_level),
            (servant.skill1_level+1, servant.skill1_level+1),
            (servant.skill2_level+1, servant.skill2_level+1),
            (servant.skill3_level+1, servant.skill3_level+1)
        ]
    }
    
    static func showFrom(parent:UIView, plan: PlanItem) -> PlanEditor{
        let editor = PlanEditor(frame: .zero)
        editor.servant = plan.0
        let ranges:[PlanRange] = plan.1
        editor.setValues(values: ranges)
        
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
        
        let panel_height:CGFloat = 330
        parent.addSubview(editor)
        editor.tag = 1001
        editor.frame = CGRect(x: 0, y: parent.bounds.height, width: parent.bounds.width, height: panel_height)
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 5, options: .curveEaseInOut, animations: {
            mask.alpha = 0.4
            editor.frame.origin.y = parent.bounds.height - panel_height
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
    
    func values() -> [PlanRange]{
        var results:[PlanRange] = []
        for i in 0..<self.items.count{
            let item = self.items[i]
            results.append((lround(Double(item.stepper.selectedMinValue)), lround(Double(item.stepper.selectedMaxValue))))
        }
        return results
    }
    
    func close(_ result:Bool){
        guard let parentView = self.superview, let maskView = parentView.viewWithTag(1000) else {return}
        if(result){
            let results:[PlanRange] = self.values()
            if let servant:Servant = self.servant {
                self.delegate?.didFinishEdit(servant: servant, values: results)
            }
        }
        
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
