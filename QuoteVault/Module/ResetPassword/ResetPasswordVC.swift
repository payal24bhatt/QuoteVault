//
//  ResetPasswordVC.swift
//  QuoteVault
//
//  Created by Payal Bhatt on 14/01/26.
//

import UIKit
import Supabase

class ResetPasswordVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtConfirmPassword: UITextField!
    @IBOutlet weak var btnPasswordShow: UIButton!
    @IBOutlet weak var btnConfirmPasswordShow: UIButton!
    @IBOutlet weak var btnReset: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var isPasswordVisible = false
    private var isConfirmPasswordVisible = false
    var resetURL: URL?
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        if let url = resetURL {
            print("🔗 ResetPasswordVC received URL: \(url.absoluteString)")
            extractTokenFromURL(url)
            // Let Supabase handle the URL to set up the session
            handleSupabaseURL(url)
        } else {
            print("⚠️ ResetPasswordVC: No URL provided")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Check if we have a session (Supabase should have set it from the URL)
        if let session = SupabaseService.shared.client.auth.currentSession {
            print("✅ ResetPasswordVC: Session found, ready to reset password")
            print("✅ Session user ID: \(session.user.id)")
        } else {
            print("⚠️ ResetPasswordVC: No session found - URL may not have been processed")
            print("💡 Important: Make sure the redirect URL in Supabase dashboard is set to: quotevault://reset-password")
            if let url = resetURL {
                print("🔗 Received URL: \(url.absoluteString)")
            }
        }
    }
    
    func handleSupabaseURL(_ url: URL) {
        // Supabase sends a code in the URL that needs to be exchanged for a session
        // The URL format from Supabase: quotevault://reset-password?code=xxx
        Task {
            do {
                // Extract code from URL query parameter
                var code: String?
                
                if let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems {
                    for item in queryItems {
                        if item.name == "code" {
                            code = item.value
                            break
                        }
                    }
                }
                
                if let code = code {
                    print("🔑 Found code in URL, exchanging for session in handleSupabaseURL...")
                    
                    // Exchange the code for a session
                    // For password reset, Supabase sends a code that needs to be verified
                    // The verifyOTP method might require email, so let's try a different approach
                    // We can use exchangeCodeForSession if available, or verifyOTP with email
                    do {
                        // Try using exchangeCodeForSession which is specifically for password reset
                        // If that doesn't exist, we'll need to get the email somehow
                        // For now, let's try verifyOTP - it might work without email for recovery type
                        // But if it requires email, we'll need to extract it from the URL or user input
                        
                        // Check if URL has email parameter
                        var email: String? = nil
                        if let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems {
                            for item in queryItems {
                                if item.name == "email" {
                                    email = item.value
                                    break
                                }
                            }
                        }
                        
                        // For password reset recovery, verifyOTP requires email
                        // But we might not have it in the URL
                        // Let's try using exchangeCodeForSession which is designed for this
                        // If that doesn't work, we'll need to prompt for email or get it another way
                        
                        // Try exchangeCodeForSession first (if available)
                        // This is the recommended way for password reset codes
                        let response = try await SupabaseService.shared.client.auth.exchangeCodeForSession(authCode: code)
                        
                        print("✅ Code verified in handleSupabaseURL")
                        
                        // Check if session was created
                        let session = SupabaseService.shared.client.auth.currentSession
                        if session != nil {
                            print("✅ Session created in handleSupabaseURL")
                        } else {
                            print("⚠️ Code verified but no session found yet")
                            // Wait a bit for session to be established
                            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                            let newSession = SupabaseService.shared.client.auth.currentSession
                            if newSession != nil {
                                print("✅ Session found after delay")
                            }
                        }
                    } catch {
                        print("❌ Failed to verify code in handleSupabaseURL: \(error.localizedDescription)")
                    }
                } else {
                    print("❌ No code found in URL")
                    print("🔗 Full URL: \(url.absoluteString)")
                }
            } catch {
                print("❌ Error processing URL: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - UI Setup
    func prepareUI() {
        title = "Reset Password"
        
        // Setup password fields
        txtPassword.isSecureTextEntry = true
        txtConfirmPassword.isSecureTextEntry = true
        txtPassword.delegate = self
        txtConfirmPassword.delegate = self
        txtPassword.textContentType = .newPassword
        txtConfirmPassword.textContentType = .newPassword
        txtPassword.maxLength = Constants.passwordLimit.maxLength
        txtConfirmPassword.maxLength = Constants.passwordLimit.maxLength
        txtPassword.autocapitalizationType = .none
        txtConfirmPassword.autocapitalizationType = .none
        
        // Setup buttons
        btnPasswordShow.setImage(UIImage(named: AppImages.showPassword.rawValue), for: .normal)
        btnConfirmPasswordShow.setImage(UIImage(named: AppImages.showPassword.rawValue), for: .normal)
        
        if let activityIndicator = activityIndicator {
            activityIndicator.hidesWhenStopped = true
        }
        
        // Add back button
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
    }
    
    // MARK: - Extract Token from URL
    func extractTokenFromURL(_ url: URL) {
        // Supabase sends the token in the hash fragment
        // Format: quotevault://reset-password#access_token=TOKEN&type=recovery&expires_in=3600
        // Or: quotevault://reset-password?access_token=TOKEN&type=recovery
        
        // Check hash fragment first (most common)
        if let fragment = url.fragment {
            let components = fragment.components(separatedBy: "&")
            for component in components {
                if component.hasPrefix("access_token=") {
                    let token = String(component.dropFirst("access_token=".count))
                    print("✅ Reset token extracted from fragment")
                    // The token is automatically handled by Supabase when the URL is opened
                    // We just need to verify the session exists
                    return
                }
            }
        }
        
        // Check query parameters
        if let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems {
            for item in queryItems {
                if item.name == "access_token" {
                    print("✅ Reset token found in query parameters")
                    // The token is automatically handled by Supabase when the URL is opened
                    return
                }
            }
        }
        
        print("⚠️ No reset token found in URL, but Supabase may have already processed it")
    }
    
    // MARK: - Actions
    @IBAction func onClickReset(_ sender: UIButton) {
        view.endEditing(true)
        resetPassword()
    }
    
    @IBAction func onClickPasswordShow(_ sender: UIButton) {
        isPasswordVisible.toggle()
        txtPassword.isSecureTextEntry = !isPasswordVisible
        
        let imageName = isPasswordVisible ? AppImages.hidePassword.rawValue : AppImages.showPassword.rawValue
        btnPasswordShow.setImage(UIImage(named: imageName), for: .normal)
    }
    
    @IBAction func onClickConfirmPasswordShow(_ sender: UIButton) {
        isConfirmPasswordVisible.toggle()
        txtConfirmPassword.isSecureTextEntry = !isConfirmPasswordVisible
        
        let imageName = isConfirmPasswordVisible ? AppImages.hidePassword.rawValue : AppImages.showPassword.rawValue
        btnConfirmPasswordShow.setImage(UIImage(named: imageName), for: .normal)
    }
    
    @objc func cancelTapped() {
        dismiss(animated: true) {
            Constants.appDelegate.redirectToLogin()
        }
    }
    
    // MARK: - Password Reset
    func resetPassword() {
        let password = txtPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let confirmPassword = txtConfirmPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        // Validate password
        guard !password.isEmpty else {
            showError("Password is required", fieldType: .password)
            return
        }
        
        guard password.count >= Constants.passwordLimit.minLength && password.count <= Constants.passwordLimit.maxLength else {
            showError("Password must be between \(Constants.passwordLimit.minLength) and \(Constants.passwordLimit.maxLength) characters", fieldType: .password)
            return
        }
        
        guard !confirmPassword.isEmpty else {
            showError("Please confirm your password", fieldType: .confirmPassword)
            return
        }
        
        guard password == confirmPassword else {
            showError("Passwords do not match", fieldType: .confirmPassword)
            return
        }
        
        activityIndicator?.startAnimating()
        btnReset.isEnabled = false
        
        Task {
            do {
                // Wait a moment to ensure Supabase has processed the URL
                try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                
                // Check if we have a valid session (set by Supabase when clicking reset link)
                var session = SupabaseService.shared.client.auth.currentSession
                
                // If no session, try to exchange the code from URL for a session
                if session == nil, let url = resetURL {
                    print("⚠️ No session found, attempting to exchange code from URL...")
                    
                    // Extract code from URL query parameter
                    // Format: quotevault://reset-password?code=xxx
                    if let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems {
                        for item in queryItems {
                            if item.name == "code", let code = item.value {
                                print("🔑 Found code in URL, exchanging for session...")
                                
                                // Exchange the code for a session using Supabase
                                // For password reset, Supabase sends a code that needs to be verified
                                do {
                                    // For password reset, use exchangeCodeForSession
                                    // This is the correct method for password reset codes
                                    let response = try await SupabaseService.shared.client.auth.exchangeCodeForSession(authCode: code)
                                    
                                    print("✅ Code verified successfully")
                                    print("✅ Response: \(response)")
                                    
                                    // Check for session after verification
                                    session = SupabaseService.shared.client.auth.currentSession
                                    if session != nil {
                                        print("✅ Session created after code verification")
                                    } else {
                                        print("⚠️ Code verified but session not found - might need to wait")
                                        // Wait a bit more for session to be established
                                        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                                        session = SupabaseService.shared.client.auth.currentSession
                                    }
                                } catch {
                                    print("❌ Failed to verify code: \(error.localizedDescription)")
                                    print("❌ Error type: \(type(of: error))")
                                    
                                    // The code might need to be used differently
                                    // Some Supabase setups use the code directly in the session
                                    // Let's try one more time with a slight delay
                                }
                                break
                            }
                        }
                    }
                }
                
                // Check session again
                session = SupabaseService.shared.client.auth.currentSession
                
                guard let validSession = session else {
                    // Provide more helpful error message
                    var errorMessage = "Invalid or expired reset link.\n\n"
                    errorMessage += "Please check:\n"
                    errorMessage += "• Click the link directly from your email (don't copy/paste)\n"
                    errorMessage += "• The link expires after 1 hour\n"
                    errorMessage += "• Make sure redirect URL in Supabase dashboard is set to: quotevault://reset-password"
                    
                    if let url = resetURL {
                        print("🔗 Full URL received: \(url.absoluteString)")
                        print("🔗 URL fragment: \(url.fragment ?? "nil")")
                    }
                    
                    throw NSError(domain: "ResetPasswordVC", code: 401, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                }
                
                print("✅ Using session for user: \(validSession.user.id)")
                
                print("✅ Session found, proceeding with password reset")
                
                // Supabase password reset using updateUser
                // The session is automatically set when the user clicks the reset link
                try await SupabaseService.shared.client.auth.update(user: UserAttributes(password: password))
                
                print("✅ Password updated successfully")
                
                // Sign out after password reset (user needs to login with new password)
                try? await SupabaseService.shared.client.auth.signOut()
                
                DispatchQueue.main.async {
                    self.activityIndicator?.stopAnimating()
                    self.btnReset.isEnabled = true
                    self.showSuccess()
                }
            } catch {
                print("❌ Password reset error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.activityIndicator?.stopAnimating()
                    self.btnReset.isEnabled = true
                    
                    let errorMessage: String
                    if let nsError = error as NSError?, nsError.code == 401 {
                        errorMessage = "Invalid or expired reset link. Please request a new password reset email."
                    } else {
                        errorMessage = "Failed to reset password: \(error.localizedDescription)"
                    }
                    
                    self.showError(errorMessage, fieldType: .none)
                }
            }
        }
    }
    
    func showSuccess() {
        let alert = UIAlertController(
            title: "Success",
            message: "Your password has been reset successfully. Please log in with your new password.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.dismiss(animated: true) {
                Constants.appDelegate.redirectToLogin()
            }
        })
        present(alert, animated: true)
    }
    
    func showError(_ message: String, fieldType: ErrorFieldType) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
        
        // Highlight the invalid text field
        switch fieldType {
        case .password:
            txtPassword.becomeFirstResponder()
        case .confirmPassword:
            txtConfirmPassword.becomeFirstResponder()
        default:
            break
        }
    }
}
