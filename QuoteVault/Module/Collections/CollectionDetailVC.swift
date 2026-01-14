//
//  CollectionDetailVC.swift
//  QuoteVault
//
//  Created by Payal Bhatt on 13/01/26.
//

import UIKit

class CollectionDetailVC: UIViewController {
    
    @IBOutlet weak var tblQuotes: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var emptyStateView: UIView!
    @IBOutlet weak var emptyStateLabel: UILabel!
    
    var collection: Collection!
    var quotes: [Quote] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        loadQuotes()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Reload quotes when returning from AddQuoteToCollectionVC
        loadQuotes()
    }
    
    func prepareUI() {
        title = collection.name
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addQuote)
        )
        
        // Safely configure outlets with nil checks
        if let tblQuotes = tblQuotes {
            tblQuotes.delegate = self
            tblQuotes.dataSource = self
            tblQuotes.register(UINib(nibName: "QuoteCell", bundle: nil), forCellReuseIdentifier: "QuoteCell")
            tblQuotes.rowHeight = UITableView.automaticDimension
            tblQuotes.estimatedRowHeight = 120
        }
        
        if let activityIndicator = activityIndicator {
            activityIndicator.hidesWhenStopped = true
        }
        
        if let emptyStateLabel = emptyStateLabel {
            emptyStateLabel.text = "No quotes in this collection.\nAdd quotes to get started!"
            emptyStateLabel.textAlignment = .center
            emptyStateLabel.numberOfLines = 0
        }
        
        if let emptyStateView = emptyStateView {
            emptyStateView.isHidden = true
        }
    }
    
    @objc func addQuote() {
        let vc = AddQuoteToCollectionVC.loadFromNib()
        vc.collectionId = collection.id
        vc.onQuoteAdded = { [weak self] in
            self?.loadQuotes()
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func loadQuotes() {
        let collectionId = collection.id
        
        activityIndicator?.startAnimating()
        
        Task {
            do {
                let quotes = try await QuoteRepository.shared.fetchCollectionQuotes(collectionId: collectionId)
                DispatchQueue.main.async {
                    self.activityIndicator?.stopAnimating()
                    self.quotes = quotes
                    self.tblQuotes?.reloadData()
                    self.updateEmptyState()
                }
            } catch {
                DispatchQueue.main.async {
                    self.activityIndicator?.stopAnimating()
                    self.alertView(message: "Failed to load quotes: \(error.localizedDescription)")
                    self.updateEmptyState()
                }
            }
        }
    }
    
    func updateEmptyState() {
        let isEmpty = quotes.isEmpty
        emptyStateView?.isHidden = !isEmpty
        tblQuotes?.isHidden = isEmpty
    }
    
    func removeQuote(_ quote: Quote, at indexPath: IndexPath) {
        let collectionId = collection.id
        
        Task {
            do {
                try await QuoteRepository.shared.removeQuoteFromCollection(collectionId: collectionId, quoteId: quote.id)
                DispatchQueue.main.async {
                    self.quotes.remove(at: indexPath.row)
                    self.tblQuotes.deleteRows(at: [indexPath], with: .fade)
                    self.updateEmptyState()
                }
            } catch {
                DispatchQueue.main.async {
                    self.alertView(message: "Failed to remove quote: \(error.localizedDescription)")
                }
            }
        }
    }
}

extension CollectionDetailVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quotes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "QuoteCell") as? QuoteCell else {
            let fallbackCell = UITableViewCell(style: .subtitle, reuseIdentifier: "FallbackCell")
            let quote = quotes[indexPath.row]
            fallbackCell.textLabel?.text = quote.text
            fallbackCell.textLabel?.numberOfLines = 0
            fallbackCell.detailTextLabel?.text = "- \(quote.author)"
            return fallbackCell
        }
        
        let quote = quotes[indexPath.row]
        cell.configure(quote: quote, isFavorite: false)
        cell.btnFavorite.isHidden = true
        
        cell.onShareTapped = { [weak self] in
            let text = "\"\(quote.text)\" - \(quote.author)"
            let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
            self?.present(activityVC, animated: true)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let quote = quotes[indexPath.row]
            removeQuote(quote, at: indexPath)
        }
    }
}

