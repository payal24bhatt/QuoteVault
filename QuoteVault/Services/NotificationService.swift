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
            print("Invalid time format")
            return
        }
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Quote of the Day"
        content.body = "Check out today's inspiring quote!"
        content.sound = .default
        
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
                print("Failed to schedule notification: \(error.localizedDescription)")
            } else {
                print("Daily quote notification scheduled for \(time)")
            }
        }
    }
    
    func cancelDailyQuoteNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dailyQuote"])
    }
}
