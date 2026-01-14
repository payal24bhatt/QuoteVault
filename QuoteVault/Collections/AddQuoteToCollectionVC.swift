//
//  AddQuoteToCollectionVC.swift
//  QuoteVault
//
//  Created by Payal Bhatt on 13/01/26.
//

import UIKit

class AddQuoteToCollectionVC: UIViewController {
    
    @IBOutlet weak var tblQuotes: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var quotes: [Quote] = []
    var collectionId: UUID?
    var onQuoteAdded: (() -> Void)?
    
    lazy var viewModel: HomeViewModel = {
        let vm = HomeViewModel()
        vm.delegate = self
        return vm
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        fetchQuotes()
    }
    
    func prepareUI() {
        title = "Add Quotes"
        
        searchBar.delegate = self
        searchBar.placeholder = "Search quotes..."
        
        tblQuotes.delegate = self
        tblQuotes.dataSource = self
        tblQuotes.register(UITableViewCell.self, forCellReuseIdentifier: "QuoteCell")
        tblQuotes.rowHeight = UITableView.automaticDimension
        tblQuotes.estimatedRowHeight = 100
        activityIndicator.hidesWhenStopped = true
    }
    
    func fetchQuotes() {
        activityIndicator.startAnimating()
        viewModel.fetchQuotes(reset: true)
    }
    
    func addQuoteToCollection(_ quote: Quote) {
        guard let collectionId = collectionId else { return }
        
        Task {
            do {
                try await QuoteRepository.shared.addQuoteToCollection(collectionId: collectionId, quoteId: quote.id)
                DispatchQueue.main.async {
                    self.alertView(message: "Quote added to collection!")
                    self.onQuoteAdded?()
                }
            } catch {
                DispatchQueue.main.async {
                    self.alertView(message: "Failed to add quote: \(error.localizedDescription)")
                }
            }
        }
    }
}

extension AddQuoteToCollectionVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quotes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuoteCell", for: indexPath)
        let quote = quotes[indexPath.row]
        cell.textLabel?.text = quote.text
        cell.detailTextLabel?.text = "- \(quote.author)"
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.numberOfLines = 0
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let quote = quotes[indexPath.row]
        addQuoteToCollection(quote)
    }
}

extension AddQuoteToCollectionVC: HomeViewModelDelegate {
    func quotesFetched(_ newQuotes: [Quote]) {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.quotes = newQuotes
            self.tblQuotes.reloadData()
        }
    }
    
    func quoteOfTheDayFetched(_ quote: Quote?) {}
    
    func errorOccurred(_ message: String) {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.alertView(message: message)
        }
    }
}

extension AddQuoteToCollectionVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

