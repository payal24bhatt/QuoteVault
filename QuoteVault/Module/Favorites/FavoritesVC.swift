//
//  FavoritesVC.swift
//  QuoteVault
//
//  Created by Payal Bhatt on 13/01/26.
//

import UIKit

class FavoritesVC: UIViewController {
    
    @IBOutlet weak var tblFavorites: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var emptyStateView: UIView!
    @IBOutlet weak var emptyStateLabel: UILabel!
    
    var favoriteQuotes: [Quote] = []
    var currentUserId: UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        loadCurrentUser()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFavorites()
        loadSettingsAndApply()
    }
    
    func loadSettingsAndApply() {
        Task {
            do {
                _ = try await SettingsManager.shared.loadSettings()
                DispatchQueue.main.async {
                    self.tblFavorites?.reloadData()
                }
            } catch {
                print("Failed to load settings: \(error.localizedDescription)")
            }
        }
    }
    
    func loadCurrentUser() {
        currentUserId = SupabaseService.shared.userId
    }
    
    func prepareUI() {
        title = "Favorites"
        
        // Safely check if outlets are connected
        if tblFavorites == nil {
            print("⚠️ Error: tblFavorites outlet not connected in XIB file")
            print("⚠️ Please connect the tblFavorites outlet in FavoritesVC.xib")
            return
        }
        
        tblFavorites.delegate = self
        tblFavorites.dataSource = self
        tblFavorites.register(UINib(nibName: "QuoteCell", bundle: nil), forCellReuseIdentifier: "QuoteCell")
        tblFavorites.rowHeight = UITableView.automaticDimension
        tblFavorites.estimatedRowHeight = 120
        tblFavorites.separatorStyle = .none
        
        activityIndicator?.hidesWhenStopped = true
        
        emptyStateLabel?.text = "No favorites yet.\nStart adding quotes to your favorites!"
        emptyStateLabel?.textAlignment = .center
        emptyStateLabel?.numberOfLines = 0
        emptyStateView?.isHidden = true
    }
    
    func loadFavorites() {
        guard let userId = currentUserId else {
            emptyStateView?.isHidden = false
            tblFavorites?.isHidden = true
            return
        }
        
        // Check if outlet is connected
        guard tblFavorites != nil else {
            print("⚠️ Error: tblFavorites outlet not connected")
            return
        }
        
        activityIndicator?.startAnimating()
        
        Task {
            do {
                let quotes = try await QuoteRepository.shared.fetchFavoriteQuotes(userId: userId)
                DispatchQueue.main.async {
                    self.activityIndicator?.stopAnimating()
                    self.favoriteQuotes = quotes
                    self.tblFavorites?.reloadData()
                    self.updateEmptyState()
                }
            } catch {
                DispatchQueue.main.async {
                    self.activityIndicator?.stopAnimating()
                    self.alertView(message: "Failed to load favorites: \(error.localizedDescription)")
                    self.updateEmptyState()
                }
            }
        }
    }
    
    func updateEmptyState() {
        let isEmpty = favoriteQuotes.isEmpty
        emptyStateView?.isHidden = !isEmpty
        tblFavorites?.isHidden = isEmpty
    }
    
    func refreshFavorites() {
        loadFavorites()
    }
    
    func removeFavorite(quote: Quote, at indexPath: IndexPath) {
        guard let userId = currentUserId else { return }
        
        Task {
            do {
                try await QuoteRepository.shared.removeFavorite(userId: userId, quoteId: quote.id)
                DispatchQueue.main.async {
                    self.favoriteQuotes.remove(at: indexPath.row)
                    self.tblFavorites.deleteRows(at: [indexPath], with: .fade)
                    self.updateEmptyState()
                }
            } catch {
                DispatchQueue.main.async {
                    self.alertView(message: "Failed to remove favorite: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func shareQuote(_ quote: Quote) {
        let alert = UIAlertController(title: "Share Quote", message: "Choose sharing option", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Share as Text", style: .default) { [weak self] _ in
            let text = "\"\(quote.text)\" - \(quote.author)"
            let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = self?.view
                popover.sourceRect = CGRect(x: self?.view.bounds.midX ?? 0, y: self?.view.bounds.midY ?? 0, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            self?.present(activityVC, animated: true)
        })
        
        alert.addAction(UIAlertAction(title: "Share as Card", style: .default) { [weak self] _ in
            guard let cardImage = QuoteCardGenerator.generateCard(quote: quote, style: .minimal) else { return }
            let activityVC = UIActivityViewController(activityItems: [cardImage], applicationActivities: nil)
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = self?.view
                popover.sourceRect = CGRect(x: self?.view.bounds.midX ?? 0, y: self?.view.bounds.midY ?? 0, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            self?.present(activityVC, animated: true)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        present(alert, animated: true)
    }
}

extension FavoritesVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteQuotes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row < favoriteQuotes.count else {
            return UITableViewCell()
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "QuoteCell") as? QuoteCell else {
            // Fallback cell
            let fallbackCell = UITableViewCell(style: .subtitle, reuseIdentifier: "FallbackCell")
            let quote = favoriteQuotes[indexPath.row]
            fallbackCell.textLabel?.text = quote.text
            fallbackCell.textLabel?.numberOfLines = 0
            fallbackCell.detailTextLabel?.text = "- \(quote.author)"
            return fallbackCell
        }
        
        let quote = favoriteQuotes[indexPath.row]
        cell.configure(quote: quote, isFavorite: true)
        
        cell.onFavoriteTapped = { [weak self] in
            self?.removeFavorite(quote: quote, at: indexPath)
        }
        
        cell.onShareTapped = { [weak self] in
            self?.shareQuote(quote)
        }
        
        return cell
    }
}
