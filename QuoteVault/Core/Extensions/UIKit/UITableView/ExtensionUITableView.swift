//
//  ExtensionUITableView.swift
//

import Foundation
import UIKit

extension UITableView {

    private enum FooterType: Int {
        case loadingMore = 1234567890
    }

    func enableNoDataView(message: String) {

        if let noDataView = NoDataView.viewFromXib as? NoDataView {

            noDataView.frame = self.frame
            noDataView.lblMessage.text = message

            backgroundView = noDataView
        }
    }

    func disableNoDataView() {

        if backgroundView != nil {
            backgroundView = nil
        }
    }

    /// It will show the loading indicator while fetching the new data.
    /// - Parameters:
    ///   - color: A UIColor Value that indicates the Color of UIActivityIndicatorView.

    func addLoadMoreIndicator(
        color: UIColor = .black,
        style: UIActivityIndicatorView.Style = UIActivityIndicatorView.Style.medium
    ) {

        let footerView = UIView(frame: CGRect(
            x: 0.0,
            y: 0.0,
            width: UIDevice.screenWidth,
            height: 40.0)
        )

        footerView.tag = FooterType.loadingMore.rawValue

        let activityIndicator = UIActivityIndicatorView(style: style)
        activityIndicator.startAnimating()
        activityIndicator.color = color
        activityIndicator.frame = footerView.frame
        footerView.addSubview(activityIndicator)

        tableFooterView = footerView
    }

    /// This method will remove the loading indicator if added in the tableFooterView.
    func removeLoadMoreIndicator() {

        if (tableFooterView != nil),
            (tableFooterView?.tag == FooterType.loadingMore.rawValue) {
            tableFooterView = nil
        }
    }

    func lastIndexPath() -> IndexPath? {

        let sections = self.numberOfSections

        if (sections <= 0) {
            return nil
        }

        let rows = self.numberOfRows(inSection: sections-1)

        if (rows <= 0) {
            return nil
        }

        return IndexPath(row: rows-1, section: sections-1)
    }

    @MainActor
    func scrollToBottom() {
        DispatchQueue.main.async {
            let section = 0
            let rowCount = self.numberOfRows(inSection: section)
            guard rowCount > 0 else { return }

            let indexPath = IndexPath(row: rowCount - 1, section: section)
            self.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }

}

extension UITableView {
    func isValid(indexPath: IndexPath) -> Bool {
        return indexPath.section < numberOfSections &&
               indexPath.row < numberOfRows(inSection: indexPath.section)
    }
}
