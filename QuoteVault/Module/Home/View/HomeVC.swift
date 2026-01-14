//
//  HomeVC.swift
//  QuoteVault
//
//  Created by Payal Bhatt on 13/01/26.
//

import UIKit

class HomeVC: UIViewController {
    
    /// IBOutlet(s)
    @IBOutlet weak var tblQuotes: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    /// Variable(s)
    var quotes: [Quote] = []
    var quoteOfTheDay: Quote?
    var currentUserId: UUID?
    var favoriteQuoteIds: Set<UUID> = []
    var refreshControl: UIRefreshControl!
    var selectedCategoryId: UUID?
    var searchText: String?
    var searchAuthor: String?
    
    lazy var viewModel: HomeViewModel = {
        let vm = HomeViewModel()
        vm.delegate = self
        return vm
    }()
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        loadCurrentUser()
        fetchQuoteOfTheDay()
        fetchQuotes(reset: true)
        
        // Listen for settings updates
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleSettingsUpdated),
            name: NSNotification.Name("SettingsUpdated"),
            object: nil
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadCurrentUser()
        loadFavorites()
        loadSettingsAndApply()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func handleSettingsUpdated() {
        loadSettingsAndApply()
    }
    
    func loadSettingsAndApply() {
        Task {
            do {
                _ = try await SettingsManager.shared.loadSettings()
                DispatchQueue.main.async {
                    self.applySettings()
                }
            } catch {
                print("Failed to load settings: \(error.localizedDescription)")
            }
        }
    }
    
    func applySettings() {
        let accentColor = SettingsManager.shared.getAccentColor()
        navigationItem.rightBarButtonItem?.tintColor = accentColor
        searchBar.tintColor = accentColor
        refreshControl?.tintColor = accentColor
        
        // Reload table to apply font size changes
        tblQuotes.reloadData()
    }
    
    func loadCurrentUser() {
        currentUserId = SupabaseService.shared.userId
    }
    
    func loadFavorites() {
        guard let userId = currentUserId else { return }
        Task {
            do {
                let favoriteQuotes = try await QuoteRepository.shared.fetchFavoriteQuotes(userId: userId)
                favoriteQuoteIds = Set(favoriteQuotes.map { $0.id })
                DispatchQueue.main.async {
                    self.tblQuotes.reloadData()
                }
            } catch {
                print("Failed to load favorites: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - UI & Utility Method(s)
extension HomeVC {
    
    func prepareUI() {
        // Setup navigation bar
        title = "Home"
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.prefersLargeTitles = false
        
        // Navigation bar filter button
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "line.3.horizontal.decrease.circle"),
            style: .plain,
            target: self,
            action: #selector(showCategoryFilter)
        )
        navigationItem.rightBarButtonItem?.tintColor = .systemTeal
        
        // Setup search bar
        searchBar.delegate = self
        searchBar.placeholder = "Search quotes or authors..."
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundImage = UIImage()
        searchBar.backgroundColor = .clear
        
        // Setup table view
        tblQuotes.contentInsetAdjustmentBehavior = .automatic
        tblQuotes.delegate = self
        tblQuotes.dataSource = self
        tblQuotes.register(UINib(nibName: "QuoteCell", bundle: nil), forCellReuseIdentifier: "QuoteCell")
        tblQuotes.rowHeight = UITableView.automaticDimension
        tblQuotes.estimatedRowHeight = 120
        tblQuotes.separatorStyle = .none
        tblQuotes.backgroundColor = .systemGroupedBackground
        activityIndicator.hidesWhenStopped = true
        
        // Pull to refresh
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = .systemTeal
        refreshControl.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
        tblQuotes.refreshControl = refreshControl
    }
    
    @objc func showCategoryFilter() {
        // Show loading indicator
        activityIndicator.startAnimating()
        
        Task {
            do {
                let categories = try await QuoteRepository.shared.fetchCategories()
                print("✅ Fetched \(categories.count) categories: \(categories.map { $0.name })")
                DispatchQueue.main.async { [weak self] in
                    self?.activityIndicator.stopAnimating()
                    if categories.isEmpty {
                        print("⚠️ Categories array is empty - check database and model")
                    }
                    self?.showCategoryPicker(categories: categories)
                }
            } catch {
                print("❌ Error fetching categories: \(error)")
                print("❌ Error details: \(error.localizedDescription)")
                DispatchQueue.main.async { [weak self] in
                    self?.activityIndicator.stopAnimating()
                    self?.alertView(message: "Failed to load categories: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func showCategoryPicker(categories: [Category]) {
        let alert = UIAlertController(title: "Filter by Category", message: nil, preferredStyle: .actionSheet)
        
        // Add "All Categories" option with checkmark if no category is selected
        let allCategoriesTitle = selectedCategoryId == nil ? "✓ All Categories" : "All Categories"
        alert.addAction(UIAlertAction(title: allCategoriesTitle, style: .default) { [weak self] _ in
            self?.selectedCategoryId = nil
            self?.fetchQuotes(reset: true)
        })
        
        // Add each category with checkmark if selected
        if categories.isEmpty {
            alert.message = "No categories available"
        } else {
            for category in categories {
                let isSelected = selectedCategoryId == category.id
                let categoryTitle = isSelected ? "✓ \(category.name)" : category.name
                alert.addAction(UIAlertAction(title: categoryTitle, style: .default) { [weak self] _ in
                    self?.selectedCategoryId = category.id
                    self?.fetchQuotes(reset: true)
                })
            }
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // Configure popover for iPad
        if let popover = alert.popoverPresentationController {
            popover.barButtonItem = navigationItem.rightBarButtonItem
            popover.permittedArrowDirections = [.up, .down]
        }
        
        present(alert, animated: true)
    }
    
    func fetchQuoteOfTheDay() {
        viewModel.fetchQuoteOfTheDay()
    }
    
    func fetchQuotes(reset: Bool) {
        if reset {
            quotes.removeAll()
            tblQuotes.reloadData()
        }
        // Only show activity indicator if we're resetting or if quotes list is empty
        if reset || quotes.isEmpty {
            activityIndicator.startAnimating()
        }
        viewModel.fetchQuotes(reset: reset, categoryId: selectedCategoryId, searchText: searchText, author: searchAuthor)
    }
    
    @objc func refreshTableView() {
        refreshControl.beginRefreshing()
        fetchQuoteOfTheDay()
        fetchQuotes(reset: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.refreshControl.endRefreshing()
        }
    }
    
    func toggleFavorite(quote: Quote, at indexPath: IndexPath) {
        guard let userId = currentUserId else {
            alertView(message: "Please login to add favorites")
            return
        }
        
        let isFavorite = favoriteQuoteIds.contains(quote.id)
        
        Task {
            do {
                if isFavorite {
                    try await QuoteRepository.shared.removeFavorite(userId: userId, quoteId: quote.id)
                    favoriteQuoteIds.remove(quote.id)
                } else {
                    try await QuoteRepository.shared.addFavorite(userId: userId, quoteId: quote.id)
                    favoriteQuoteIds.insert(quote.id)
                }
                
                DispatchQueue.main.async {
                    self.tblQuotes.reloadRows(at: [indexPath], with: .none)
                }
            } catch {
                DispatchQueue.main.async {
                    self.alertView(message: "Failed to update favorite: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func shareQuote(_ quote: Quote) {
        let alert = UIAlertController(title: "Share Quote", message: "Choose sharing option", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Share as Text", style: .default) { [weak self] _ in
            self?.shareAsText(quote)
        })
        
        alert.addAction(UIAlertAction(title: "Share as Card - Minimal", style: .default) { [weak self] _ in
            self?.shareAsCard(quote, style: .minimal)
        })
        
        alert.addAction(UIAlertAction(title: "Share as Card - Gradient", style: .default) { [weak self] _ in
            self?.shareAsCard(quote, style: .gradient)
        })
        
        alert.addAction(UIAlertAction(title: "Share as Card - Elegant", style: .default) { [weak self] _ in
            self?.shareAsCard(quote, style: .elegant)
        })
        
        alert.addAction(UIAlertAction(title: "Save Card to Photos", style: .default) { [weak self] _ in
            self?.saveCardToPhotos(quote)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        present(alert, animated: true)
    }
    
    func shareAsText(_ quote: Quote) {
        let text = "\"\(quote.text)\" - \(quote.author)"
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        present(activityVC, animated: true)
    }
    
    func shareAsCard(_ quote: Quote, style: QuoteCardStyle) {
        guard let cardImage = QuoteCardGenerator.generateCard(quote: quote, style: style) else {
            alertView(message: "Failed to generate quote card")
            return
        }
        
        let activityVC = UIActivityViewController(activityItems: [cardImage], applicationActivities: nil)
        
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        present(activityVC, animated: true)
    }
    
    func saveCardToPhotos(_ quote: Quote) {
        let alert = UIAlertController(title: "Select Style", message: "Choose card style to save", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Minimal", style: .default) { [weak self] _ in
            self?.saveCard(quote, style: .minimal)
        })
        
        alert.addAction(UIAlertAction(title: "Gradient", style: .default) { [weak self] _ in
            self?.saveCard(quote, style: .gradient)
        })
        
        alert.addAction(UIAlertAction(title: "Elegant", style: .default) { [weak self] _ in
            self?.saveCard(quote, style: .elegant)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        present(alert, animated: true)
    }
    
    func saveCard(_ quote: Quote, style: QuoteCardStyle) {
        guard let cardImage = QuoteCardGenerator.generateCard(quote: quote, style: style) else {
            alertView(message: "Failed to generate quote card")
            return
        }
        
        QuoteCardGenerator.saveToPhotos(image: cardImage)
        alertView(message: "Quote card saved to Photos!")
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension HomeVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return quoteOfTheDay != nil ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 && quoteOfTheDay != nil {
            return 1 // Quote of the Day
        }
        return quotes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 && quoteOfTheDay != nil {
            // Quote of the Day cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "QuoteCell", for: indexPath) as! QuoteCell
            if let quote = quoteOfTheDay {
                let isFavorite = favoriteQuoteIds.contains(quote.id)
                cell.configure(quote: quote, isFavorite: isFavorite)
                
                // Apply accent color to Quote of the Day background
                let accentColor = SettingsManager.shared.getAccentColor()
                cell.viewContainer.backgroundColor = accentColor.withAlphaComponent(0.1)
                
                // Apply font size (slightly larger for Quote of the Day)
                let fontSize = SettingsManager.shared.getFontSize()
                cell.lblQuote.font = UIFont.systemFont(ofSize: fontSize + 2, weight: .semibold)
                
                cell.onFavoriteTapped = { [weak self] in
                    self?.toggleFavorite(quote: quote, at: indexPath)
                }
                
                cell.onShareTapped = { [weak self] in
                    self?.shareQuote(quote)
                }
            }
            return cell
        }
        
        // Regular quote cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuoteCell", for: indexPath) as! QuoteCell
        let quote = quotes[indexPath.row]
        let isFavorite = favoriteQuoteIds.contains(quote.id)
        cell.configure(quote: quote, isFavorite: isFavorite)
        // Ensure background is adaptive for dark mode
        cell.viewContainer.backgroundColor = .systemBackground
        
        cell.onFavoriteTapped = { [weak self] in
            self?.toggleFavorite(quote: quote, at: indexPath)
        }
        
        cell.onShareTapped = { [weak self] in
            self?.shareQuote(quote)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 && quoteOfTheDay != nil {
            return "Quote of the Day"
        }
        return quotes.isEmpty ? nil : "All Quotes"
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Load more when scrolling near bottom
        if indexPath.section == (quoteOfTheDay != nil ? 1 : 0) && indexPath.row == quotes.count - 5 {
            fetchQuotes(reset: false)
        }
    }
}

// MARK: - HomeViewModelDelegate
extension HomeVC: HomeViewModelDelegate {
    func quotesFetched(_ newQuotes: [Quote]) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            // Always stop activity indicator when quotes are fetched (even if empty)
            self.activityIndicator.stopAnimating()
            self.quotes.append(contentsOf: newQuotes)
            self.tblQuotes.reloadData()
        }
    }
    
    func quoteOfTheDayFetched(_ quote: Quote?) {
        DispatchQueue.main.async { [weak self] in
            self?.quoteOfTheDay = quote
            self?.tblQuotes.reloadData()
        }
    }
    
    func errorOccurred(_ message: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            // Always stop activity indicator on error
            self.activityIndicator.stopAnimating()
            // Only show error for critical failures (like fetching quotes list)
            // Quote of the day errors are handled silently
            if !message.contains("quote of the day") {
                self.alertView(message: message)
            } else {
                print("⚠️ \(message)")
            }
        }
    }
}

// MARK: - UISearchBarDelegate
extension HomeVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        let searchTerm = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Clear previous search
        searchText = nil
        searchAuthor = nil
        
        // If search term exists, search in both quote text and author
        if let term = searchTerm, !term.isEmpty {
            // Search in both text and author fields
            searchText = term
            searchAuthor = term
        }
        
        fetchQuotes(reset: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
        searchText = nil
        searchAuthor = nil
        fetchQuotes(reset: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Use debouncing for real-time search (optional - can be removed if not needed)
        // For now, only clear when empty
        if searchText.isEmpty {
            self.searchText = nil
            self.searchAuthor = nil
            fetchQuotes(reset: true)
        }
    }
}
