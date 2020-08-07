//
//  UIColor+GenericForm.swift
//  GenericForm
//
//  Created by Benjamin LORENZI on 07/08/2020.
//  Copyright © 2020 Benjamin LORENZI. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    static func ErrorColor() -> UIColor {
        return UIColor(red: 255, green: 59, blue: 59, alpha: 1.0)
    }
    
    static func TextFieldDefaultColor() -> UIColor {
        return UIColor(red: 0, green: 104, blue: 144, alpha: 1.0)
    }
    
    static func TextColor() -> UIColor {
        return UIColor(red: 34, green: 50, blue: 74, alpha: 1.0)
    }
    
    static func HighlightColor() -> UIColor {
        return UIColor(red: 0, green: 155, blue: 187, alpha: 1.0)
    }
}
