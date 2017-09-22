//
//  Servant.swift
//  FgoPluto
//
//  Created by Zhang, Qianze on 17/09/2017.
//  Copyright © 2017 Plutoless Studio. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class Servant : BaseObject
{
    dynamic var id:Int = 0
    dynamic var text:String = ""
    dynamic var kind:Int = -1
    dynamic var rank:Int = -1
    dynamic var ad_level:Int = 0
    dynamic var skill1_level:Int = 0
    dynamic var skill2_level:Int = 0
    dynamic var skill3_level:Int = 0
    
    dynamic lazy var image:UIImage? = {
        return UIImage(named: "servant-\(String(format:"%03d", self.id)).jpg")
    }()
    let AdAgain1 = List<Material>()
    let AdAgain2 = List<Material>()
    let AdAgain3 = List<Material>()
    let AdAgain4 = List<Material>()
    let skill1 = List<Material>()
    let skill2 = List<Material>()
    let skill3 = List<Material>()
    let skill4 = List<Material>()
    let skill5 = List<Material>()
    let skill6 = List<Material>()
    let skill7 = List<Material>()
    let skill8 = List<Material>()
    let skill9 = List<Material>()
    
    override static func ignoredProperties() -> [String] {
        return ["image"]
    }
    
    override static func indexedProperties() -> [String] {
        return ["id"]
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    override func fillvalues(realm: Realm, data: [String : AnyObject]) {
        super.fillvalues(realm: realm, data: data)
        self.id = data["id"] as? Int ?? 0
        self.text = data["text"] as? String ?? ""
        self.kind = data["kind"] as? Int ?? -1
        self.rank = data["value"] as? Int ?? -1
        
        self.fill_materials(realm: realm, data: data, key: "AdAgain1", target: self.AdAgain1)
        self.fill_materials(realm: realm, data: data, key: "AdAgain2", target: self.AdAgain2)
        self.fill_materials(realm: realm, data: data, key: "AdAgain3", target: self.AdAgain3)
        self.fill_materials(realm: realm, data: data, key: "AdAgain4", target: self.AdAgain4)
        self.fill_materials(realm: realm, data: data, key: "skill1", target: self.skill1)
        self.fill_materials(realm: realm, data: data, key: "skill2", target: self.skill2)
        self.fill_materials(realm: realm, data: data, key: "skill3", target: self.skill3)
        self.fill_materials(realm: realm, data: data, key: "skill4", target: self.skill4)
        self.fill_materials(realm: realm, data: data, key: "skill5", target: self.skill5)
        self.fill_materials(realm: realm, data: data, key: "skill6", target: self.skill6)
        self.fill_materials(realm: realm, data: data, key: "skill7", target: self.skill7)
        self.fill_materials(realm: realm, data: data, key: "skill8", target: self.skill8)
        self.fill_materials(realm: realm, data: data, key: "skill9", target: self.skill9)
    }
    
    
    private func fill_materials(realm: Realm, data: [String : AnyObject], key:String, target:List<Material>){
        if let materialsMap = data[key] as? [String:Int] {
            for item_id:String in materialsMap.keys{
                if(item_id == "elesh"){
                    continue
                }
                guard let id = Int(item_id), let quantity = materialsMap[item_id] else {print("failed to convert id");continue}
                guard let material = realm.object(ofType: Material.self, forPrimaryKey: id) else {print("unknown item \(item_id)"); continue}
                
                
                
                if(quantity > 0){
                    for _ in 0..<quantity{
                        target.append(material)
                    }
                }
            }
        }
    }
    
    internal static func kind_name(kind:Int) -> String{
        switch kind {
        case 0:
            return "剑阶"
        case 1:
            return "弓阶"
        case 2:
            return "枪阶"
        case 3:
            return "骑阶"
        case 4:
            return "术阶"
        case 5:
            return "杀阶"
        case 6:
            return "狂阶"
        case 7:
            return "尺阶"
        case 8:
            return "仇阶"
        case 9:
            return "盾阶"
        case 10:
            return "Mooncell"
        case 11:
            return "Alter Ego"
        default:
            return "\(kind)"
        }
    }
}
