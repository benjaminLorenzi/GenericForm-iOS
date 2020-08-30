# Generic Form 

Generic Form : a generic implementation of a form 

## Example of usage in a ViewController 

<img src="formExample.png" with="800" height= "800">

```swift

class ViewController : UIViewCoordinable {
    
    // The IBOutlet from the xib 
    @IBOutlet weak var nameField: FormTextField!
    @IBOutlet weak var phoneNumberField: FormTextField!
    @IBOutlet weak var emailField: FormTextField!
    
    var fields: [FormTextField] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Store all the FormTextField to handle the form state
        fields = [nameField, phoneNumberField, emailField]
        
        // Write your validators logic here
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
    
    // Bind the validation logic 
    @IBAction func submitAction(_ sender: Any) {
        for field in fields {
            field.performValidation()
        }
    }
}

```

## Write your own validation logic 

<img src="customEx.png" with="300" height= "300">

```swift

nameField.validators = [.custom({ textField in
    let isValid = !(textField._text ?? "").contains("benjamin")
    return (isValid, isValid ? [] : ["i don't like benjamin"])
})
]

```
Validators is an enum with severals utils functions that you can use :
- required 
- regular expression
- email
- password
....
You can use the custom logic function if you need to write your own business logic. 
It use a closure with a textField as parameter.
It should return a tuple (Bool, [String]) where the bool argument say if the field is valid and thee second return the errors messages. 

## Override the localizable strings for the generic validators 

```swift
"field_empty_error" = "This field should not be empty";
"email_format_invalid_error" = "Invalid email format";
"mobile_number_invalid" = "Invalid phone number";
"specials_characters" = "Use at least one special character and no spaces";
"password_has_wrong_length" = "Password must be 8–20 characters";
"password_number_letter_suggestion" = "Use at least one number and one letter";
```
