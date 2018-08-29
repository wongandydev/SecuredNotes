//
//  UIColor+Extension.swift
//  GoingToJapan
//
//  Created by Andy Wong on 8/28/18.
//  Copyright © 2018 Andy Wong. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        let newRed = CGFloat(red)/255
        let newGreen = CGFloat(green)/255
        let newBlue = CGFloat(blue)/255
        
        self.init(red: newRed, green: newGreen, blue: newBlue, alpha: 1.0)
    }
    
    class var lightPink: UIColor {
        return UIColor(red:0.98, green:0.73, blue:1.00, alpha:1.0)
    }
    
    class var mintGreen: UIColor {
        return UIColor(red:0.77, green:0.96, blue:1.00, alpha:1.0)
    }
    
    class var pastelPurple: UIColor {
        return UIColor(red:0.90, green:0.76, blue:1.00, alpha:1.0)
    }
}
