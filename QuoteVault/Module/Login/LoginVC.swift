//
//  LoginVC.swift
//  
//
//  Created by Payal Bhatt on 10/11/25.
//

import UIKit
import Supabase

class LoginVC: UIViewController, UITextFieldDelegate {
    
    /// IBOutlet(s)
    @IBOutlet weak var txtEmailId: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var btnSignup: UIButton!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnForgotPassword: UIButton!
    @IBOutlet weak var btnPasswordShow: UIButton!
    
    /// Variable(s)
    private var isPasswordVisible = false
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
    }
}

// MARK: - UI & Utility Method(s)
extension LoginVC {
    
    func prepareUI() {
        
//        #if DEBUG
//        txtEmailId.text = "abc@gmail.com"
//        txtPassword.text = "12345678"
//        #endif
        
        txtPassword.isSecureTextEntry = true
        
        txtEmailId.keyboardType = .emailAddress
        
        txtEmailId.maxLength = 50
        txtPassword.maxLength = Constants.passwordLimit.maxLength
        txtEmailId.autocapitalizationType = .none
        txtPassword.autocapitalizationType = .none
        
        txtEmailId.delegate = self
        txtPassword.delegate = self
        txtPassword.textContentType = .password
        txtEmailId.textContentType = .username
        btnPasswordShow.setImage(UIImage(named: AppImages.showPassword.rawValue), for: .normal)
    }
    
    @objc func passwordToggle() {
        txtPassword.isSecureTextEntry.toggle()
        /// Change the image based on the current state of isSecureTextEntry
        let imageName = txtPassword.isSecureTextEntry ? AppImages.showPassword.rawValue : AppImages.hidePassword.rawValue
    }
    
}

//MARK:- Action
extension LoginVC {
    
    @IBAction func onClickLogin(_ sender: UIButton) {
        self.view.endEditing(true)
        callLoginAPI(email: txtEmailId.text ?? "", password: txtPassword.text ?? "")
    }
    
    @IBAction func onClickSignup(_ sender: UIButton) {
        self.view.endEditing(true)
        Constants.appDelegate.redirectToSignup()
    }
    
    @IBAction func onClickForgotPassword(_ sender: UIButton) {
        self.view.endEditing(true)
        guard let email = txtEmailId.text, !email.isEmpty else {
            showAlert("Please enter email first")
            return
        }

        Task {
            do {
                try await SupabaseService.shared.client.auth.resetPasswordForEmail(email, redirectTo: URL(string: "quotevault://reset-password")!)
                showAlert("Password reset email sent")
            } catch {
                showAlert(error.localizedDescription)
            }
        }
    }
    
    @IBAction func onClickPassword(_ sender: UIButton) {
        self.view.endEditing(true)
        isPasswordVisible.toggle()
        txtPassword.isSecureTextEntry = !isPasswordVisible
        
        let imageName = isPasswordVisible ? AppImages.hidePassword.rawValue : AppImages.showPassword.rawValue
        btnPasswordShow.setImage(UIImage(named: imageName), for: .normal)
    }
    
    func showAlert(_ message: String) {
        let alert = UIAlertController(title: "QuoteVault", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Login Methods
extension LoginVC {
    
    func callLoginAPI(email: String, password: String) {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

        // MARK: - Validations
        guard !trimmedEmail.isEmpty else {
            showError("Email is required", fieldType: .email)
            return
        }

        guard trimmedEmail.isValidEmail else {
            showError("Please enter a valid email", fieldType: .email)
            return
        }

        guard !trimmedPassword.isEmpty else {
            showError("Password is required", fieldType: .password)
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
                    Constants.appDelegate.redirectToHome()
                }

            } catch {
                DispatchQueue.main.async {
                    self.showError(error.localizedDescription, fieldType: .none)
                }
            }
        }
    }
    
    func showError(_ message: String, fieldType: ErrorFieldType) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
        
        // Optionally: highlight the invalid text field
        switch fieldType {
        case .email:
            txtEmailId.becomeFirstResponder()
        case .password:
            txtPassword.becomeFirstResponder()
        default:
            break
        }
    }
}


