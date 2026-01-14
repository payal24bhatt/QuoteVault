//
//  RegisterVC.swift
//  
//
//  Created by Payal Bhatt on 10/11/25.
//

import UIKit
import Supabase

class RegisterVC: UIViewController, UITextFieldDelegate {
    
    /// IBOutlet(s)
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var txtEmailId: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var btnPasswordShow: UIButton!
    @IBOutlet weak var txtConfirmPassword: UITextField!
    @IBOutlet weak var btnConfirmPasswordShow: UIButton!
    @IBOutlet weak var btnBackToLogin: UIButton!
    
    /// Variable(s)
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
    }
}

// MARK: - UI & Utility Method(s)
extension RegisterVC {
    
    func prepareUI() {
        txtPassword.isSecureTextEntry = true
        txtConfirmPassword.isSecureTextEntry = true
        
        txtEmailId.keyboardType = .emailAddress
        
        txtFirstName.maxLength = 50
        txtLastName.maxLength = 50
        txtEmailId.maxLength = 50
        txtPassword.maxLength = 20
        txtConfirmPassword.maxLength = 20
        
        txtFirstName.autocapitalizationType = .words
        txtLastName.autocapitalizationType = .words
        txtEmailId.autocapitalizationType = .none
        txtPassword.autocapitalizationType = .none
        txtConfirmPassword.autocapitalizationType = .none
        
        txtFirstName.delegate = self
        txtLastName.delegate = self
        txtEmailId.delegate = self
        txtPassword.delegate = self
        txtConfirmPassword.delegate = self
        
        txtPassword.textContentType = .newPassword
        txtConfirmPassword.textContentType = .newPassword
        txtEmailId.textContentType = .emailAddress
        
        btnPasswordShow.setImage(UIImage(named: AppImages.showPassword.rawValue), for: .normal)
        btnConfirmPasswordShow.setImage(UIImage(named: AppImages.showPassword.rawValue), for: .normal)
    }
    
}

//MARK:- Action
extension RegisterVC {
    
    @IBAction func onClickSignup(_ sender: UIButton) {
        self.view.endEditing(true)
        callSignupAPI(
            firstName: txtFirstName.text ?? "",
            lastName: txtLastName.text ?? "",
            email: txtEmailId.text ?? "",
            password: txtPassword.text ?? "",
            confirmPassword: txtConfirmPassword.text ?? ""
        )
    }
    
    @IBAction func onClickBackToLogin(_ sender: UIButton) {
        self.view.endEditing(true)
        Constants.appDelegate.redirectToLogin()
    }
    
    @IBAction func onClickPassword(_ sender: UIButton) {
        txtPassword.isSecureTextEntry.toggle()
        
        let imageName = txtPassword.isSecureTextEntry ? AppImages.showPassword.rawValue : AppImages.hidePassword.rawValue
        btnPasswordShow.setImage(UIImage(named: imageName), for: .normal)
    }
    
    @IBAction func onClickConfirmPassword(_ sender: UIButton) {
        txtConfirmPassword.isSecureTextEntry.toggle()
        
        let imageName = txtConfirmPassword.isSecureTextEntry ? AppImages.showPassword.rawValue : AppImages.hidePassword.rawValue
        btnConfirmPasswordShow.setImage(UIImage(named: imageName), for: .normal)
    }
}

// MARK: - Signup Methods
extension RegisterVC {
    
    func callSignupAPI(firstName: String, lastName: String, email: String, password: String, confirmPassword: String) {
        let trimmedFirstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedLastName = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedConfirmPassword = confirmPassword.trimmingCharacters(in: .whitespacesAndNewlines)

        // Validate first name
        guard !trimmedFirstName.isEmpty else {
            showError("First name is required", fieldType: .fname)
            return
        }
        
        // Validate last name
        guard !trimmedLastName.isEmpty else {
            showError("Last name is required", fieldType: .lname)
            return
        }
        
        // Validate email
        guard !trimmedEmail.isEmpty else {
            showError("Email is required", fieldType: .email)
            return
        }
        
        guard trimmedEmail.isValidEmail else {
            showError("Please enter a valid email", fieldType: .email)
            return
        }
        
        // Validate password
        guard !trimmedPassword.isEmpty else {
            showError("Password is required", fieldType: .password)
            return
        }
        
        guard trimmedPassword.count >= Constants.passwordLimit.minLength && trimmedPassword.count <= Constants.passwordLimit.maxLength else {
            showError("Password must be between \(Constants.passwordLimit.minLength) and \(Constants.passwordLimit.maxLength) characters", fieldType: .password)
            return
        }
        
        // Validate confirm password
        guard !trimmedConfirmPassword.isEmpty else {
            showError("Please confirm your password", fieldType: .confirmPassword)
            return
        }
        
        guard trimmedPassword == trimmedConfirmPassword else {
            showError("Passwords do not match", fieldType: .confirmPassword)
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
                    self.signupSuccess()
                }
            } catch {
                DispatchQueue.main.async {
                    let errorMessage = error.localizedDescription
                    // Check if it's an email already exists error
                    if errorMessage.contains("already registered") || errorMessage.contains("already exists") {
                        self.showError("Email already exists. Please use a different email.", fieldType: .email)
                    } else {
                        self.showError("Signup failed: \(errorMessage)", fieldType: .none)
                    }
                }
            }
        }
    }
    
    func signupSuccess() {
        let alert = UIAlertController(
            title: "Success",
            message: "Your account has been created. Please log in to continue.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            Constants.appDelegate.redirectToLogin()
        })
        present(alert, animated: true)
    }
    
    func showError(_ message: String, fieldType: ErrorFieldType) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
        
        // Optionally: highlight the invalid text field
        switch fieldType {
        case .fname:
            txtFirstName.becomeFirstResponder()
        case .lname:
            txtLastName.becomeFirstResponder()
        case .email:
            txtEmailId.becomeFirstResponder()
        case .password:
            txtPassword.becomeFirstResponder()
        case .confirmPassword:
            txtConfirmPassword.becomeFirstResponder()
        default:
            break
        }
    }
}




