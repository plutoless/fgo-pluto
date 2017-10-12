//
//  Plan.swift
//  FgoPluto
//
//  Created by Zhang, Qianze on 12/10/2017.
//  Copyright © 2017 Plutoless Studio. All rights reserved.
//

import Foundation
import RealmSwift

class Plan : BaseObject
{
    //group id is used to bundle multiple plan items into one
    //they will share the same group id
    dynamic var groupId:Int = -1
    dynamic var servant:Servant?
    //as realm does not support array of primitive types
    //we store the plan numbers as a string like below
    //ad_from, ad_to, skill1_from, skill1_to, skill2_from, skill2_to, skill3_from, skill3_to
    dynamic var archived_plan:String = "0,0,0,0,0,0"
    var plan:[PlanRange]?{
        let plan_values:[String] = self.archived_plan.components(separatedBy: ",")
        if(plan_values.count != 6){
            return nil
        }
        
        var results:[PlanRange] = []
        var plan_int_vals:[Int] = []
        for i in 0..<plan_values.count{
            let val_str:String = plan_values[i]
            guard let val:Int = Int(val_str) else {return nil}
            plan_int_vals.append(val)
            if(i % 2 == 1){
                results.append((plan_int_vals[i - 1], plan_int_vals[i]))
            }
        }
        return results
    }
    
    override static func ignoredProperties() -> [String] {
        return ["plan"]
    }
}
