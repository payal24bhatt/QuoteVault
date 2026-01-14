//
//  ValidationFactory.swift
//

import Foundation
import UIKit

class ValidationError: Error {
    var status : Bool
    var message: String?
    
    init(status : Bool, message: String? = nil) {
        self.status = status
        self.message = message
    }
}

protocol ValidatorConvertible {
    func validated(_ value: String) -> ValidationError
}

enum ValidatorType {
    case email
    case password
    case mobileNumber
    case firstLastName(field: String)
    case requiredField(field: String)

    var keyboardType:UIKeyboardType {
        switch self {
        case .mobileNumber: if #available(iOS 10.0, *) {
            return .asciiCapableNumberPad
        } else {
            return .numberPad
        }
        case .email: return .emailAddress
        default: return .default
        }
    }
}

enum ValidatorFactory {
    static func validatorFor(type: ValidatorType) -> ValidatorConvertible {
        switch type {
        case .email: return EmailValidator()
        case .password: return PasswordValidator()
        case .requiredField(let fieldName): return RequiredFieldValidator(fieldName)
        case .firstLastName( let fieldName): return FirstNameLastNameValidator(fieldName)
        case .mobileNumber:  return MobileNumberValidator()
        }
    }
}

struct MobileNumberValidator: ValidatorConvertible {
    func validated(_ value: String) -> ValidationError {
        
        guard !value.isEmpty else {
            return ValidationError(
                status: false,
                message: "Enter the valid mobile number")
        }
        if value.count < 9 {
            return ValidationError(
                status: false,
                message: "Enter the valid mobile number")
        }
        if value.allSatisfy({$0 == "0"}) {
            return  ValidationError(
                status: false,
                message: "Enter the valid mobile number")
        }
        return ValidationError(status: true)
    }
}

struct RequiredFieldValidator: ValidatorConvertible {
    private let fieldName: String

    init(_ field: String) {
        fieldName = field
    }

    func validated(_ value: String) -> ValidationError {
        guard !value.isEmpty else {
            return ValidationError(
                status: false,
                message: String(format: "Enter %@.", fieldName.lowercased()))
        }
        return ValidationError(status: true)
    }
}

struct FirstNameLastNameValidator : ValidatorConvertible {

    private let fieldName: String

    init(_ field: String) {
        let msgfieldName = field.trimmingCharacters(in: .whitespacesAndNewlines)
        fieldName = msgfieldName
    }
    func validated(_ value: String) -> ValidationError {
        guard value != "" else {
            return ValidationError(
                status: false,
                message: String(format: "Enter %@.", fieldName.lowercased()))
        }
        
//        guard value.count >= 3 else {
//            return ValidationError(
//                status: false,
//                message: String(format: AppMessages.ValidationString.validationcharcterMinimumLimit, fieldName, "3"))
//        }
        
        guard value.count <= 50 else {
            return ValidationError(
                status: false,
                message: String(format: "%@ should not contain more than %@ characters.", fieldName, "50"))
        }
        
        if !validatePart(value) {
            return ValidationError(
                status: false,
                message: String(format: "Enter %@.", fieldName.lowercased()))
        }
        
        return ValidationError(status: true)
    }
    
    func validatePart(_ part: String) -> Bool {
        let regex = try! NSRegularExpression(pattern: "^[A-Za-z0-9'.’]{1,50}$")
        let range = NSRange(location: 0, length: part.utf16.count)
        print(regex.firstMatch(in: part, options: [], range: range) != nil)
        return regex.firstMatch(in: part, options: [], range: range) != nil
    }


}

struct FullNameValidator: ValidatorConvertible {

    private let fieldName: String

    init(_ field: String) {
        let msgFieldName = field.trimmingCharacters(in: .whitespacesAndNewlines)
        fieldName = msgFieldName
    }

    func validated(_ value: String) -> ValidationError {
        guard !value.isEmpty else {
            return ValidationError(
                status: false,
                message: String(format: "Enter %@.", fieldName.lowercased()))
        }
        
        guard value.count >= 3 else {
            return ValidationError(
                status: false,
                message: String(format: "%@ must contain more than %@ characters.", fieldName, "3"))
        }
        
        guard value.count <= 50 else {
            return ValidationError(
                status: false,
                message: String(format: "%@ should not contain more than %@ characters.", fieldName, "50"))
        }
        
        if !validatePart(value) {
            return ValidationError(
                status: false,
                message: String(format: "Enter a valid %@.", fieldName.lowercased()))
        }
        
        return ValidationError(status: true)
    }
    
    func validatePart(_ part: String) -> Bool {
        // Regex to allow only letters (a-z, A-Z) and a single space between words
        let regex = try! NSRegularExpression(pattern: "^[A-Za-z]+( [A-Za-z]+)?$", options: [])
        let range = NSRange(location: 0, length: part.utf16.count)
        return regex.firstMatch(in: part, options: [], range: range) != nil
    }
}

struct DropdownValidator : ValidatorConvertible {

    private let fieldName: String

    init(_ field: String) {
        let msgfieldName = field.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        fieldName = msgfieldName
    }
    
    func validated(_ value: String) -> ValidationError {
        guard value != "" else {
            return ValidationError(
                status: false,
                message: String(format: "Select %@.", fieldName.lowercased()))
        }
        return ValidationError(status: true)
    }
}

