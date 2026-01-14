//
//  SplashVC.swift
//  QuoteVault
//
//  Created by Payal Bhatt on 13/01/26.
//

import UIKit

class SplashVC: UIViewController {
    
    /// Variable(s)
    lazy var viewModel: SplashViewModel = {
        let vm = SplashViewModel()
        vm.delegate = self
        return vm
    }()
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Load and apply theme on app launch
        ThemeManager.shared.loadAndApplyTheme()
        checkSession()
    }
    
    func checkSession() {
        // Check if user is logged in via Supabase
        if SupabaseService.shared.isLoggedIn {
            // User has active session, redirect to home
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                Constants.appDelegate.redirectToHome()
            }
        } else {
            // No session, redirect to login
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                Constants.appDelegate.redirectToLogin()
            }
        }
    }
}

// MARK: - SplashViewModelDelegate Method
extension SplashVC : SplashViewModelDelegate {
    func errorOccurred(_ message: String, errorType: ErrorType, fieldType: ErrorFieldType) {
        alertView(message: message)
    }
}
