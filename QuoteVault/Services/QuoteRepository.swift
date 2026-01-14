//
//  QuoteRepository.swift
//  QuoteVault
//
//  Created by Payal Bhatt on 13/01/26.
//

import Foundation
import Supabase

final class QuoteRepository {
    static let shared = QuoteRepository()
    private let client = SupabaseService.shared.client
    
    private init() {}
    
    // MARK: - Quotes
    
    func fetchQuotes(limit: Int = 20, offset: Int = 0, categoryId: UUID? = nil, searchText: String? = nil, author: String? = nil) async throws -> [Quote] {
        // If both searchText and author are provided with the same value, search in both fields using OR logic
        if let searchText = searchText, !searchText.isEmpty, 
           let author = author, !author.isEmpty, 
           searchText == author {
            // Search in both text and author fields - fetch results matching either
            var query1 = client.database.from("quotes").select("*")
            var query2 = client.database.from("quotes").select("*")
            
            if let categoryId = categoryId {
                query1 = query1.eq("category_id", value: categoryId)
                query2 = query2.eq("category_id", value: categoryId)
            }
            
            query1 = query1.ilike("text", pattern: "%\(searchText)%")
            query2 = query2.ilike("author", pattern: "%\(author)%")
            
            // Execute both queries
            let results1: [Quote] = try await query1.execute().value
            let results2: [Quote] = try await query2.execute().value
            
            // Combine and deduplicate results
            var allQuotes = results1 + results2
            var uniqueQuotes: [Quote] = []
            var seenIds: Set<UUID> = []
            
            for quote in allQuotes {
                if !seenIds.contains(quote.id) {
                    seenIds.insert(quote.id)
                    uniqueQuotes.append(quote)
                }
            }
            
            // Sort by created_at descending
            uniqueQuotes.sort { ($0.createdAt ?? Date.distantPast) > ($1.createdAt ?? Date.distantPast) }
            
            // Apply pagination
            let startIndex = min(offset, uniqueQuotes.count)
            let endIndex = min(offset + limit, uniqueQuotes.count)
            
            return Array(uniqueQuotes[startIndex..<endIndex])
        } else {
            // Normal query with single search parameter
            var query = client.database.from("quotes").select("*")
            
            if let categoryId = categoryId {
                query = query.eq("category_id", value: categoryId)
            }
            
            if let searchText = searchText, !searchText.isEmpty {
                query = query.ilike("text", pattern: "%\(searchText)%")
            }
            
            if let author = author, !author.isEmpty {
                query = query.ilike("author", pattern: "%\(author)%")
            }
            
            do {
                let response: [Quote] = try await query
                    .order("created_at", ascending: false)
                    .range(from: offset, to: offset + limit - 1)
                    .execute()
                    .value
                return response
            } catch {
                print("❌ Widget: Error decoding quotes: \(error.localizedDescription)")
                if let decodingError = error as? DecodingError {
                    switch decodingError {
                    case .keyNotFound(let key, let context):
                        print("❌ Missing key: \(key.stringValue) in \(context.debugDescription)")
                    case .typeMismatch(let type, let context):
                        print("❌ Type mismatch: expected \(type) in \(context.debugDescription)")
                    case .valueNotFound(let type, let context):
                        print("❌ Value not found: \(type) in \(context.debugDescription)")
                    case .dataCorrupted(let context):
                        print("❌ Data corrupted: \(context.debugDescription)")
                    @unknown default:
                        print("❌ Unknown decoding error")
                    }
                }
                throw error
            }
        }
    }
    
    func fetchQuoteOfTheDay() async throws -> Quote? {
        do {
            let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
            let total = try await getTotalQuoteCount()
            
            print("📊 Widget: Total quotes: \(total), Day of year: \(dayOfYear)")
            
            guard total > 0 else {
                print("⚠️ Widget: No quotes found in database")
                return nil
            }
            
            let index = dayOfYear % total
            print("📊 Widget: Fetching quote at index: \(index)")
            
            let quotes = try await fetchQuotes(limit: 1, offset: index)
            print("✅ Widget: Fetched \(quotes.count) quote(s)")
            
            return quotes.first
        } catch {
            print("❌ Widget: Error in fetchQuoteOfTheDay: \(error.localizedDescription)")
            throw error
        }
    }
    
