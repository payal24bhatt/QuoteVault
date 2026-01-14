//
//  AppDelegate.swift
//  QuoteVault
//
//  Created by Payal Bhatt on 13/01/26.
//

import UIKit
import CoreData
import IQKeyboardManagerSwift
import IQKeyboardToolbarManager

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var pendingResetURL: URL?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UIViewController.swizzleViewDidAppear
        
        IQKeyboardManager.shared.isEnabled = true
        IQKeyboardManager.shared.resignOnTouchOutside = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        
        // Handle URL if app was launched from a URL
        if let url = launchOptions?[.url] as? URL {
            print("🔗 App launched with URL (AppDelegate): \(url.absoluteString)")
            handleURL(url)
        }
        
        return true
    }
    
    // Handle URL when app is already running (iOS 13+ uses SceneDelegate, but this is a fallback)
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print("🔗 AppDelegate received URL: \(url.absoluteString)")
        handleURL(url)
        return true
    }
    
    func handleURL(_ url: URL) {
        if url.scheme == "quotevault" {
            if url.host == "reset-password" {
                print("✅ Detected reset password URL in AppDelegate")
                // If window exists, navigate immediately
                if let window = window {
                    DispatchQueue.main.async {
                        self.redirectToResetPassword(with: url)
                    }
                } else {
                    // Store URL to use when window is ready
                    pendingResetURL = url
                }
            }
        }
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "QuoteVault")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

/// Helper function didFinishLaunchingWithOptions
extension AppDelegate {
    
    /// iqKeyboard configration setup
    func iqKeyboardSetup(isEnable:Bool) {
        IQKeyboardManager.shared.isEnabled = true
        IQKeyboardToolbarManager.shared.isEnabled = true
        IQKeyboardToolbarManager.shared.toolbarConfiguration.tintColor = UIColor.white
    }
    
    /// Theme setup
    func initialTheameSetup() {
        UITextField.appearance().tintColor = UIColor.white
        UITextView.appearance().tintColor = UIColor.white
    }
    
    /// setNavigationBarAppearance is used to set clear navigation bar appearance
    func setNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.shadowColor = .clear
        appearance.backgroundColor = .systemTeal
        appearance.backgroundImage = nil
        appearance.shadowImage = nil
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }
    
    /// setupNavigationController is used to set root view controller
    /// - Parameter rootController: UIViewController type
    func setupNavigationController(rootController: UIViewController) {
        let navigationController: UINavigationController
        // For TabBarVC, wrap it in navigation controller and show nav bar
        if rootController is TabBarVC {
            navigationController = UINavigationController(rootViewController: rootController)
            navigationController.isNavigationBarHidden = false
        } else {
            navigationController = UINavigationController(rootViewController: rootController)
            navigationController.isNavigationBarHidden = true
        }
        self.setWindowRootViewController(
            rootVC: navigationController,
            animated: false,
            completion: nil)
    }
    
    /// setWindowRootViewController is used to set root view
    /// - Parameters:
    ///   - rootVC: UIViewController optional type
    ///   - animated: Bool type
    ///   - completion: completion block
    func setWindowRootViewController(
        rootVC:UIViewController?,
        animated:Bool,
        completion: ((Bool) -> Void)?) {
            guard rootVC != nil else {
                return
            }
            self.window?.rootViewController = rootVC
            completion?(true)
        }
    
}

/// Appdelegate Common Redirectionscreen for app
extension AppDelegate {
    
    /// redirectToSplash is used to redirect to splash screen
    func redirectToSplash() {
        self.setupNavigationController(rootController: SplashVC.loadFromNib())
    }
    
    /// redirectToSelectUserType is used to redirect to user type selection screen
    func redirectToLogin() {
//        clearLoginData()
        self.setupNavigationController(rootController: LoginVC.loadFromNib())
    }
    
    func redirectToSignup() {
        self.setupNavigationController(rootController: RegisterVC.loadFromNib())
        
    }
    
    func redirectToHome() {
        self.setupNavigationController(rootController: TabBarVC())
    }
    
    func redirectToResetPassword(with url: URL? = nil) {
        print("🔗 redirectToResetPassword called with URL: \(url?.absoluteString ?? "nil")")
        let resetVC = ResetPasswordVC.loadFromNib()
        resetVC.resetURL = url
        let nav = UINavigationController(rootViewController: resetVC)
        nav.isNavigationBarHidden = false
        self.setWindowRootViewController(rootVC: nav, animated: true, completion: nil)
    }
}
