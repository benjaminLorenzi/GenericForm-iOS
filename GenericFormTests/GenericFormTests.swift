//
//  GenericFormTests.swift
//  GenericFormTests
//
//  Created by Benjamin LORENZI on 07/08/2020.
//  Copyright © 2020 Benjamin LORENZI. All rights reserved.
//

import XCTest
@testable import GenericForm

class MockTextField: TextFieldValidatorAdaptble {

    var _text: String?
    func performValidation() {
        
    }
    
    var isEmpty: Bool {
        return _text ?? "" == ""
    }
    var validators: [Validators] = []

    var isValid: Bool {
        let (isValid, _) = performValidator()
        return isValid
    }

    var messages: [String] {
        let (_, messages) = performValidator()
        return messages
    }

    func performValidator() -> (Bool, [String]) {
        let (isValid, messages) = validators.applyAll(self)
        return (isValid, messages)
    }

}

class GenericFormTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {

        let mockTextField = MockTextField()
        mockTextField.validators = [.required, .email]

        mockTextField._text = "BobyLeMEc"

        XCTAssert(mockTextField.isValid == false)
        XCTAssert( mockTextField.messages.count == 1)
        XCTAssert( mockTextField.messages[0] == "Invalid email format")

        mockTextField._text = "BobyLeMEc@gmail.com"

        XCTAssert(mockTextField.isValid == true)
        XCTAssert( mockTextField.messages.count == 0)

        mockTextField.validators = [ .regularExpression(message: "No special caracateres and between 5-10", regexp:  try! NSRegularExpression(pattern: "^[a-zA-Z0-9]{5,10}$", options: []))]

        XCTAssert(mockTextField.isValid == false)
        XCTAssert( mockTextField.messages.count == 1)
        XCTAssert( mockTextField.messages[0] == "No special caracateres and between 5-10")

        mockTextField.validators = [ .pattern("^[a-zA-Z0-9]{5,10}$", message: "No special caracteres and between 5-10 caracteres")]


        mockTextField._text = "bobyJo"
        XCTAssert(mockTextField.isValid == true)
        XCTAssert( mockTextField.messages.count == 0)

        mockTextField._text = "bobyJo@"
        XCTAssert(mockTextField.isValid == false)
        XCTAssert( mockTextField.messages.count == 1)
        XCTAssert( mockTextField.messages[0] == "No special caracteres and between 5-10 caracteres")

        mockTextField._text = "bobyJo$"
        XCTAssert(mockTextField.isValid == false)
        XCTAssert( mockTextField.messages.count == 1)
        XCTAssert( mockTextField.messages[0] == "No special caracteres and between 5-10 caracteres")

        mockTextField._text = "bobyJoasdsadasdasdas"
        XCTAssert(mockTextField.isValid == false)
        XCTAssert( mockTextField.messages.count == 1)
        XCTAssert( mockTextField.messages[0] == "No special caracteres and between 5-10 caracteres")

        mockTextField.validators = [ .required, .custom({ textField in
            let isValid = !(textField._text ?? "").contains("benjamin")
            return (isValid, isValid ? [] : ["i don't like benjamin"])
        })]

        mockTextField._text = "saasdasdasbenjaminsdsad"
        XCTAssert(mockTextField.isValid == false)
        XCTAssert( mockTextField.messages.count == 1)
        XCTAssert( mockTextField.messages[0] == "i don't like benjamin")

        mockTextField._text = "dsdasdasdasdasdasdsa"
        XCTAssert(mockTextField.isValid == true)
        XCTAssert( mockTextField.messages.count == 0)

        mockTextField._text = ""
        XCTAssert(mockTextField.isValid == false)
        XCTAssert( mockTextField.messages.count == 1)

        let mockUserNameTextField = MockTextField()
        mockUserNameTextField.validators = [
            .required,
            .minLength(length: 5, message: "needs more that 5 characters!"),
            .maxLength(length: 25, message: "needs less that 25 characters!"),
            first(.custom({ neoTextField in
                guard let text = neoTextField._text else {
                    return (false, [])
                }
                let isEmail = text.isValidEmail()
                return (!isEmail, isEmail ? ["User should not be an email"] : [])
            }), .pattern("^[a-zA-Z0-9]*$", message: "The user should not have special characters"))
        ]

