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


extension String{
    internal func indexOfSubString(string:String) -> Int?{
        if let range = self.range(of: string){
            let startPos = self.distance(from: self.startIndex, to: range.lowerBound)
            return startPos
        }
        return nil;
    }
    
    internal func substringWithRange(lowerBound:Int, length:Int) -> String{
        let start = self.index(self.startIndex, offsetBy: lowerBound)
        let end = self.index(start, offsetBy: length)
        return self.substring(with: start..<end)
    }
}
