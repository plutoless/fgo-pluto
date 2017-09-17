//
//  Servant.swift
//  FgoPluto
//
//  Created by Zhang, Qianze on 17/09/2017.
//  Copyright © 2017 Plutoless Studio. All rights reserved.
//

import Foundation
import UIKit

class Servant : BaseObject
{
    dynamic var id:Int = 0
    dynamic var text:String = ""
    dynamic var kind:Int = -1
    dynamic lazy var image:UIImage? = {
        return UIImage(named: "servant-\(String(format:"%03d", self.id)).jpg")
    }()
    
    override static func ignoredProperties() -> [String] {
        return ["image"]
    }
    
    override static func indexedProperties() -> [String] {
        return ["id"]
    }
    
    override func fillvalues(data: [String : AnyObject]) {
        self.id = data["id"] as? Int ?? 0
        self.text = data["text"] as? String ?? ""
        self.kind = data["kind"] as? Int ?? -1
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
