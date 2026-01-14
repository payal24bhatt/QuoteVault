//
//  RegisterVC.swift
//  
//
//  Created by Payal Bhatt on 10/11/25.
//

import UIKit

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
    lazy var viewModel: SignupViewModel = {
        viewModel = SignupViewModel()
        viewModel.delegate = self
        return viewModel
    }()
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        prepareViewModel()
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
    
    func prepareViewModel() {
        // Prepare ViewModel Here
    }
}

//MARK:- Action
extension RegisterVC {
    
    @IBAction func onClickSignup(_ sender: UIButton) {
        self.view.endEditing(true)
        viewModel.callSignupAPI(
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

// MARK: - SignupViewModelDelegate Method
extension RegisterVC : SignupViewModelDelegate {
    
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
    
    func errorOccurred(_ message: String, errorType: ErrorType, fieldType: ErrorFieldType) {
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




