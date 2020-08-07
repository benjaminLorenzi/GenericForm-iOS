//
//  NSRegularExpression+GenericForm.swift
//  GenericForm
//
//  Created by Benjamin LORENZI on 07/08/2020.
//  Copyright © 2020 Benjamin LORENZI. All rights reserved.
//

import Foundation

extension NSRegularExpression {

    static func phoneNumberRegEx(_ options: NSRegularExpression.Options = []) -> NSRegularExpression {
        let pattern = "^\\+?[1-9]\\d{5,14}$"
        return try! NSRegularExpression(pattern: pattern, options: options)
    }
    
    static func specialCharactersRegEx(_ options: NSRegularExpression.Options = []) -> NSRegularExpression {
        let pattern = "[^a-zA-Z0-9]"
        return try! NSRegularExpression(pattern: pattern, options: options)
    }

    func isFullMatch(_ str: String, options: NSRegularExpression.MatchingOptions = []) -> Bool {
        let range = NSRange(location: 0, length: str.count)
        return rangeOfFirstMatch(in: str, options: options, range: range) == range
    }
}
