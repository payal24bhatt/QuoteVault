//
//  UITableView+Extension.swift
//

import Foundation
import UIKit

extension UITableView {

    /**
     Register nibs faster by passing the type - if for some reason the `identifier` is different then it can be passed
     - Parameter type: UITableViewCell.Type
     - Parameter identifier: String?
     */
    func registerCell(type: UITableViewCell.Type, identifier: String? = nil) {
        let cellId = String(describing: type)
        register(UINib(nibName: cellId, bundle: nil), forCellReuseIdentifier: identifier ?? cellId)
    }
    
    
    func registerCells(cellTypes: [UITableViewCell.Type]) {
           for cellType in cellTypes {
               let cellId = String(describing: cellType)
               register(UINib(nibName: cellId, bundle: nil), forCellReuseIdentifier: cellId)
           }
       }
    
    func registerHeaderFooterCell(type: UITableViewHeaderFooterView.Type, identifier: String? = nil) {
        let headerId = String(describing: type)
        register(UINib(nibName: headerId, bundle: nil), forHeaderFooterViewReuseIdentifier: identifier ?? headerId)
    }

    func automaticHeaderViewSize() {

        if let headerView = self.tableHeaderView {

            headerView.setNeedsLayout()
            headerView.layoutIfNeeded()

            let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            var headerFrame = headerView.frame

            // Comparison necessary to avoid infinite loop
            if (height != headerFrame.size.height) {
                headerFrame.size.height = height
                headerView.frame = headerFrame
                self.tableHeaderView = headerView
            }
            self.tableHeaderView = headerView
        }
    }

    func performUpdate(_ update: () -> Void, completion: (() -> Void)?) {
        if #available(iOS 11.0, *) {
            performBatchUpdates({
                update()
            }) { (isCompleted) in
                if !(isCompleted) { return }
                if let blk = completion { blk() }
            }
        } else {
            CATransaction.begin()
            CATransaction.setCompletionBlock(completion)

            beginUpdates()
            update()
            endUpdates()

            CATransaction.commit()
        }
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

    public func relayoutTableHeaderView() {

        if let tableHeaderView = tableHeaderView {
            let labels = tableHeaderView.findViewsOfClass(viewClass: UILabel.self)
            for label in labels {
                label.preferredMaxLayoutWidth = label.frame.width
            }
            tableHeaderView.setNeedsLayout()
            tableHeaderView.layoutIfNeeded()

            let height = tableHeaderView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            var headerFrame = tableHeaderView.frame

            if height != headerFrame.size.height {
                headerFrame.size.height = height
                tableHeaderView.frame = headerFrame
                self.tableHeaderView = tableHeaderView
            }
            self.tableHeaderView = tableHeaderView
        }
    }

    func activityLoader() {

        let spinner = UIActivityIndicatorView()
        spinner.startAnimating()
        spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: self.bounds.width, height: CGFloat(44))
        spinner.color = .blue
        self.tableFooterView = spinner
        self.tableFooterView?.isHidden = false
    }
}