//struct PasswordValidator: ValidatorConvertible {
//    func validated(_ value: String) -> ValidationError {
//        guard value != "" else {
//            return ValidationError(
//                status: false,
//                message: AppMessages.ValidationString.validationPasswordEmpty)
//        }
//
//        // Minimum 6 characters at least 1 Uppercase Alphabet, 1 Lowercase Alphabet and 1 Number And one special char max 15 charcter
//        let passwordRegex = "^.{6,15}$"
//                do {
//                    if try NSRegularExpression(pattern: passwordRegex,  options: .caseInsensitive).firstMatch(in: value, options: [], range: NSRange(location: 0, length: value.count)) == nil {
//                        return ValidationError(
//                            status: false,
//                            message: AppMessages.ValidationString.validationPasswordLength)
//                    }
//                } catch {
//                    return ValidationError(
//                        status: false,
//                        message: AppMessages.ValidationString.validationPasswordLength)
//                }
//        return ValidationError(status: true)
//    }
//}


struct PasswordValidator: ValidatorConvertible {
    func validated(_ value: String) -> ValidationError {
        guard !value.isEmpty else {
            return ValidationError(
                status: false,
                message:  String(format: "Enter %@.", "password"))
        }

        // Regex to check for at least 8 characters, at least one uppercase letter, and at least one number
//        let passwordRegex = "^(?=.*[A-Z])(?=.*\\d).{8,}$"
        let passwordRegex = "^.{8,}$" // At least 8 characters required
        
        do {
            let regex = try NSRegularExpression(pattern: passwordRegex, options: .caseInsensitive)
            let range = NSRange(location: 0, length: value.utf16.count)
            if regex.firstMatch(in: value, options: [], range: range) == nil {
                return ValidationError(
                    status: false,
                    message: "Password must be at least 8 characters long."
                )
            }
        } catch {
            return ValidationError(
                status: false,
                message: "Password length should be min 6 and max 15 character.")
        }
        
        return ValidationError(status: true)
    }
    
    func newValidated(_ value: String) -> ValidationError {
        guard !value.isEmpty else {
            return ValidationError(
                status: false,
                message:  String(format: "Enter %@.", "new password"))
        }

        // Regex to check for at least 8 characters, at least one uppercase letter, and at least one number
//        let passwordRegex = "^(?=.*[A-Z])(?=.*\\d).{8,}$"
        let passwordRegex = "^.{8,}$" // At least 8 characters required
        
        do {
            let regex = try NSRegularExpression(pattern: passwordRegex, options: .caseInsensitive)
            let range = NSRange(location: 0, length: value.utf16.count)
            if regex.firstMatch(in: value, options: [], range: range) == nil {
                return ValidationError(
                    status: false,
                    message: "Password must be at least 8 characters long."
                )
            }
        } catch {
            return ValidationError(
                status: false,
                message: "Password length should be min 6 and max 15 character.")
        }
        
        return ValidationError(status: true)
    }
    
    func oldvalidated(_ value: String) -> ValidationError {
        guard !value.isEmpty else {
            return ValidationError(
                status: false,
                message:  String(format: "Enter %@.", "old password"))
        }
        
        return ValidationError(status: true)
    }
}


struct ConfirmPasswordValidator: ValidatorConvertible {
    private let valueToMatchWith: String

    init(_ toMatchWith: String) {
        valueToMatchWith = toMatchWith
    }

    func validated(_ value: String) -> ValidationError {
        guard value != "" else {
            return ValidationError(
                status: false,
                message: "Enter confirm password.")}

        if valueToMatchWith != value {
            return ValidationError(
                status:false,
                message: "Password does not match")
        }
        return ValidationError(status: true)
    }
}

struct EmailValidator: ValidatorConvertible {
    func validated(_ value: String) -> ValidationError {
        do {
            guard value != "" else {
                return ValidationError(
                    status: false,
                    message: String(format: "Enter %@.", "email address"))
            }
            
            let emailRegex = try NSRegularExpression(
                pattern: "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9-]+(\\.[A-Za-z]{2,4})+$",
                options: .caseInsensitive)
            
            if emailRegex.firstMatch(in: value, options: [], range: NSRange(location: 0, length: value.count)) == nil {
                return ValidationError(
                    status: false,
                    message: "Enter valid email address.")
            }
        } catch {
            return ValidationError(
                status: false,
                message: "Enter valid email address.")
        }
        
        if value.isValidEmail {
            return ValidationError(status: true)
        }
        return ValidationError(
            status: false,
            message: "Enter valid email address.")
    }
}

struct DateValidator: ValidatorConvertible {
    func validated(_ value: String) -> ValidationError {
        validated(value, removeEnter: false)
    }
    
    private let fieldName: String
    private let dateFormat: DateFormates
    private let allowFuture: Bool

    init(_ field: String,
         format: DateFormates = .yyyy_MM_dd,
         allowFuture: Bool = false) {
        self.fieldName = field
        self.dateFormat = format
        self.allowFuture = allowFuture
    }

    func validated(_ value: String, removeEnter: Bool = false) -> ValidationError {
        // Empty check (similar to RequiredFieldValidator)
        guard !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return ValidationError(
                status: false,
                message: removeEnter ? String(format: "%@.", fieldName.lowercased()) : String(
                    format: "Enter %@.",
                    fieldName.lowercased()
                )
            )
        }

        // Parse date
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat.rawValue   // ✅ use enum rawValue
        formatter.locale = Locale(identifier: "en_US_POSIX")

        guard let date = formatter.date(from: value) else {
            return ValidationError(
                status: false,
                message: "\(fieldName) is not a valid date"
            )
        }

        // Future date check
        if !allowFuture && date > Date() {
            return ValidationError(
                status: false,
                message: "\(fieldName) cannot be in the future"
            )
        }

        // ✅ Valid → reset to normal (no error message)
        return ValidationError(status: true, message: nil)
    }
}
