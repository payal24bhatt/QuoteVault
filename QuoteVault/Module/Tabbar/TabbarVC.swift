//
//  TabbarVC.swift
//  QuoteVault
//
//  Created by Payal Bhatt on 13/01/26.
//

import UIKit

class TabBarVC: UITabBarController {
    
    private var homeVC: HomeVC!
    private var favoritesVC: FavoritesVC!
    private var collectionsVC: CollectionsVC!
    private var settingsVC: SettingsVC!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.backgroundImage = UIImage()
        tabBar.shadowImage = UIImage()
        tabBar.isTranslucent = true
        tabBar.backgroundColor = .clear
        setupTabs()
        delegate = self
        
        // Listen for settings updates
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleSettingsUpdated),
            name: NSNotification.Name("SettingsUpdated"),
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func handleSettingsUpdated() {
        loadSettingsAndApply()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Load and apply theme when tab bar appears
        ThemeManager.shared.loadAndApplyTheme()
        // Load and apply settings
        loadSettingsAndApply()
    }
    
    func loadSettingsAndApply() {
        guard let userId = SupabaseService.shared.userId else { return }
        
        Task {
            do {
                let settings = try await QuoteRepository.shared.fetchSettings(userId: userId)
                DispatchQueue.main.async {
                    self.applySettings()
                    // Schedule notifications if enabled
                    if let settings = settings,
                       let enabled = settings.notificationEnabled,
                       enabled,
                       let time = settings.notificationTime {
                        NotificationService.shared.updateNotificationSchedule(enabled: true, time: time)
                    } else {
                        // Disable notifications if not enabled
                        NotificationService.shared.updateNotificationSchedule(enabled: false, time: nil)
                    }
                }
            } catch {
                print("Failed to load settings: \(error.localizedDescription)")
            }
        }
    }
    
    func applySettings() {
        let accentColor = SettingsManager.shared.getAccentColor()
        tabBar.tintColor = accentColor
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Only apply transparent styling, let system handle positioning
        // This prevents layout issues when returning from view controllers that hide tab bar
        tabBar.backgroundImage = UIImage()
        tabBar.shadowImage = UIImage()
        tabBar.isTranslucent = true
        tabBar.backgroundColor = UIColor.clear
    }
    
    func setupTabs() {
        // Create HomeVC
        homeVC = HomeVC.loadFromNib()
        let homeNav = UINavigationController(rootViewController: homeVC)
        homeNav.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
        
        // Create FavoritesVC
        favoritesVC = FavoritesVC.loadFromNib()
        let favNav = UINavigationController(rootViewController: favoritesVC)
        favNav.tabBarItem = UITabBarItem(title: "Favorites", image: UIImage(systemName: "heart"), tag: 1)
        
        // Create CollectionsVC
        collectionsVC = CollectionsVC.loadFromNib()
        let collectionsNav = UINavigationController(rootViewController: collectionsVC)
        collectionsNav.tabBarItem = UITabBarItem(title: "Collections", image: UIImage(systemName: "folder"), tag: 2)
        
        // Create SettingsVC
        settingsVC = SettingsVC.loadFromNib()
        let settingsNav = UINavigationController(rootViewController: settingsVC)
        settingsNav.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gearshape"), tag: 3)
        
        viewControllers = [homeNav, favNav, collectionsNav, settingsNav]
        
        // Apply accent color from settings (will be updated when settings load)
        let accentColor = SettingsManager.shared.getAccentColor()
        tabBar.tintColor = accentColor
        tabBar.unselectedItemTintColor = .gray
    }
    
}

// MARK: - UITabBarControllerDelegate
extension TabBarVC: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        // Refresh data when switching tabs
        // Get the actual view controller from the navigation controller
        if let navController = viewController as? UINavigationController,
           let rootVC = navController.viewControllers.first {
            
            // Ensure tab bar is visible when switching tabs
            tabBar.isHidden = false
            
            if tabBarController.selectedIndex == 0 {
                if let home = rootVC as? HomeVC {
                    home.loadCurrentUser()
                    home.loadFavorites()
                }
            } else if tabBarController.selectedIndex == 1 {
                if let favorites = rootVC as? FavoritesVC {
                    favorites.loadFavorites()
                }
            } else if tabBarController.selectedIndex == 2 {
                if let collections = rootVC as? CollectionsVC {
                    collections.loadCollections()
                }
            }
        }
    }
}
