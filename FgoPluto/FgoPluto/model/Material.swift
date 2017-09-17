//
//  Material.swift
//  FgoPluto
//
//  Created by Zhang, Qianze on 17/09/2017.
//  Copyright © 2017 Plutoless Studio. All rights reserved.
//

import Foundation
import UIKit

class Material:BaseObject
{
    dynamic var id:Int = 0
    dynamic var text:String = ""
    dynamic var quantity:Int64 = 0
    dynamic var kind:Int{
        get{
            return self.kindFromId()
        }
    }
    dynamic lazy var image:UIImage? = {
        return UIImage(named: "material-\(self.id).jpg")
    }()
    
    override func fillvalues(data: [String : AnyObject]) {
        super.fillvalues(data: data)
        guard let id = Int(data["id"] as? String ?? "0") else {return}
        self.id = id
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    override static func indexedProperties() -> [String] {
        return ["id"]
    }
    
    override static func ignoredProperties() -> [String] {
        return ["image", "kind"]
    }
    
    private func kindFromId() -> Int{
        let mid = self.id
        if(mid >= 100 && mid < 110){
            return 0
        } else if(mid >= 110 && mid < 120){
            return 1
        } else if(mid >= 200 && mid < 210){
            return 2
        } else if(mid >= 210 && mid < 220){
            return 3
        } else if(mid >= 220 && mid < 230){
            return 4
        } else if(mid >= 300 && mid < 400){
            return 5
        } else if(mid >= 400 && mid < 500){
            return 6
        } else if(mid >= 500 && mid < 600){
            return 7
        } else if(mid == 800 || mid == 900){
            return 8
        }
        return -1
    }
    
    
    internal static func kind_name(kind:Int) -> String{
        switch kind {
        case 0:
            return "银棋"
        case 1:
            return "金棋"
        case 2:
            return "辉石"
        case 3:
            return "魔石"
        case 4:
            return "秘石"
        case 5:
            return "铜素材"
        case 6:
            return "银素材"
        case 7:
            return "金素材"
        case 8:
            return "特殊素材"
        default:
            return "\(kind)"
        }
    }
}