    private func getTotalQuoteCount() async throws -> Int {
        do {
            // Create a minimal struct that only decodes the id field
            struct QuoteId: Decodable {
                let id: UUID
            }
            
            let response: [QuoteId] = try await client.database
                .from("quotes")
                .select("id")
                .execute()
                .value
            print("📊 Widget: Total quote count query returned \(response.count) quotes")
            return response.count
        } catch {
            print("❌ Widget: Error getting quote count: \(error.localizedDescription)")
            if let decodingError = error as? DecodingError {
                print("❌ Widget: Decoding error details: \(decodingError)")
                switch decodingError {
                case .keyNotFound(let key, let context):
                    print("❌ Missing key: \(key.stringValue) in \(context.debugDescription)")
                case .typeMismatch(let type, let context):
                    print("❌ Type mismatch: expected \(type) in \(context.debugDescription)")
                case .valueNotFound(let type, let context):
                    print("❌ Value not found: \(type) in \(context.debugDescription)")
                case .dataCorrupted(let context):
                    print("❌ Data corrupted: \(context.debugDescription)")
                @unknown default:
                    print("❌ Unknown decoding error")
                }
            }
            throw error
        }
    }
    
    func fetchQuoteById(_ id: UUID) async throws -> Quote? {
        let response: [Quote] = try await client.database
            .from("quotes")
            .select("*")
            .eq("id", value: id)
            .limit(1)
            .execute()
            .value
        return response.first
    }
    
    // MARK: - Categories
    
    func fetchCategories() async throws -> [Category] {
        do {
            print("✅ Fetching categories from database...")
            
            let response: [Category] = try await client.database
                .from("categories")
                .select("*")
                .order("name", ascending: true)
                .execute()
                .value
            
            print("✅ fetchCategories: Retrieved \(response.count) categories from database")
            if !response.isEmpty {
                print("✅ Category names: \(response.map { $0.name })")
            } else {
                print("⚠️ Categories array is empty - check if table has data")
            }
            return response
        } catch {
            print("❌ fetchCategories error: \(error)")
            print("❌ Error type: \(type(of: error))")
            if let decodingError = error as? DecodingError {
                print("❌ Decoding error details: \(decodingError)")
                switch decodingError {
                case .keyNotFound(let key, let context):
                    print("❌ Missing key: \(key.stringValue) in \(context.debugDescription)")
                case .typeMismatch(let type, let context):
                    print("❌ Type mismatch: expected \(type) in \(context.debugDescription)")
                case .valueNotFound(let type, let context):
                    print("❌ Value not found: \(type) in \(context.debugDescription)")
                case .dataCorrupted(let context):
                    print("❌ Data corrupted: \(context.debugDescription)")
                @unknown default:
                    print("❌ Unknown decoding error")
                }
            }
            throw error
        }
    }
    
    // MARK: - Favorites
    
    func addFavorite(userId: UUID, quoteId: UUID) async throws {
        struct FavoriteInsert: Encodable {
            let user_id: UUID
            let quote_id: UUID
        }
        
        let favorite = FavoriteInsert(user_id: userId, quote_id: quoteId)
        try await client.database
            .from("user_favorites")
            .insert(favorite)
            .execute()
    }
    
    func removeFavorite(userId: UUID, quoteId: UUID) async throws {
        try await client.database
            .from("user_favorites")
            .delete()
            .eq("user_id", value: userId)
            .eq("quote_id", value: quoteId)
            .execute()
    }
    
    func isFavorite(userId: UUID, quoteId: UUID) async throws -> Bool {
        let response: [UserFavorite] = try await client.database
            .from("user_favorites")
            .select("*")
            .eq("user_id", value: userId)
            .eq("quote_id", value: quoteId)
            .limit(1)
            .execute()
            .value
        return !response.isEmpty
    }
    
    func fetchFavoriteQuotes(userId: UUID) async throws -> [Quote] {
        struct FavoriteRow: Decodable {
            let quote_id: UUID
        }
        
        let favorites: [FavoriteRow] = try await client.database
            .from("user_favorites")
            .select("quote_id")
            .eq("user_id", value: userId)
            .order("created_at", ascending: false)
            .execute()
            .value
        
        guard !favorites.isEmpty else { return [] }
        
        let quoteIds = favorites.map { $0.quote_id }
        let quotes: [Quote] = try await client.database
            .from("quotes")
            .select("*")
            .in("id", values: quoteIds)
            .execute()
            .value
        
        // Preserve order from favorites
        return quoteIds.compactMap { id in
            quotes.first { $0.id == id }
        }
    }
    
    // MARK: - Collections
    
    func createCollection(userId: UUID, name: String) async throws -> Collection {
        struct CollectionInsert: Encodable {
            let user_id: UUID
            let name: String
        }
        
        let collection = CollectionInsert(user_id: userId, name: name)
        let response: [Collection] = try await client.database
            .from("collections")
            .insert(collection)
            .select()
            .execute()
            .value
        return response[0]
    }
    
