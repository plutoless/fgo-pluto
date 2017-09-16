//
// Created by Zhang, Qianze on 07/06/2017.
// Copyright (c) 2017 Zhang, Qianze. All rights reserved.
//

import UIKit

extension UIColor {
    /**
     convenience constructor to get a color from hex string e.g. #333333
     @param hex, the color code string represented in hex form
     @returns return the color with given hex code
     */
    public convenience init(hex: String) {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.characters.count) != 6) {
            self.init(white: 0, alpha: 0)
            return
        }

        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        self.init(
                red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                alpha: CGFloat(1.0)
        )
    }
}