        mockUserNameTextField._text = "BobyLeMEc"
        XCTAssert(mockUserNameTextField.isValid)
        XCTAssert(mockUserNameTextField.messages.count == 0)

        mockUserNameTextField._text = "BobyLeMEc$"
        XCTAssert(!mockUserNameTextField.isValid)
        XCTAssert(mockUserNameTextField.messages.count == 1)
        XCTAssert(mockUserNameTextField.messages[0] == "The user should not have special characters")

        mockUserNameTextField._text = "BobyLeMEc@kds.com"
        XCTAssert(!mockUserNameTextField.isValid)
        XCTAssert(mockUserNameTextField.messages.count == 1)
        XCTAssert(mockUserNameTextField.messages[0] == "User should not be an email")

        mockUserNameTextField._text = "blo&"
        XCTAssert(!mockUserNameTextField.isValid)
        XCTAssert(mockUserNameTextField.messages.count == 2)
        XCTAssert(mockUserNameTextField.messages[0] == "needs more that 5 characters!")
        XCTAssert(mockUserNameTextField.messages[1] == "The user should not have special characters")

        mockUserNameTextField._text = "bloasdasdasdasdaawddwdqqqwwdqwds"
        XCTAssert(!mockUserNameTextField.isValid)
        XCTAssert(mockUserNameTextField.messages.count == 1)
        XCTAssert(mockUserNameTextField.messages[0] == "needs less that 25 characters!")

        mockUserNameTextField._text = "bloasdasdasdasdaawddwdqqqwwdqwdsˆ"
        XCTAssert(!mockUserNameTextField.isValid)
        XCTAssert(mockUserNameTextField.messages.count == 2)
        XCTAssert(mockUserNameTextField.messages[0] == "needs less that 25 characters!")
        XCTAssert(mockUserNameTextField.messages[1] == "The user should not have special characters")

        let mobileNumberTextField = MockTextField()
        mobileNumberTextField.validators = [.required, .mobileNumber]
        mobileNumberTextField._text = "603903594"
        XCTAssert(mobileNumberTextField.isValid)
        XCTAssert(mobileNumberTextField.messages.count == 0)

        mobileNumberTextField._text = "60390r3594"
        XCTAssert(!mobileNumberTextField.isValid)
        XCTAssert(mobileNumberTextField.messages[0] == "Invalid phone number")

        let passwordTextField = MockTextField()
        let passwordConfirmation = MockTextField()
        passwordTextField.validators = [.required, .password]

        func validatorPasswordMatch(_ neoTextField: TextFieldValidatorAdaptble) -> (Bool, [String]) {
            let passwordsMatch = passwordTextField._text ==
                passwordConfirmation._text
            return (passwordsMatch, passwordsMatch ? [] :["Password don't match"])
        }
        passwordConfirmation.validators = [.required, .custom(validatorPasswordMatch)]

        passwordTextField._text = "lechatestmort"
        XCTAssert(!passwordTextField.isValid)
        XCTAssert(passwordTextField.messages.count == 2)
        XCTAssert(passwordTextField.messages[0] == "Use at least one number and one letter")
        XCTAssert(passwordTextField.messages[1] == "Use at least one special character and no spaces")

        passwordTextField._text = "lechatestmort3"
        XCTAssert(!passwordTextField.isValid)
        XCTAssert(passwordTextField.messages.count == 1)
        XCTAssert(passwordTextField.messages[0] == "Use at least one special character and no spaces")

        passwordTextField._text = "lechatestmort3@"
        XCTAssert(passwordTextField.isValid)
        XCTAssert(passwordTextField.messages.count == 0)

        XCTAssert(!passwordConfirmation.isValid)
        XCTAssert(passwordConfirmation.messages.count == 2)
        XCTAssert(passwordConfirmation.messages[1] == "Password don\'t match")

        passwordConfirmation._text = "lechatestmort3@"
        XCTAssert(passwordConfirmation.isValid)
        XCTAssert(passwordConfirmation.messages.count == 0)

    }

}

