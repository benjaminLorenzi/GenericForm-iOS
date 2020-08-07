//
//  Validators.swift
//  GenericForm
//
//  Created by Benjamin LORENZI on 07/08/2020.
//  Copyright © 2020 Benjamin LORENZI. All rights reserved.
//

import Foundation
import UIKit


protocol TextFieldValidatorAdaptble {

    var _text: String? {
        get set
    }

    var isEmpty: Bool {
        get
    }

    var validators: [Validators] { get set }

    func performValidation()
}

extension TextFieldValidatorAdaptble {
    var errorsMessages: [String] {
        return self.validators.applyAll(self).1
    }
    var isValid: Bool {
        return self.validators.applyAll(self).0
    }
}

extension Array where Element==TextFieldValidatorAdaptble {

    func performValidation() {
        return self.forEach { $0.performValidation() }
    }

    var isValid: Bool {
        return self.allSatisfy { $0.isValid }
    }

}


func first(_ validators: Validators...) -> Validators {
    return Validators.custom({ formTextField in
        for validator in validators {
            let (isValid, messages) = validator.invoke()(formTextField)
            if isValid == false {
                return (isValid, messages)
            }
        }
        return (true, [])
    })
}


extension Array where Element==Validators {

    func applyAll(_ formTextField: TextFieldValidatorAdaptble) -> (Bool, [String]) {
        var isValid = true
        var messages: [String] = []

        self.forEach { validator in

            let (valid, message) = validator.invoke()(formTextField)
            isValid = isValid && valid
            messages += message

        }
        return (isValid, messages)
    }
}

enum Validators {
    case required
    case regularExpression(message: String, regexp: NSRegularExpression)
    case pattern(_ regex: String, message: String)
    case mobileNumber
    case noEmojis(message: String)
    case email
    case password
    //case union(_ validators: Validators...)
    case minLength(length: Int, message: String)
    case maxLength(length: Int, message: String)
    case custom((_ formTextField: TextFieldValidatorAdaptble) -> (Bool, [String]))
    case notOnlyWhiteSpaces

    func invoke() -> (_ formTextField: TextFieldValidatorAdaptble) -> (Bool, [String]) {
        switch self {
        case .required:
            return requiredValidator
        case let .regularExpression(message, regexp):
            return regularExpressionValidator(message: message, regexp: regexp)
        case let .pattern(regex, message):
            return regularExpressionValidator(message: message, regexp: try! NSRegularExpression(pattern: regex, options: []))
        case .email:
            return emailValidator
        case .password:
            return passwordValidator
        case let .minLength(length, message):
            return minOrMaxLengthValidator(isMin: true, length: length, message: message)
        case let .maxLength(length, message):
            return minOrMaxLengthValidator(isMin: false, length: length, message: message)
        case .mobileNumber:
            return mobileNumberValidator
        case let .noEmojis(message):
            return noEmojisValidator(message)
        case let .custom(customFct):
            return customFct
        case .notOnlyWhiteSpaces:
            return notOnlyWhiteSpaces
        }
    }

    private func noEmojisValidator(_ message: String) -> (_ formTextField: TextFieldValidatorAdaptble) -> (Bool, [String]) {

        func noEmo(_ formTextField: TextFieldValidatorAdaptble) -> (Bool, [String]) {
            guard let text = formTextField._text, !text.isEmpty else {
                return (true, [])
            }

            let messages: [String] = text.containsEmoji ? [message] : []
            return (messages.count == 0, messages)
        }

        return noEmo
    }

    private func minOrMaxLengthValidator(isMin: Bool = true, length: Int, message: String) -> (_ formTextField: TextFieldValidatorAdaptble) -> (Bool, [String]) {

        func minOrMax(_ formTextField: TextFieldValidatorAdaptble) -> (Bool, [String]) {
            guard let text = formTextField._text, !text.isEmpty else {
                return (false, [message])
            }
            let isValid = isMin ? text.count >= length : text.count <= length
            return (isValid, isValid ? [] : [message])
        }

        return minOrMax
    }


    private func passwordValidator(_ formTextField: TextFieldValidatorAdaptble) -> (Bool, [String]) {
        guard let text = formTextField._text, !text.isEmpty else {
            return (true, [])
        }
        let messages = text.getPasswordValidationErrors()
        return (messages.count == 0, messages)
    }

    private func requiredValidator(_ formTextField: TextFieldValidatorAdaptble) -> (Bool, [String]) {
        guard let text = formTextField._text, !text.isEmpty, text != "" else {
            return (false, [NSLocalizedString("field_empty_error", comment: "")])
        }
        var tempText = text
        while tempText.count > 0 && (
            tempText[tempText.index(before: tempText.endIndex)]
                == "\n" ||  tempText[tempText.index(before: tempText.endIndex)] == " ") {
                    tempText = String(tempText.dropLast())
        }
        guard !tempText.isEmpty, tempText != "" else {
            return (false, [NSLocalizedString("field_empty_error", comment: "")])
        }
        return (true, [])
    }

    private func regularExpressionValidator(message: String, regexp: NSRegularExpression) -> (_ formTextField: TextFieldValidatorAdaptble) -> (Bool, [String]) {

        func regularExpressionValidator(_ formTextField: TextFieldValidatorAdaptble) -> (Bool, [String]) {
            guard let text = formTextField._text, !text.isEmpty else {
                return (true, [])
            }

            guard text.count > 0, regexp.isFullMatch(text) else {
                return (false, [message])
            }
            return (true, [])
        }

        return regularExpressionValidator
    }

    private func mobileNumberValidator(_ formTextField: TextFieldValidatorAdaptble) -> (Bool, [String]) {
        return regularExpressionValidator(message: NSLocalizedString("mobile_number_invalid", comment: ""), regexp: NSRegularExpression.phoneNumberRegEx())(formTextField)
    }
    
    private func emailValidator(_ formTextField: TextFieldValidatorAdaptble) -> (Bool, [String]) {
        let invalidEmail = NSLocalizedString("email_format_invalid_error", comment: "")
        guard var text = formTextField._text, !text.isEmpty else {
            return (true, [])
        }
        text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard text.count > 0, text.isValidEmail() else {
            return (false, [invalidEmail])
        }
        return (true, [])
    }

    private func notOnlyWhiteSpaces(_ formTextField: TextFieldValidatorAdaptble) -> (Bool, [String]) {
        if let text = formTextField._text {
            for char in text where !char.isWhitespace {
                return (true, [])
            }
        }
        return (false, [NSLocalizedString("field_empty_error", comment: "")])
    }
}

