//
//  ChaldeaManager.swift
//  FgoPluto
//
//  Created by Zhang, Qianze on 17/09/2017.
//  Copyright © 2017 Plutoless Studio. All rights reserved.
//

import Foundation
import JavaScriptCore
import RealmSwift
import Realm

class ChaldeaManager: NSObject
{
    private let USER_CONTEXT = "USER_CONTEXT"
    private struct UserContext{
        static let account = "account"
    }
    
    //chaldea relevant
    internal var servants:[Servant] = []
    internal var materials:[Material] = []
    internal var configuration:Realm.Configuration = Realm.Configuration()
    
    //context data
    private var _contexts:[String:AnyObject]?
    internal var contexts:[String:AnyObject] {
        get{
            if(_contexts == nil){
                if let data = UserDefaults.standard.value(forKey: USER_CONTEXT) as? Data{
                    _contexts = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String: AnyObject]
                }
            }
            return _contexts ?? [:]
        }
        set{
            _contexts = newValue
        }
    }
    
    internal var account:String{
        get{
            return self.contexts[UserContext.account] as? String ?? "default"
        }
        set{
            self.contexts[UserContext.account] = newValue as AnyObject
            self.sync_contexts()
        }
    }
    
    
    static let sharedInstance: ChaldeaManager = {
        let instance = ChaldeaManager()
        
        return instance
    }()
    
    
    private func sync_contexts(){
        guard let c = _contexts else {return}
        let data = NSKeyedArchiver.archivedData(withRootObject: c)
        UserDefaults.standard.setValue(data, forKey: USER_CONTEXT)
        UserDefaults.standard.synchronize()
    }
    
    override init(){
        super.init()
        
        //prepare db config
        let db_url = URL.documentFolderPath().changeDirectory(folder: "db").file(path: "\(self.account).realm")
        self.configuration.fileURL = db_url
        Realm.Configuration.defaultConfiguration = self.configuration
        
        
        //load default db
//        self.prepareDefaultDB(target_url: db_url)
        
        
        self.prepareDataFromJS()
    }
    
    private func prepareDefaultDB(target_url:URL){
        if(!FileManager.default.fileExists(atPath: target_url.path)){
            if let default_db_url = Bundle.main.url(forResource: "default", withExtension: "realm"){
                try? FileManager.default.copyItem(at: default_db_url, to: target_url)
            }
        }
        
        
        if let realm = try? Realm(){
            realm.objects(Servant.self).forEach({ servant in
                self.servants.append(servant)
            })
        }
    }
    
    private func prepareDataFromJS(){
        let jscontext = JSContext(virtualMachine: JSVirtualMachine())
        guard let script_path = Bundle.main.path(forResource: "fgos_material.min", ofType: "js"), let data_js:Data = try? Data(contentsOf: URL(fileURLWithPath: script_path)) else {return}
        let script = String(data: data_js, encoding: .utf8)
        let _ = jscontext?.evaluateScript(script)
        
        let servants_array:[[String:AnyObject]] = jscontext?.objectForKeyedSubscript("Servantdb").toArray() as? [[String:AnyObject]] ?? []
        let materials_map:[String:Int] = jscontext?.objectForKeyedSubscript("mTotalNum").toDictionary() as? [String:Int] ?? [:]
        
        for item:[String:AnyObject] in servants_array{
            let servant = Servant()
            servant.fillvalues(data: item)
            
            if (servant.id == 152) {
                continue
            }
            self.servants.append(servant)
        }
        
        
        
        for item_id:String in materials_map.keys{
            let material = Material()
            material.id = Int(item_id) ?? 0
            self.materials.append(material)
        }
        
        do {
            let realm = try Realm()
            try? realm.write {
                realm.deleteAll()
                realm.add(self.servants)
                realm.add(self.materials)
            }
        } catch {
            print(error)
        }
    }
    
    internal func servantsByClass() -> [Int: [Servant]]{
        var results:[Int: [Servant]] = [:]
        
        for servant:Servant in self.servants{
            let kind:Int = servant.kind
            if(results[kind] == nil){
                results[kind] = []
            }
            
            results[kind]?.append(servant)
        }
        return results;
    }
}
