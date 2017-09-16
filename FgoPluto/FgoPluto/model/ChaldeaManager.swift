//
//  ChaldeaManager.swift
//  FgoPluto
//
//  Created by Zhang, Qianze on 17/09/2017.
//  Copyright © 2017 Plutoless Studio. All rights reserved.
//

import Foundation
import JavaScriptCore

class ChaldeaManager: NSObject
{
    internal var servants:[Servant] = []
    
    static let sharedInstance: ChaldeaManager = {
        let instance = ChaldeaManager()
        
        return instance
    }()
    
    
    override init(){
        super.init()
        
        let context = JSContext(virtualMachine: JSVirtualMachine())
        guard let script_path = Bundle.main.path(forResource: "fgos_material.min", ofType: "js"), let data_js:Data = try? Data(contentsOf: URL(fileURLWithPath: script_path)) else {return}
        let script = String(data: data_js, encoding: .utf8)
        let _ = context?.evaluateScript(script)
        
        let servants_array:[[String:AnyObject]] = context?.objectForKeyedSubscript("Servantdb").toArray() as? [[String:AnyObject]] ?? []
        
        for item:[String:AnyObject] in servants_array{
            let servant = Servant(data: item)
            if (servant.id == 152) {
                continue
            }
            self.servants.append(servant)
        }
    }
    
    
    internal func servantsByClass() -> [String: [Servant]]{
        var results:[String: [Servant]] = [:]
        
        for servant:Servant in self.servants{
            let kind:String = servant.kind_name()
            if(results[kind] == nil){
                results[kind] = []
            }
            
            results[kind]?.append(servant)
        }
        return results;
    }
}
