//
//  SignupViewModel.swift
//  QuoteVault
//
//  Created by Payal Bhatt on 13/01/26.
//

import Foundation
import UIKit
import Supabase

protocol SignupViewModelDelegate: AnyObject {
    func signupSuccess()
    func errorOccurred(_ message: String, errorType: ErrorType, fieldType: ErrorFieldType)
}

class SignupViewModel {
    
    /// Variable(s)
    weak var delegate: SignupViewModelDelegate?

    func callSignupAPI(firstName: String, lastName: String, email: String, password: String, confirmPassword: String) {
        let trimmedFirstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedLastName = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedConfirmPassword = confirmPassword.trimmingCharacters(in: .whitespacesAndNewlines)

        // Validate first name
        guard !trimmedFirstName.isEmpty else {
            delegate?.errorOccurred("First name is required", errorType: .system, fieldType: .fname)
            return
        }
        
        // Validate last name
        guard !trimmedLastName.isEmpty else {
            delegate?.errorOccurred("Last name is required", errorType: .system, fieldType: .lname)
            return
        }
        
        // Validate email
        guard !trimmedEmail.isEmpty else {
            delegate?.errorOccurred("Email is required", errorType: .system, fieldType: .email)
            return
        }
        
        guard trimmedEmail.isValidEmail else {
            delegate?.errorOccurred("Please enter a valid email", errorType: .system, fieldType: .email)
            return
        }
        
        // Validate password
        guard !trimmedPassword.isEmpty else {
            delegate?.errorOccurred("Password is required", errorType: .system, fieldType: .password)
            return
        }
        
        guard trimmedPassword.count >= Constants.passwordLimit.minLength && trimmedPassword.count <= Constants.passwordLimit.maxLength else {
            delegate?.errorOccurred("Password must be between \(Constants.passwordLimit.minLength) and \(Constants.passwordLimit.maxLength) characters", errorType: .system, fieldType: .password)
            return
        }
        
        // Validate confirm password
        guard !trimmedConfirmPassword.isEmpty else {
            delegate?.errorOccurred("Please confirm your password", errorType: .system, fieldType: .confirmPassword)
            return
        }
        
        guard trimmedPassword == trimmedConfirmPassword else {
            delegate?.errorOccurred("Passwords do not match", errorType: .system, fieldType: .confirmPassword)
            return
        }
        
        // Perform signup using Supabase Auth
        Task {
            do {
                let fullName = "\(trimmedFirstName) \(trimmedLastName)".trimmingCharacters(in: .whitespaces)
                
                // Sign up with Supabase Auth
                let response = try await SupabaseService.shared.client.auth.signUp(
                    email: trimmedEmail,
                    password: trimmedPassword,
                    data: ["full_name": .string(fullName)]
                )
                
                let user = response.user
                
                // Create profile in database
                struct ProfileInsert: Encodable {
                    let id: UUID
                    let email: String
                    let full_name: String
                    let created_at: String
                }
                
                let profile = ProfileInsert(
                    id: user.id,
                    email: trimmedEmail,
                    full_name: fullName,
                    created_at: ISO8601DateFormatter().string(from: Date())
                )
                
                _ = try await SupabaseService.shared.client.database.from("profiles").insert(profile).execute()
                
                // Create default settings
                struct SettingsInsert: Encodable {
                    let user_id: UUID
                    let theme: String
                    let font_size: Int
                    let accent_color: String
                    let created_at: String
                }
                
                let settings = SettingsInsert(
                    user_id: user.id,
                    theme: "system",
                    font_size: 16,
                    accent_color: "blue",
                    created_at: ISO8601DateFormatter().string(from: Date())
                )
                
                _ = try await SupabaseService.shared.client.database.from("user_settings").insert(settings).execute()
                
                DispatchQueue.main.async {
                    self.delegate?.signupSuccess()
                }
            } catch {
                DispatchQueue.main.async {
                    let errorMessage = error.localizedDescription
                    // Check if it's an email already exists error
                    if errorMessage.contains("already registered") || errorMessage.contains("already exists") {
                        self.delegate?.errorOccurred("Email already exists. Please use a different email.", errorType: .api, fieldType: .email)
                    } else {
                        self.delegate?.errorOccurred("Signup failed: \(errorMessage)", errorType: .api, fieldType: .none)
                    }
                }
            }
        }
    }
}
