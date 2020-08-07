//
//  CreateAccountFormViewController.swift
//  GenericForm
//
//  Created by Benjamin LORENZI on 07/08/2020.
//  Copyright © 2020 Benjamin LORENZI. All rights reserved.
//

import UIKit

class CreateAccountFormViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        fields = [nameField, phoneNumberField, emailField]
        
        nameField.validators = [.required]
        emailField.validators = [.required, .email]
        phoneNumberField.validators = [.required, .mobileNumber]
        
        buildUI()
    }
    
    func buildUI() {
        nameField.placeholder = "Name"
        nameField.textField.autocorrectionType = .no
        nameField.textField.autocapitalizationType = .none
        nameField.textField.accessibilityIdentifier = "emailField"
        
        emailField.placeholder = "Email address"
        emailField.keyboardType = .emailAddress
        emailField.textField.autocapitalizationType = UITextAutocapitalizationType.none
        emailField.textField.accessibilityIdentifier = "emailField"
        
        phoneNumberField.placeholder = "Phone Number"
        phoneNumberField.keyboardType = .phonePad
        phoneNumberField.textField.autocapitalizationType = UITextAutocapitalizationType.none
        phoneNumberField.textField.accessibilityIdentifier = "phoneNumber"
        
    }

    @IBOutlet weak var nameField: FormTextField!
    @IBOutlet weak var phoneNumberField: FormTextField!
    @IBOutlet weak var emailField: FormTextField!
    
    var fields: [FormTextField] = []
    
    @IBAction func submitAction(_ sender: Any) {
        for field in fields {
            field.performValidation()
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
