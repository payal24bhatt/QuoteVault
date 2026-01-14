//
//  ExtensionUICollectionView.swift
//

import Foundation
import UIKit

extension UICollectionView {
    
    func registerCell(type: UICollectionViewCell.Type, identifier: String? = nil) {
        let cellId = String(describing: type)
        register(UINib(nibName: cellId, bundle: nil), forCellWithReuseIdentifier: identifier ?? cellId)
    }
    
    /// Register multiple cells at once
    /// - Parameter types: Array of UICollectionViewCell types to be registered
    func registerCells(types: [UICollectionViewCell.Type]) {
        types.forEach { type in
            let cellId = String(describing: type)
            register(UINib(nibName: cellId, bundle: nil), forCellWithReuseIdentifier: cellId)
        }
    }
    
    func setEmptyCoverImage(
        image: UIImage? = UIImage(appImage: .placeholder),
        shadowImage: UIImage? = UIImage(appImage: .profileMask)
    ) {
        let backgroundView = UIView()
        self.backgroundView = backgroundView

        // Main Cover Image
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false

        // Shadow Image (on top of main image)
        let shadowImageView = UIImageView(image: shadowImage)
        shadowImageView.contentMode = .scaleAspectFill
        shadowImageView.translatesAutoresizingMaskIntoConstraints = false

        backgroundView.addSubview(imageView)
        backgroundView.addSubview(shadowImageView)

        NSLayoutConstraint.activate([
            // Main image fills background
            imageView.topAnchor.constraint(equalTo: backgroundView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor),

            // Shadow image also fills same space (overlay)
            shadowImageView.topAnchor.constraint(equalTo: backgroundView.topAnchor),
            shadowImageView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor),
            shadowImageView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor),
            shadowImageView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor)
        ])
    }

    func setEmptyMessage(image: UIImage? = UIImage(appImage: .emptyList), title: String, subtitle: String,topOffset: CGFloat? = nil) {
        let backgroundView = UIView()
        self.backgroundView = backgroundView

        // Image View
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false

        // Title Label
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.custom(name: .futuraMedium, size: 20)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Subtitle Label
        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = UIFont.custom(name: .futuraRegular, size: 12)
        subtitleLabel.textColor = .gray
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Stack View for Vertical Layout
        let stackView = UIStackView(arrangedSubviews: [imageView, titleLabel, subtitleLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false

        backgroundView.addSubview(stackView)

        // Common constraints
        var constraints: [NSLayoutConstraint] = [
            stackView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: backgroundView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: backgroundView.trailingAnchor, constant: -20),

            imageView.heightAnchor.constraint(equalToConstant: 80),
            imageView.widthAnchor.constraint(equalToConstant: 80)
        ]

        // Conditional top or centerY constraint
        if let topOffset = topOffset {
            constraints.append(stackView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: topOffset))
        } else {
            constraints.append(stackView.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor))
        }

        NSLayoutConstraint.activate(constraints)
    }

    func restore() {
        self.backgroundView = nil
    }
}
