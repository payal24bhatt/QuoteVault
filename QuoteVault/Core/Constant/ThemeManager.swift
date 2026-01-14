//
//  ThemeManager.swift
//  QuoteVault
//
//  Created by Payal Bhatt on 13/01/26.
//

import UIKit

class ThemeManager {
    static let shared = ThemeManager()
    
    private init() {}
    
    func applyTheme(_ theme: String) {
        let style: UIUserInterfaceStyle
        
        switch theme.lowercased() {
        case "system", "auto":
            style = .unspecified
        case "dark":
            style = .dark
        case "light":
            style = .light
        default:
            style = .unspecified
        }
        
        // Apply to all windows in all scenes
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            for window in windowScene.windows {
                window.overrideUserInterfaceStyle = style
            }
        }
        
        // Also apply to AppDelegate window if it exists
        if let window = Constants.appDelegate.window {
            window.overrideUserInterfaceStyle = style
        }
    }
    
    func loadAndApplyTheme() {
        guard let userId = SupabaseService.shared.userId else {
            // Default to system if not logged in
            applyTheme("system")
            return
        }
        
        Task {
            do {
                let settings = try await QuoteRepository.shared.fetchSettings(userId: userId)
                let theme = settings?.theme.isEmpty == false ? settings?.theme : "system"
                DispatchQueue.main.async {
                    self.applyTheme(theme ?? "system")
                }
            } catch {
                // Default to system on error
                DispatchQueue.main.async {
                    self.applyTheme("system")
                }
            }
        }
    }
}
