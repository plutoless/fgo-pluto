//
//  String.swift
//  FgoPluto
//
//  Created by Zhang, Qianze on 17/09/2017.
//  Copyright © 2017 Plutoless Studio. All rights reserved.
//

import Foundation

extension URL{
    internal static func documentFolderPath() -> URL{
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    internal func changeDirectory(folder:String) -> URL{
        let url = self.appendingPathComponent(folder)
        let fileManager = FileManager.default
        var isDir : ObjCBool = false
        if(!fileManager.fileExists(atPath: url.path, isDirectory: &isDir)){
            try? fileManager.createDirectory(at: url, withIntermediateDirectories: false, attributes: nil)
        }
        return url
    }
    
    internal func file(path:String) -> URL{
        return self.appendingPathComponent(path)
    }
}
