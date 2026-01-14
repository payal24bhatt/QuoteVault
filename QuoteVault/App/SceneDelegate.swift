//
//  SceneDelegate.swift
//  QuoteVault
//
//  Created by Payal Bhatt on 13/01/26.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        Constants.appDelegate.window = window
        
        // Load and apply theme on app launch
        ThemeManager.shared.loadAndApplyTheme()
        
        // Handle widget deep link
        if let urlContext = connectionOptions.urlContexts.first {
            handleWidgetURL(urlContext.url)
        }
        
        // TEMP: show Home / Splash / Login
        let rootVC = SplashVC.loadFromNib()
        let nav = UINavigationController(rootViewController: rootVC)
        
        window.rootViewController = nav
        self.window = window
        window.makeKeyAndVisible()
    }
    
    // Handle widget tap - opens app to home screen showing quote of the day
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        handleWidgetURL(url)
    }
    
    private func handleWidgetURL(_ url: URL) {
        // Widget URL scheme: quotevault://quoteoftheday
        if url.scheme == "quotevault" && url.host == "quoteoftheday" {
            // Navigate to home screen (which shows quote of the day)
            DispatchQueue.main.async {
                guard let window = self.window else { return }
                
                // Check if user is logged in
                if SupabaseService.shared.isLoggedIn {
                    // User is logged in - go directly to home
                    let tabBarVC = TabBarVC()
                    let nav = UINavigationController(rootViewController: tabBarVC)
                    window.rootViewController = nav
                    window.makeKeyAndVisible()
                } else {
                    // User not logged in - go to splash/login
                    let rootVC = SplashVC.loadFromNib()
                    let nav = UINavigationController(rootViewController: rootVC)
                    window.rootViewController = nav
                    window.makeKeyAndVisible()
                }
            }
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}

