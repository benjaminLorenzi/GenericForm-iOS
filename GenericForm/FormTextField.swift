//
//  FormTextField.swift
//  GenericForm
//
//  Created by Benjamin LORENZI on 07/08/2020.
//  Copyright © 2020 Benjamin LORENZI. All rights reserved.
//

import Foundation
import UIKit

@objc protocol FormTextFieldProtocol: class {
    @objc func formTextFieldDidEndTyping(_ formTextField: FormTextField)
    @objc optional func formTextWillBlur(_ textField: UITextField)
    @objc optional func formTextWillFocus(_ textField: UITextField)
    @objc optional func formTextViewDidChange(_ formTextField: FormTextField)
}


extension FormTextField: TextFieldValidatorAdaptble {
    var text: String? {
        get { return textField.text }
        set (text) { textField.text = text }
    }
    
    var _text: String? {
        get { return text }
        set (text) { self.text = text }
    }
    
    var isEmpty: Bool {
        return textField.text == nil || textField.text!.count == 0 || textField.text == ""
    }
    
    func performValidation() {
        if !textField.isFirstResponder {
            let (isValid, messages) = validators.applyAll(self)
            displayValidationMessages(isValid ? [] : messages)
            hasError = !validatorView.isHidden
        } else {
            displayValidationMessages( [] )
            hasError = !validatorView.isHidden
        }
    }
}


class FormTextField: UIView {
    var validators: [Validators] = []
    fileprivate let baseHeight: Int = 35
    var stateFullMode: Bool = false
    
    weak var formDelegate: FormTextFieldProtocol?
    fileprivate var didEndTypingTimer: Timer?
    
    var nextField: FormTextField?
    var textField: UITextField = FormFocusBlurTextField()
    fileprivate let validatorView: FormFieldValidationView = FormFieldValidationView()
    var validatorAccessibility: String? {
        get {
            return validatorView.accessibilityIdentifier
        }
        set(newValue) {
            validatorView.accessibilityIdentifier = newValue
        }
    }
    fileprivate let border: UIView = UIView()
    
    override var accessibilityIdentifier: String? {
        get { return textField.accessibilityIdentifier }
        set(value) {
            textField.accessibilityIdentifier = value
        }
    }
    
    override var isUserInteractionEnabled: Bool {
        get { return textField.isUserInteractionEnabled }
        set(value) {
            textField.isUserInteractionEnabled = value
        }
    }
    
    var placeholder: String? {
        get { return textField.placeholder }
        set (placeholder) { textField.placeholder = placeholder }
    }
    
    var keyboardType: UIKeyboardType {
        get { return textField.keyboardType }
        set (keyboardType) { textField.keyboardType = keyboardType }
    }
    
    var hasError: Bool = false {
        didSet { colorBorderAndMessages() }
    }
    
    override public var intrinsicContentSize: CGSize {
        let validatorMargin: CGFloat = validatorView.isHidden ? 0 : validatorView.layoutMargins.top
        let validatorSpacing: CGFloat = validatorView.isHidden ? 0 : CGFloat(validatorView.arrangedSubviews.count) * validatorView.spacing
        let validatorSize = validatorView.isHidden ? 0 : validatorView.getHeigt()
        return CGSize(width: 100, height: CGFloat(baseHeight) + validatorSize + validatorSpacing + validatorMargin)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        buildUI()
    }
    
}


// MARK: NeoFocusBlurDelegate
extension FormTextField: FormFocusBlurDelegate {
    
    func formTextFieldWillBlur(_ textField: UITextField) {
        colorBorderAndMessages()
        formDelegate?.formTextWillBlur?(textField)
    }
    
    func formTextFieldWillFocus(_ textField: UITextField) {
        colorBorderAndMessages()
        formDelegate?.formTextWillFocus?(textField)
    }
}

// MARK: textfield changing
extension FormTextField {
    @objc func didEndTyping() {
        if let delegate = formDelegate, self.window != nil {
            delegate.formTextFieldDidEndTyping(self)
        }
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        didEndTypingTimer?.invalidate()
        didEndTypingTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(didEndTyping), userInfo: nil, repeats: false)
        if stateFullMode {
            self.performValidation()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
            if let delegate = self.formDelegate, self.window != nil {
                delegate.formTextViewDidChange?(self)
            }
        }
    }
    
    @objc func formTextFieldDidEndEditing(_ textField: UITextField) {
        self.textField.resignFirstResponder()
        if stateFullMode {
            self.performValidation()
        }
        if let delegate = formDelegate, self.window != nil {
            delegate.formTextFieldDidEndTyping(self)
        }
    }
    
    @objc func formTextFieldDidBeginEditing(_ textField: UITextField) {
        if stateFullMode {
            self.performValidation()
        }
    }
}

// MARK: Validation messages
extension FormTextField {
    
    func displayValidationMessages(_ messages: [String]) {
        
        validatorView.displayMessages((messages.count > 0 ) ? [messages.first!] : [])
        validatorView.isHidden = (messages.count == 0)
        invalidateIntrinsicContentSize()
        
    }
}

// MARK: Building UI
private extension FormTextField {
    
