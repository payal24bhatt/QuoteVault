//
//  QuoteCell.swift
//  QuoteVault
//
//  Created by Payal Bhatt on 13/01/26.
//

import UIKit

class QuoteCell: UITableViewCell {
    
    @IBOutlet weak var lblQuote: UILabel!
    @IBOutlet weak var lblAuthor: UILabel!
    @IBOutlet weak var btnFavorite: UIButton!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var viewContainer: UIView!
    
    var onFavoriteTapped: (() -> Void)?
    var onShareTapped: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    func setupUI() {
        viewContainer.layer.cornerRadius = 12
        viewContainer.layer.shadowColor = UIColor.black.cgColor
        viewContainer.layer.shadowOffset = CGSize(width: 0, height: 2)
        viewContainer.layer.shadowOpacity = 0.1
        viewContainer.layer.shadowRadius = 4
        
        // Use adaptive colors that work in both light and dark mode
        viewContainer.backgroundColor = .systemBackground
        
        lblQuote.numberOfLines = 0
        lblQuote.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        lblQuote.textColor = .label // Adaptive color for light/dark mode
        lblAuthor.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        lblAuthor.textColor = .secondaryLabel // Adaptive color for light/dark mode
        
        btnFavorite.setImage(UIImage(systemName: "heart"), for: .normal)
        btnFavorite.setImage(UIImage(systemName: "heart.fill"), for: .selected)
    }
    
    func configure(quote: Quote, isFavorite: Bool) {
        lblQuote.text = quote.text
        lblAuthor.text = "- \(quote.author)"
        btnFavorite.isSelected = isFavorite
        
        // Ensure adaptive colors are set (important for dark mode)
        lblQuote.textColor = .label
        lblAuthor.textColor = .secondaryLabel
        viewContainer.backgroundColor = .systemBackground
        
        // Apply user's font size preference
        let fontSize = SettingsManager.shared.getFontSize()
        lblQuote.font = UIFont.systemFont(ofSize: fontSize, weight: .regular)
        
        // Apply user's accent color preference
        let accentColor = SettingsManager.shared.getAccentColor()
        btnFavorite.tintColor = accentColor
        btnShare.tintColor = accentColor
    }
    
    @IBAction func favoriteButtonTapped(_ sender: UIButton) {
        onFavoriteTapped?()
    }
    
    @IBAction func shareButtonTapped(_ sender: UIButton) {
        onShareTapped?()
    }
}
