//
//  QuoteModel.swift
//  QuoteVault
//
//  Created by Payal Bhatt on 13/01/26.
//

import Foundation

struct Quote: Codable, Identifiable {
    let id: UUID
    let text: String
    let author: String
    let categoryId: UUID
    let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case text
        case author
        case categoryId = "category_id"
        case createdAt = "created_at"
    }
}

struct Category: Codable, Identifiable {
    let id: UUID
    let name: String
    let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case createdAt = "created_at"
    }
}

struct UserFavorite: Codable {
    let id: UUID
    let userId: UUID
    let quoteId: UUID
    let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case quoteId = "quote_id"
        case createdAt = "created_at"
    }
}

struct Collection: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let name: String
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case createdAt = "created_at"
    }
}

struct CollectionQuote: Codable {
    let id: UUID
    let collectionId: UUID
    let quoteId: UUID
    
    enum CodingKeys: String, CodingKey {
        case id
        case collectionId = "collection_id"
        case quoteId = "quote_id"
    }
}

struct UserProfile: Codable {
    let id: UUID              // auth.users.id
    let name: String?
    let avatarUrl: String?
    let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case avatarUrl = "avatar_url"
        case createdAt = "created_at"
    }
}

struct UserSettings: Codable {
    let userId: UUID
    let theme: String
    let fontSize: Int
    let accentColor: String

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case theme
        case fontSize = "font_size"
        case accentColor = "accent_color"
    }
}

struct QuoteWithCategory: Codable {
    let quote: Quote
    let category: Category?
    var isFavorite: Bool = false
}

