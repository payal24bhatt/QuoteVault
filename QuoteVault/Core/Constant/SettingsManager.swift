//
//  SettingsManager.swift
//  QuoteVault
//
//  Created by Payal Bhatt on 13/01/26.
//

import UIKit

class SettingsManager {
    static let shared = SettingsManager()
    
    private var cachedSettings: UserSettings?
    private var isLoading = false
    
    private init() {}
    
    // MARK: - Load Settings
    
    func loadSettings() async throws -> UserSettings? {
        guard let userId = SupabaseService.shared.userId else { return nil }
        
        let settings = try await QuoteRepository.shared.fetchSettings(userId: userId)
        cachedSettings = settings
        return settings
    }
    
    func getCachedSettings() -> UserSettings? {
        return cachedSettings
    }
    
    // MARK: - Font Size
    
    func getFontSize() -> CGFloat {
        if let settings = cachedSettings {
            return CGFloat(settings.fontSize)
        }
        return 16 // Default
    }
    
    // MARK: - Accent Color
    
    func getAccentColor() -> UIColor {
        if let settings = cachedSettings {
            return colorForAccentName(settings.accentColor)
        }
        return .systemTeal // Default
    }
    
    func colorForAccentName(_ name: String) -> UIColor {
        switch name.lowercased() {
        case "blue":
            return .systemBlue
        case "purple":
            return .systemPurple
        case "teal":
            return .systemTeal
        case "orange":
            return .systemOrange
        case "pink":
            return .systemPink
        default:
            return .systemTeal
        }
    }
    
    // MARK: - Theme
    
    func getTheme() -> String {
        return cachedSettings?.theme ?? "system"
    }
    
    // MARK: - Refresh
    
    func refreshSettings() {
        Task {
            do {
                _ = try await loadSettings()
            } catch {
                print("Failed to refresh settings: \(error.localizedDescription)")
            }
        }
    }
}

