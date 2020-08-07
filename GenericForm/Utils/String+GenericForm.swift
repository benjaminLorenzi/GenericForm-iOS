//
//  String+GenericForm.swift
//  GenericForm
//
//  Created by Benjamin LORENZI on 07/08/2020.
//  Copyright © 2020 Benjamin LORENZI. All rights reserved.
//

import Foundation

extension String {
    
    func getPasswordValidationErrors() -> [String] {
        var errors: [String] = []
        let hasNumbers = self.rangeOfCharacter(from: .decimalDigits) != nil
        let hasLetters = self.rangeOfCharacter(from: .letters) != nil
        let hasWhitespaces = self.rangeOfCharacter(from: .whitespacesAndNewlines) != nil

        if !hasLetters || !hasNumbers {
            errors.append(NSLocalizedString("password_number_letter_suggestion", comment: ""))
        }

        if self.count < 8 || self.count > 20 {
            errors.append(NSLocalizedString("password_has_wrong_length", comment: ""))
        }

        if hasWhitespaces || (NSRegularExpression.specialCharactersRegEx().rangeOfFirstMatch(in: self, options: [], range: NSRange(location: 0, length: self.count)) == NSRange(location: NSNotFound, length: 0)) {
            errors.append(NSLocalizedString("specials_characters", comment: ""))
        }

        return errors
    }
    
    func isValidEmail() -> Bool {
        let emailRange = getEmailLinkRange()
        return emailRange != nil ? emailRange!.length == self.count : false
    }

    var containsEmoji: Bool {
        for scalar in unicodeScalars {
            switch scalar.value {
            case 0x1F600...0x1F64F, // Emoticons
            0x1F300...0x1F5FF, // Misc Symbols and Pictographs
            0x1F680...0x1F6FF, // Transport and Map
            0x2600...0x26FF,   // Misc symbols
            0x2700...0x27BF,   // Dingbats
            0xFE00...0xFE0F,   // Variation Selectors
            0x1F900...0x1F9FF, // Supplemental Symbols and Pictographs
            0x1F1E6...0x1F1FF: // Flags
                return true
            default:
                continue
            }
        }
        return false
    }
    
    func getEmailLinkRange() -> NSRange? {
        let linkDetector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let range = NSRange(location: 0, length: self.count)
        let result = linkDetector?.firstMatch(in: self, options: .reportCompletion, range: range)
        let scheme = result?.url?.scheme ?? ""
        return scheme == "mailto" ? result?.range : nil
    }
}
