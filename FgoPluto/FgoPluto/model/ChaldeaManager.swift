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
        self.configuration.schemaVersion = 1
        self.configuration.migrationBlock = {migration, oldSchemaVersion in
            if (oldSchemaVersion < 1) {
                // Nothing to do!
                // Realm will automatically detect new properties and removed properties
                // And will update the schema on disk automatically
            }
        }
        Realm.Configuration.defaultConfiguration = self.configuration
        
        
        //load default db
        self.prepareDefaultDB(target_url: db_url)
        self.prepareDataFromJS()
    }
    
    private func prepareDefaultDB(target_url:URL){
        if(!FileManager.default.fileExists(atPath: target_url.path)){
            if let default_db_url = Bundle.main.url(forResource: "default", withExtension: "realm"){
                try? FileManager.default.copyItem(at: default_db_url, to: target_url)
            }
        }
        
        do {
            let realm = try Realm()
            //materials must be written first
            realm.objects(Material.self).forEach({ material in
                self.materials.append(material)
            })
            //as servants have dependencies on materials
            realm.objects(Servant.self).forEach({ servant in
                self.servants.append(servant)
            })
            
            self.materials.sort { (m1, m2) -> Bool in
                return m1.id < m2.id
            }
        } catch {
            print(error)
        }
    }
    
    private func prepareDataFromJS(){
        let jscontext = JSContext(virtualMachine: JSVirtualMachine())
        guard let script_path = Bundle.main.path(forResource: "fgos_material.min", ofType: "js"), let data_js:Data = try? Data(contentsOf: URL(fileURLWithPath: script_path)) else {return}
        let script = String(data: data_js, encoding: .utf8)
        let _ = jscontext?.evaluateScript(script)
        
        let servants_array:[[String:AnyObject]] = jscontext?.objectForKeyedSubscript("Servantdb").toArray() as? [[String:AnyObject]] ?? []
        
        
        
        do {
            let realm = try Realm()
            try realm.write {
                realm.delete(realm.objects(Servant.self))
                
                self.servants = []
                for item:[String:AnyObject] in servants_array{
                    let servant = Servant()
                    servant.fillvalues(realm: realm, data: item)
                    
                    if (servant.id == 152) {
                        continue
                    }
                    self.servants.append(servant)
                    realm.add(servant)
                }
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
    
    internal func materialsByClass() -> [Int: [Material]]{
        var results:[Int: [Material]] = [:]
        
        for material:Material in self.materials{
            let kind:Int = material.kind
            if(results[kind] == nil){
                results[kind] = []
            }
            
            results[kind]?.append(material)
        }
        return results;
    }
    
    internal func encode_item_data() -> String{
//        var d = "*c", e = "*b", c = "*s", b = "*g", a = ""
//        
//        do {
//            let realm = try Realm()
//            let qp = realm.object(ofType: Material.self, forPrimaryKey: 900)
//            a = String(qp?.quantity ?? 0, radix:32).padding(toLength: 6, withPad: "0", startingAt: 0)
//            print()
//        } catch {
//            print(error)
//        }
        
        return ""
    }
    
    internal func decode_servant_data(){
        var code:String = "#08wxzh13awssf13dexs9p"
        
        do {
            let realm = try Realm()
            let initial = code.substringWithRange(lowerBound: 0, length: 1)
            
            if(initial != "#"){
                //improper
            } else {
                code = code.substringWithRange(lowerBound: 1, length: code.characters.count - 1)
                if(code.characters.count % 7 != 0){
                    //improper
                } else {
                    for i in 0..<code.characters.count / 7{
                        let piece = code.substringWithRange(lowerBound: i*7, length: 7)
                        let servant_source = piece.substringWithRange(lowerBound: 0, length: 2)
                        let servant_code:Int = strtol(servant_source, nil, 36)
                        guard let servant:Servant = realm.object(ofType: Servant.self, forPrimaryKey: servant_code) else {print("Servant \(servant_code) not found"); continue}
                        
                        let data_source = piece.substringWithRange(lowerBound: 2, length: 5)
                        let data_code:Int64 = strtoll(data_source, nil, 36)
                        let parsed_data_source = "\(data_code)"
                        
                        if(parsed_data_source.characters.count != 8){
                            //improper
                        } else {
                            let ad_from = Int(parsed_data_source.substringWithRange(lowerBound: 0, length: 1)) ?? 0
    //                        let ad_to = Int(parsed_data_source.substringWithRange(lowerBound: 1, length: 1)) ?? 4
                            let skill1_from = Int(parsed_data_source.substringWithRange(lowerBound: 2, length: 1)) ?? 0
    //                        let skill1_to = Int(parsed_data_source.substringWithRange(lowerBound: 3, length: 1)) ?? 10
                            let skill2_from = Int(parsed_data_source.substringWithRange(lowerBound: 4, length: 1)) ?? 0
    //                        let skill2_to = Int(parsed_data_source.substringWithRange(lowerBound: 5, length: 1)) ?? 10
                            let skill3_from = Int(parsed_data_source.substringWithRange(lowerBound: 6, length: 1)) ?? 0
    //                        let skill3_to = Int(parsed_data_source.substringWithRange(lowerBound: 7, length: 1)) ?? 10
                            
                            try realm.write {
                                servant.ad_level = ad_from - 1
                                servant.skill1_level = skill1_from
                                servant.skill2_level = skill2_from
                                servant.skill3_level = skill3_from
                            }
                        }
                    }
                }
            }
        }catch{
            print(error)
        }
    }
    
    
    internal func decode_item_data(){
        let code:String = "*c03a78j000a000o0008000z001k000e001u000z000b0007000j0018000h001w0012001h001f0016000k00080012000d001q00230014000s001x000n003c000a0001000l0004000s0004001h*b0047001d006i002t000l00000000*s0008000u000m000q001q000r000o001z0009000h0000*g000e000s001y001200180012001500090006000000000000"
        
        guard let realm = try? Realm() else {return}
        
        let h = 2 + 6 + 4 + 140 + 2 + 28 + 2 + 44 + 2 + 48
        let start = code.index(code.startIndex, offsetBy: 0)
        let end = code.index(code.startIndex, offsetBy: 1)
        let range = start..<end
        let initial = code.substring(with: range)
        if(initial != "*"){
            //improper format
        } else {
            if(code.characters.count == h){
                let e = code.substringWithRange(lowerBound: 2, length: 150)
                let g = code.substringWithRange(lowerBound: 154, length: 4*7)
                let d = code.substringWithRange(lowerBound: 184, length: 4*11)
                let c = code.substringWithRange(lowerBound: 230, length: 4*12)
                
                
                try? realm.write {
                    var obj = realm.object(ofType: Material.self, forPrimaryKey: 900)
                    obj?.quantity = strtoll(e.substringWithRange(lowerBound: 0, length: 6), nil, 36)
                    obj = realm.object(ofType: Material.self, forPrimaryKey: 800)
                    obj?.quantity = strtoll(e.substringWithRange(lowerBound: 6, length: 4), nil, 36)
                    
                    
                    //银棋
                    for i in 0..<7{
                        obj = realm.object(ofType: Material.self, forPrimaryKey: 100 + i)
                        obj?.quantity = strtoll(e.substringWithRange(lowerBound: 10+i*4, length: 4), nil, 36)
                    }
                    
                    //金棋
                    for i in 0..<7{
                        obj = realm.object(ofType: Material.self, forPrimaryKey: 110 + i)
                        obj?.quantity = strtoll(e.substringWithRange(lowerBound: 38+i*4, length: 4), nil, 36)
                    }
                    
                    for i in 0..<7{
                        obj = realm.object(ofType: Material.self, forPrimaryKey: 200 + i)
                        obj?.quantity = strtoll(e.substringWithRange(lowerBound: 66+i*4, length: 4), nil, 36)
                    }
                    
                    for i in 0..<7{
                        obj = realm.object(ofType: Material.self, forPrimaryKey: 210 + i)
                        obj?.quantity = strtoll(e.substringWithRange(lowerBound: 94+i*4, length: 4), nil, 36)
                    }
                    
                    for i in 0..<7{
                        obj = realm.object(ofType: Material.self, forPrimaryKey: 220 + i)
                        obj?.quantity = strtoll(e.substringWithRange(lowerBound: 122+i*4, length: 4), nil, 36)
                    }
                    
                    for i in 0..<7{
                        obj = realm.object(ofType: Material.self, forPrimaryKey: 300 + i)
                        obj?.quantity = strtoll(g.substringWithRange(lowerBound: i*4, length: 4), nil, 36)
                    }
                    
                    for i in 0..<11{
                        obj = realm.object(ofType: Material.self, forPrimaryKey: 400 + i)
                        obj?.quantity = strtoll(d.substringWithRange(lowerBound: i*4, length: 4), nil, 36)
                    }
                    
                    for i in 0..<12{
                        obj = realm.object(ofType: Material.self, forPrimaryKey: 500 + i)
                        obj?.quantity = strtoll(c.substringWithRange(lowerBound: i*4, length: 4), nil, 36)
                    }
                }
            } else {
                //improper format
            }
        }
        
    }
}
