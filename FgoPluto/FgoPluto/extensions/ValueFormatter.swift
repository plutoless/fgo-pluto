//
//  Formatter.swift
//  FgoPluto
//
//  Created by Zhang, Qianze on 27/09/2017.
//  Copyright © 2017 Plutoless Studio. All rights reserved.
//

import Foundation

class ValueFormatter:NSObject
{
    static func format_abbr_big_number(value:Double) -> String{
        let input = value
        var output = input
        
        if(input >= 1*pow(10, 12)){
            output = input / (1*pow(10, 12))
        } else if(input >= 1*pow(10, 8)){
            output = input / (1*pow(10, 8))
        } else if(input >= 1*pow(10, 4)){
            output = input / (1*pow(10, 4))
        }
        
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: output)) ?? "\(value)"
    }
    
    static func format_unit_big_number(value:Double) -> String{
        let input = value
        
        if(input >= 1*pow(10, 12)){
            return "万亿"
        } else if(input >= 1*pow(10, 8)){
            return "亿"
        } else if(input >= 1*pow(10, 4)){
            return "万"
        }
        return "个"
    }
}
