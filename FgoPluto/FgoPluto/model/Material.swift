//
//  Material.swift
//  FgoPluto
//
//  Created by Zhang, Qianze on 17/09/2017.
//  Copyright © 2017 Plutoless Studio. All rights reserved.
//

import Foundation

class Material:BaseObject
{
    dynamic var id:Int = 0
    dynamic var text:String = ""
    
    
    override func fillvalues(data: [String : AnyObject]) {
        super.fillvalues(data: data)
        self.id = Int(data["id"] as? String ?? "0") ?? 0
    }
    
    override static func indexedProperties() -> [String] {
        return ["id"]
    }
}
