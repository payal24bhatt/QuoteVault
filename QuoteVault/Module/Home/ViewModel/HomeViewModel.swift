//
//  HomeViewModel.swift
//  QuoteVault
//
//  Created by Payal Bhatt on 13/01/26.
//

import Foundation
import UIKit

protocol HomeViewModelDelegate: AnyObject {
    func quotesFetched(_ quotes: [Quote])
    func quoteOfTheDayFetched(_ quote: Quote?)
    func errorOccurred(_ message: String)
}

class HomeViewModel {
    
    /// Variable(s)
    weak var delegate: HomeViewModelDelegate?
    private var currentPage = 0
    private let pageSize = 20
    private var isLoading = false
    private var hasMore = true
    
    func fetchQuoteOfTheDay() {
        Task {
            do {
                let quote = try await QuoteRepository.shared.fetchQuoteOfTheDay()
                DispatchQueue.main.async {
                    // Silently handle nil quote (no quotes in database yet)
                    self.delegate?.quoteOfTheDayFetched(quote)
                }
            } catch {
                // Log error but don't show alert - quote of the day is non-critical
                print("⚠️ Failed to fetch quote of the day: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    // Return nil instead of showing error - allows app to continue
                    self.delegate?.quoteOfTheDayFetched(nil)
                }
            }
        }
    }
    
    func fetchQuotes(reset: Bool = false, categoryId: UUID? = nil, searchText: String? = nil, author: String? = nil) {
        guard !isLoading && (hasMore || reset) else { return }
        
        if reset {
            currentPage = 0
            hasMore = true
        }
        
        isLoading = true
        
        Task {
            do {
                let quotes = try await QuoteRepository.shared.fetchQuotes(
                    limit: pageSize,
                    offset: currentPage * pageSize,
                    categoryId: categoryId,
                    searchText: searchText,
                    author: author
                )
                
                hasMore = quotes.count == pageSize
                currentPage += 1
                isLoading = false
                
                DispatchQueue.main.async {
                    self.delegate?.quotesFetched(quotes)
                }
            } catch {
                isLoading = false
                DispatchQueue.main.async {
                    self.delegate?.errorOccurred("Failed to fetch quotes: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func resetPagination() {
        currentPage = 0
        hasMore = true
        isLoading = false
    }
}
