//
//  NotificationService.swift
//  QuoteVault
//
//  Created by Payal Bhatt on 13/01/26.
//

import Foundation
import UserNotifications

class NotificationService {
    static let shared = NotificationService()
    
    private init() {
        requestAuthorization()
    }
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification authorization error: \(error.localizedDescription)")
            } else if granted {
                print("✅ Notification permission granted")
            } else {
                print("⚠️ Notification permission denied")
            }
        }
    }
    
    func scheduleDailyQuoteNotification(time: String) {
        // Remove existing notifications
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dailyQuote"])
        
        // Parse time string (HH:mm format)
        let components = time.split(separator: ":")
        guard components.count == 2,
              let hour = Int(components[0]),
              let minute = Int(components[1]) else {
            print("❌ Invalid time format: \(time)")
            return
        }
        
        // Fetch today's quote to include in notification
        Task {
            do {
                let quote = try await QuoteRepository.shared.fetchQuoteOfTheDay()
                
                // Create notification content
                let content = UNMutableNotificationContent()
                content.title = "Quote of the Day"
                
                if let quote = quote {
                    // Truncate quote if too long (notification body has character limit)
                    let quoteText = quote.text.count > 100 ? String(quote.text.prefix(100)) + "..." : quote.text
                    content.body = "\"\(quoteText)\" - \(quote.author)"
                } else {
                    content.body = "Check out today's inspiring quote!"
                }
                
                content.sound = .default
                content.badge = 1
                content.categoryIdentifier = "QUOTE_DAILY"
                
                // Create date components for daily trigger
                var dateComponents = DateComponents()
                dateComponents.hour = hour
                dateComponents.minute = minute
                
                // Create trigger
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                
                // Create request
                let request = UNNotificationRequest(
                    identifier: "dailyQuote",
                    content: content,
                    trigger: trigger
                )
                
                // Schedule notification
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        print("❌ Failed to schedule notification: \(error.localizedDescription)")
                    } else {
                        print("✅ Daily quote notification scheduled for \(time)")
                    }
                }
            } catch {
                print("❌ Failed to fetch quote for notification: \(error.localizedDescription)")
                // Schedule notification with default message if quote fetch fails
                self.scheduleDefaultNotification(time: time)
            }
        }
    }
    
    private func scheduleDefaultNotification(time: String) {
        let components = time.split(separator: ":")
        guard components.count == 2,
              let hour = Int(components[0]),
              let minute = Int(components[1]) else {
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Quote of the Day"
        content.body = "Check out today's inspiring quote!"
        content.sound = .default
        content.badge = 1
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: "dailyQuote",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule default notification: \(error.localizedDescription)")
            } else {
                print("✅ Default notification scheduled for \(time)")
            }
        }
    }
    
    func cancelDailyQuoteNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dailyQuote"])
        print("✅ Daily quote notification cancelled")
    }
    
    func updateNotificationSchedule(enabled: Bool, time: String?) {
        if enabled, let time = time {
            scheduleDailyQuoteNotification(time: time)
        } else {
            cancelDailyQuoteNotification()
        }
    }
}
