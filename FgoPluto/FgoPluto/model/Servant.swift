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
    internal var id:Int
    internal var name:String
    internal var kind:Int
    lazy var image:UIImage? = {
        return UIImage(named: "servant-\(String(format:"%03d", self.id)).jpg")
    }()
    
    required init(data:[String:AnyObject]) {
        self.id = data["id"] as? Int ?? 0
        self.name = data["text"] as? String ?? ""
        self.kind = data["kind"] as? Int ?? -1
        super.init()
    }
    
    
    internal func kind_name() -> String{
        switch self.kind {
        case 1:
            return "剑阶"
        default:
            return "\(self.kind)"
        }
    }
}
