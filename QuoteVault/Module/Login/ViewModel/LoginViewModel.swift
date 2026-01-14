//
//  LoginViewModel.swift


import Foundation
import UIKit
import Supabase

/// for manage validation field type
enum ErrorFieldType {
    case fname
    case lname
    case email
    case password
    case confirmPassword
    case none
    case dob
}

/// manage error type
enum ErrorType {
    case api
    case system
}

protocol LoginViewModelDelegate: AnyObject {
    
    func loginSuccess()
    func errorOccurred(_ message: String, errorType: ErrorType, fieldType: ErrorFieldType)
}

class LoginViewModel {
    
    /// Variable(s)
    weak var delegate: LoginViewModelDelegate?

    func callLoginAPI(email: String, password: String) {

        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

        // MARK: - Validations (UNCHANGED)
        guard !trimmedEmail.isEmpty else {
            delegate?.errorOccurred("Email is required", errorType: .system, fieldType: .email)
            return
        }

        guard trimmedEmail.isValidEmail else {
            delegate?.errorOccurred("Please enter a valid email", errorType: .system, fieldType: .email)
            return
        }

        guard !trimmedPassword.isEmpty else {
            delegate?.errorOccurred("Password is required", errorType: .system, fieldType: .password)
            return
        }

        // MARK: - SUPABASE LOGIN
        Task {
            do {
                try await SupabaseService.shared.client.auth.signIn(
                    email: trimmedEmail,
                    password: trimmedPassword
                )

                // Success
                DispatchQueue.main.async {
                    self.delegate?.loginSuccess()
                }

            } catch {
                DispatchQueue.main.async {
                    self.delegate?.errorOccurred(
                        error.localizedDescription,
                        errorType: .api,
                        fieldType: .none
                    )
                }
            }
        }
    }
}