    func buildUI() {
        self.textField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        self.textField.addTarget(self, action: #selector(formTextFieldDidEndEditing(_:)), for: .editingDidEnd)
        self.textField.addTarget(self, action: #selector(formTextFieldDidBeginEditing(_:)), for: .editingDidBegin)
        
        textField.borderStyle = .none
        textField.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        textField.textColor = UIColor.TextColor()
        translatesAutoresizingMaskIntoConstraints = false
        
        (textField as? FormFocusBlurTextField)?.focusBlurDelegate = self
        
        positionTextField()
        positionValidator()
        positionBottomBorder()
    }
    
    func positionTextField() {
        addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[tf]-0-|", options: .init(rawValue: 0), metrics: nil, views: ["tf": textField]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[tf(==\(baseHeight - 1))]", options: .init(rawValue: 0), metrics: nil, views: ["tf": textField]))
    }
    
    func positionBottomBorder() {
        border.translatesAutoresizingMaskIntoConstraints = false
        colorBorderAndMessages()
        addSubview(border)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|", options: .init(rawValue: 0), metrics: nil, views: ["view": border]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[tf]-0-[view(==1)]-0-[validator]|", options: .init(rawValue: 0), metrics: nil, views: ["tf": textField, "view": border, "validator": validatorView]))
    }
    
    func positionValidator() {
        validatorView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(validatorView)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|", options: .init(rawValue: 0), metrics: nil, views: ["view": validatorView]))
        validatorView.isHidden = true
    }
    
    func colorBorderAndMessages() {
        var color: UIColor = UIColor(red: 175, green: 175, blue: 175, alpha: 1.0)
        
        if hasError {
            color = UIColor.ErrorColor()
        }
        if textField.isFirstResponder {
            color = UIColor.HighlightColor()
            
        }
        
        border.backgroundColor = color
        validatorView.color = color
    }
}


// MARK: Stack view used for messages
public class FormFieldValidationView: UIStackView {

    var font: UIFont = UIFont.systemFont(ofSize: 12, weight: .medium)
    var color: UIColor = UIColor.TextFieldDefaultColor() {
        didSet {
            self.arrangedSubviews.forEach { ($0 as! UILabel).textColor = color }
        }
    }
    
    public override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        axis = .vertical
        distribution = .fill
        alignment = .fill
        spacing = 2.0
        isLayoutMarginsRelativeArrangement = true
    }
    
    func displayMessages(_ messages: [String]) {
        let topMargin: CGFloat = messages.count == 0 ? 0 : 4
        layoutMargins = UIEdgeInsets(top: topMargin, left: 0, bottom: -3, right: 20)
        arrangedSubviews.forEach { (view: UIView) in
            removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        messages.forEach { addArrangedSubview(createLabel(text: $0)) }
    }
    
    func getHeigt() -> CGFloat {
        
        let size = self.arrangedSubviews.reduce(0) {
            $0 + ($1 as! UILabel).formGetHeight(width: self.bounds.width - 20)
        }
        return size
    }
    
    func createLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = "\(text)"
        label.numberOfLines = 0
        label.setLineHeight(6, textAlignment: .left)
        label.font = font
        label.textColor = color
        return label
    }
}

// MARK: Textfield for which we can detect blur and focus without overriding the delegate

protocol FormFocusBlurDelegate: class {
    
    func formTextFieldWillFocus(_ textField: UITextField)
    func formTextFieldWillBlur(_ textField: UITextField)
    
}

private class FormFocusBlurTextField: UITextField {
    
    weak var focusBlurDelegate: FormFocusBlurDelegate?
    
    override func becomeFirstResponder() -> Bool {
        let returnValue = super.becomeFirstResponder()
        if returnValue, let delegate = focusBlurDelegate {
            delegate.formTextFieldWillFocus(self)
        }
        return returnValue
    }
    
    override func resignFirstResponder() -> Bool {
        let returnValue = super.resignFirstResponder()
        
        if returnValue, let delegate = focusBlurDelegate {
            delegate.formTextFieldWillBlur(self)
        }
        return returnValue
    }
}

extension FormTextField {
    static func focusNextNeoTextField(fields: [FormTextField], textField: UITextField) {
        // find the NeoTextField object
        let formTextFields = fields.filter { $0.textField == textField }
        if formTextFields.count > 0 {
            let formTextField = formTextFields.first!
            var index = fields.firstIndex(of: formTextField)
            
            repeat {
                index! += 1
                index = index! % fields.count
                // skip the hidden fields; we have at least one unhidden (the field where we pressed "return", part of the fields array)
                if !fields[index!].isHidden {
                    fields[index!].textField.becomeFirstResponder()
                    break
                }
            } while true
        }
    }
}



private extension UILabel {
    
    func formGetHeight(width: CGFloat) -> CGFloat {
        let sizeToFit = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        return self.sizeThatFits(sizeToFit).height
    }
    
    func getOrCreateAttributeString() -> NSMutableAttributedString {
        if let currentAttrString = attributedText {
            return NSMutableAttributedString(attributedString: currentAttrString)
        } else {
            return NSMutableAttributedString(string: text ?? "")
        }
    }
    
    func setLineHeight(_ lineHeight: CGFloat, textAlignment: NSTextAlignment = .center) {
           guard let text = self.text else {
               return
           }
           
           let attributedText = getOrCreateAttributeString()
           
           let style = NSMutableParagraphStyle()
           
           style.lineSpacing = lineHeight
           style.lineBreakMode = self.lineBreakMode
            attributedText.addAttributes([NSAttributedString.Key.paragraphStyle: style, NSAttributedString.Key.font: self.font as Any], range: NSRange(location: 0, length: text.count))
           
           self.attributedText = attributedText
           self.textAlignment = textAlignment
           self.numberOfLines = 0
       }
}
