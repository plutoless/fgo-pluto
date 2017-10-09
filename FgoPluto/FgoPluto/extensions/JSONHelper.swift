//
//  JSONHelper.swift
//  FgoPluto
//
//  Created by Zhang, Qianze on 06/10/2017.
//  Copyright © 2017 Plutoless Studio. All rights reserved.
//

import Foundation

class JSONHelper : NSObject{
    static func loadJsonArray(file:String, type:String) -> [AnyObject] {
        guard let script_path = Bundle.main.path(forResource: file, ofType: type), let data_js:Data = try? Data(contentsOf: URL(fileURLWithPath: script_path)) else {return []}
        var results:[AnyObject] = []
        do{
            results = try JSONSerialization.jsonObject(with: data_js, options: .allowFragments) as! [AnyObject]
        } catch{
            print(error)
        }
        return results
    }
}
