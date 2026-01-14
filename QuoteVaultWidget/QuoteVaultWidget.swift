//
//  QuoteVaultWidget.swift
//  QuoteVaultWidget
//
//  Created by Payal Bhatt on 13/01/26.
//

import WidgetKit
import SwiftUI

// MARK: - Timeline Provider
struct QuoteProvider: TimelineProvider {
    func placeholder(in context: Context) -> QuoteEntry {
        QuoteEntry(
            date: Date(),
            quote: Quote(
                id: UUID(),
                text: "The only way to do great work is to love what you do.",
                author: "Steve Jobs",
                categoryId: UUID(),
                createdAt: nil
            )
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (QuoteEntry) -> ()) {
        // For preview/snapshot, return placeholder immediately
        // This is called when widget is being previewed or needs a quick snapshot
        let entry = QuoteEntry(
            date: Date(),
            quote: Quote(
                id: UUID(),
                text: "The only way to do great work is to love what you do.",
                author: "Steve Jobs",
                categoryId: UUID(),
                createdAt: nil
            )
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<QuoteEntry>) -> ()) {
        // Always provide a fallback quote - widget will show this immediately
        let fallbackQuote = Quote(
            id: UUID(),
            text: "The only way to do great work is to love what you do.",
            author: "Steve Jobs",
            categoryId: UUID(),
            createdAt: nil
        )
        
        // Try to fetch real quote, but always provide fallback
        Task {
            var finalQuote = fallbackQuote
            var shouldRetry = true
            
            do {
                // Fetch quote of the day from Supabase
                var quote = try await QuoteRepository.shared.fetchQuoteOfTheDay()
                
                // If quote of the day fails, try to fetch any quote as fallback
                if quote == nil {
                    print("⚠️ Widget: Quote of the day returned nil, trying to fetch any quote...")
                    let quotes = try await QuoteRepository.shared.fetchQuotes(limit: 1, offset: 0)
                    quote = quotes.first
                }
                
                if let quote = quote {
                    print("✅ Widget: Successfully fetched quote: \"\(quote.text)\" by \(quote.author)")
                    finalQuote = quote
                    shouldRetry = false
                } else {
                    print("⚠️ Widget: No quote returned from database, using fallback")
                    shouldRetry = true
                }
            } catch {
                // Fallback entry on error - always show something
                print("❌ Widget error fetching quote: \(error.localizedDescription)")
                print("❌ Widget error type: \(type(of: error))")
                if let urlError = error as? URLError {
                    print("❌ Widget URL error: \(urlError.localizedDescription), code: \(urlError.code.rawValue)")
                }
                shouldRetry = true
            }
            
            // Create entry with fetched or fallback quote
            let entry = QuoteEntry(date: Date(), quote: finalQuote)
            
            // Update once per day at midnight, or retry in 1 hour if error
            let calendar = Calendar.current
            let nextUpdate: Date
            if shouldRetry {
                // Retry in 1 hour if there was an error
                nextUpdate = calendar.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
            } else {
                // Update at midnight if successful
                nextUpdate = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: Date()) ?? Date())
            }
            
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            
            DispatchQueue.main.async {
                completion(timeline)
            }
        }
    }
}

// MARK: - Timeline Entry
struct QuoteEntry: TimelineEntry {
    let date: Date
    let quote: Quote
}

// MARK: - Widget View
struct QuoteVaultWidgetEntryView: View {
    var entry: QuoteProvider.Entry
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            
            Text("QUOTE OF THE DAY")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.secondary)
                .privacySensitive(false)
            
            Text(entry.quote.text)
                .font(.system(size: 15))
                .foregroundColor(.primary)
                .lineLimit(4)
                .privacySensitive(false)   // ⭐ IMPORTANT
            
            Spacer(minLength: 4)
            
            Text("— \(entry.quote.author)")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .privacySensitive(false)   // ⭐ IMPORTANT
        }
        .padding(12)
    }
}

// MARK: - Widget Configuration
struct QuoteVaultWidget: Widget {
    let kind = "QuoteVaultWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: QuoteProvider()) { entry in
            if #available(iOS 17.0, *) {
                QuoteVaultWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                QuoteVaultWidgetEntryView(entry: entry)
                    .background(Color(.systemBackground))
            }
        }
        .configurationDisplayName("Quote of the Day")
        .description("Displays today's inspiring quote.")
        .supportedFamilies([.systemMedium]) // ⚠️ IMPORTANT
    }
}

// MARK: - Preview
// Preview removed for iOS 16 compatibility
// For iOS 17+, you can use: #Preview(as: .systemSmall) { QuoteVaultWidget() } timeline: { ... }