    func fetchCollections(userId: UUID) async throws -> [Collection] {
        let response: [Collection] = try await client.database
            .from("collections")
            .select("*")
            .eq("user_id", value: userId)
            .order("created_at", ascending: false)
            .execute()
            .value
        return response
    }
    
    func deleteCollection(collectionId: UUID) async throws {
        try await client.database
            .from("collections")
            .delete()
            .eq("id", value: collectionId)
            .execute()
    }
    
    func addQuoteToCollection(collectionId: UUID, quoteId: UUID) async throws {
        // Check if quote already exists in collection to prevent duplicates
        struct CollectionQuoteCheck: Decodable {
            let id: UUID
        }
        
        let existing: [CollectionQuoteCheck] = try await client.database
            .from("collection_quotes")
            .select("id")
            .eq("collection_id", value: collectionId)
            .eq("quote_id", value: quoteId)
            .execute()
            .value
        
        if !existing.isEmpty {
            throw NSError(domain: "QuoteRepository", code: 409, userInfo: [NSLocalizedDescriptionKey: "Quote already exists in this collection"])
        }
        
        struct CollectionQuoteInsert: Encodable {
            let collection_id: UUID
            let quote_id: UUID
        }
        
        let collectionQuote = CollectionQuoteInsert(collection_id: collectionId, quote_id: quoteId)
        try await client.database
            .from("collection_quotes")
            .insert(collectionQuote)
            .execute()
    }
    
    func removeQuoteFromCollection(collectionId: UUID, quoteId: UUID) async throws {
        // Fetch the specific collection_quote entry ID to delete only one instance
        struct CollectionQuoteRow: Decodable {
            let id: UUID
        }
        
        let rows: [CollectionQuoteRow] = try await client.database
            .from("collection_quotes")
            .select("id")
            .eq("collection_id", value: collectionId)
            .eq("quote_id", value: quoteId)
            .limit(1)
            .execute()
            .value
        
        guard let rowToDelete = rows.first else {
            throw NSError(domain: "QuoteRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "Quote not found in collection"])
        }
        
        // Delete by specific ID to ensure only one instance is deleted
        try await client.database
            .from("collection_quotes")
            .delete()
            .eq("id", value: rowToDelete.id)
            .execute()
    }
    
    func fetchCollectionQuotes(collectionId: UUID) async throws -> [Quote] {
        struct Row: Decodable {
            let quote_id: UUID
        }
        
        let rows: [Row] = try await client.database
            .from("collection_quotes")
            .select("quote_id")
            .eq("collection_id", value: collectionId)
            .execute()
            .value
        
        guard !rows.isEmpty else { return [] }
        
        let quoteIds = rows.map { $0.quote_id }
        let quotes: [Quote] = try await client.database
            .from("quotes")
            .select("*")
            .in("id", values: quoteIds)
            .execute()
            .value
        
        return quoteIds.compactMap { id in
            quotes.first { $0.id == id }
        }
    }
    
    // MARK: - Profile
    
    func fetchProfile(userId: UUID) async throws -> UserProfile? {
        let response: [UserProfile] = try await client.database
            .from("profiles")
            .select("*")
            .eq("id", value: userId)
            .limit(1)
            .execute()
            .value
        return response.first
    }
    
    func upsertProfile(userId: UUID, name: String?, avatarUrl: String?) async throws {
        struct ProfileUpsert: Encodable {
            let id: UUID
            let name: String?
            let avatar_url: String?
        }
        
        let profile = ProfileUpsert(id: userId, name: name, avatar_url: avatarUrl)
        try await client.database
            .from("profiles")
            .upsert(profile)
            .execute()
    }
    
    // MARK: - Settings
    
    func fetchSettings(userId: UUID) async throws -> UserSettings? {
        let response: [UserSettings] = try await client.database
            .from("user_settings")
            .select("*")
            .eq("user_id", value: userId)
            .limit(1)
            .execute()
            .value
        return response.first
    }
    
    func upsertSettings(userId: UUID, theme: String, fontSize: Int, accentColor: String) async throws {
        struct SettingsUpsert: Encodable {
            let user_id: UUID
            let theme: String
            let font_size: Int
            let accent_color: String
        }
        
        let settings = SettingsUpsert(
            user_id: userId,
            theme: theme,
            font_size: fontSize,
            accent_color: accentColor
        )
        
        try await client.database
            .from("user_settings")
            .upsert(settings)
            .execute()
    }
}

