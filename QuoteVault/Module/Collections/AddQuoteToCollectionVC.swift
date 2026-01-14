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
    private var searchText: String?
    private var searchAuthor: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        fetchQuotes()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Re-ensure delegate is set (in case outlets weren't ready in viewDidLoad)
        if let tblQuotes = tblQuotes {
            if tblQuotes.delegate !== self {
                tblQuotes.delegate = self
                tblQuotes.dataSource = self
                tblQuotes.allowsSelection = true
            }
        }
    }
    
    func prepareUI() {
        title = "Add Quotes"
        
        // Setup search bar with nil check
        if let searchBar = searchBar {
            searchBar.delegate = self
            searchBar.placeholder = "Search quotes..."
            searchBar.searchBarStyle = .minimal
            searchBar.backgroundImage = UIImage()
            searchBar.backgroundColor = .clear
        }
        
        // Setup table view with nil checks
        if let tblQuotes = tblQuotes {
            tblQuotes.delegate = self
            tblQuotes.dataSource = self
            tblQuotes.register(UITableViewCell.self, forCellReuseIdentifier: "QuoteCell")
            tblQuotes.rowHeight = UITableView.automaticDimension
            tblQuotes.estimatedRowHeight = 100
            tblQuotes.allowsSelection = true
            tblQuotes.isUserInteractionEnabled = true
            print("✅ AddQuoteToCollectionVC: Table view configured successfully")
        } else {
            print("⚠️ AddQuoteToCollectionVC: tblQuotes outlet is nil! Check XIB connections.")
        }
        
        if let activityIndicator = activityIndicator {
            activityIndicator.hidesWhenStopped = true
        }
    }
    
    func fetchQuotes() {
        activityIndicator?.startAnimating()
        
        Task {
            do {
                let fetchedQuotes = try await QuoteRepository.shared.fetchQuotes(
                    limit: 100, // Fetch more quotes for selection
                    offset: 0,
                    categoryId: nil,
                    searchText: searchText,
                    author: searchAuthor
                )
                
                DispatchQueue.main.async {
                    self.activityIndicator?.stopAnimating()
                    self.quotes = fetchedQuotes
                    self.tblQuotes?.reloadData()
                }
            } catch {
                DispatchQueue.main.async {
                    self.activityIndicator?.stopAnimating()
                    self.alertView(message: "Failed to load quotes: \(error.localizedDescription)")
                }
            }
        }
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
                    let errorMessage = error.localizedDescription
                    if errorMessage.contains("already exists") {
                        self.alertView(message: "This quote is already in the collection")
                    } else {
                        self.alertView(message: "Failed to add quote: \(errorMessage)")
                    }
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
        guard indexPath.row < quotes.count else {
            return UITableViewCell()
        }
        
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
        print("✅ AddQuoteToCollectionVC: Cell tapped at row \(indexPath.row)")
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.row < quotes.count else {
            print("⚠️ AddQuoteToCollectionVC: Index out of bounds")
            return
        }
        let quote = quotes[indexPath.row]
        print("✅ AddQuoteToCollectionVC: Adding quote: \(quote.text)")
        addQuoteToCollection(quote)
    }
}


extension AddQuoteToCollectionVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        let searchTerm = searchBar.text?.isEmpty == false ? searchBar.text : nil
        searchText = searchTerm
        searchAuthor = searchTerm
        fetchQuotes()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
        searchText = nil
        searchAuthor = nil
        fetchQuotes()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            self.searchText = nil
            self.searchAuthor = nil
            fetchQuotes()
        }
    }
}

