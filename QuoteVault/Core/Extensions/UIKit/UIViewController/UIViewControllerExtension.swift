//
//  UIViewControllerExtension.swift
//

import Foundation
import UIKit
import AVFoundation
import MessageUI

typealias AlertActionHandler = ((UIAlertAction) -> Void)?
typealias AlertTextFieldHandler = ((UITextField) -> Void)

typealias PopUpCompletionHandler = (() -> Void)

extension UIViewController {

    private struct AssociatedObjectKeyForPopUp {
        static var popUpOverlay = "popUpOverlay"
    }

    var popUpOverlay: PopUpOverlay? {
        if let popUpOverlay = objc_getAssociatedObject(self, &AssociatedObjectKeyForPopUp.popUpOverlay) as? PopUpOverlay {
            return popUpOverlay
        } else {
            guard let popUpOverlay = PopUpOverlay.shared else { return nil }
            popUpOverlay.imgVBlur.frame = UIDevice.mainScreen.bounds

            objc_setAssociatedObject(self, &AssociatedObjectKeyForPopUp.popUpOverlay, popUpOverlay, .OBJC_ASSOCIATION_RETAIN)
            return popUpOverlay
        }
    }

    func presentPopUp(view: UIView, shouldOutSideClick: Bool, isBlurOverlay: Bool, type: PopUpOverlay.PopUpPresentType, completionHandler: PopUpCompletionHandler?) {

        guard let popUpOverlay = self.popUpOverlay else { return }
        var blurImage: UIImage?

        if (isBlurOverlay) {

            if (self.navigationController != nil) {
                blurImage = self.navigationController?.view.snapshotImage?.blurImage(radius: 5.0)
                self.navigationController?.view.addSubview(popUpOverlay)
            } else {
                blurImage = self.view.snapshotImage?.blurImage(radius: 5.0)
                self.view.addSubview(popUpOverlay)
            }
            popUpOverlay.imgVBlur.image = blurImage

        } else {

            if (self.navigationController != nil) {
                self.navigationController?.view.addSubview(popUpOverlay)
            } else {
                self.view.addSubview(popUpOverlay)
            }
        }

        popUpOverlay.shouldOutSideClick = shouldOutSideClick
        popUpOverlay.type = type
        popUpOverlay.addSubview(view)

        popUpOverlay.presentPopUpOverlayView(view: view, completionHandler: completionHandler)
    }

    func dismissPopUp(view: UIView, completionHandler: PopUpCompletionHandler?) {
        guard let popUpOverlay = self.popUpOverlay else { return }
        popUpOverlay.dismissPopUpOverlayView(view: view, completionHandler: completionHandler)
    }
}

typealias BlockHandler = ((_ data: Any?, _ error: String?) -> Void)

// MARK: - Extension of UIViewController set the Block and getting back with some data(Any Type of Data) AND error message(String). -

extension UIViewController {

    /// This Private Structure is used to create all AssociatedObjectKey which will be used within this extension.
    private struct BlockKey {
        static var blockHandler = "blockHandler"
    }

    /// A Computed Property (only getter) of blockHandler(data , error) , Both data AND error are optional so you can pass nil if you don't want to share anything. This Computed Property is optional , it might be return nil so please use if let OR guard let.
    var block: BlockHandler? {
        guard let block = objc_getAssociatedObject(self, &BlockKey.blockHandler) as? BlockHandler else { return nil }
        return block
    }

    /// This method is used to set the block on CurrentController for getting back with some data(Any Type of Data) AND error message(String).
    ///
    /// - Parameter block: This block contain data(Any Type of Data) AND error message(String) to let you help in CurrentController. Both data AND error might be nil , in this case to prevent the crash please use if let OR guard let.
    func setBlock(block: @escaping BlockHandler) {
        objc_setAssociatedObject(self, &BlockKey.blockHandler, block, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

// MARK: - Extension of UIViewController. -

extension UIViewController {

    /// This static method is used for initialize the UIViewController with nibName AND bundle.
    /// - Returns: This Method returns instance of UIViewController.
    static func initWithNibName() -> Self {
        return self.init(nibName: "\(self)", bundle: nil)
    }

    var isVisible: Bool {
        return self.isViewLoaded && (self.view.window != nil)
    }

    var isPresentted: Bool {
        return self.isBeingPresented || self.isMovingToParent
    }

    var isDismissed: Bool {
        return self.isBeingDismissed || self.isMovingFromParent
    }
}

extension UIViewController {

    func openInSafari(strUrl: String) {

        if let url = strUrl.toURL {

            if Constants.sharedApplication.canOpenURL(url) {
                Constants.sharedApplication.open(url, options: [:], completionHandler: nil)
            }

        } else {
            print("Master Log ::--> Unable to Convert the String to URL")
        }
    }
}

extension UIViewController : MFMailComposeViewControllerDelegate {

    func openMailComposer(subject: String, toRecipients: [String]?, ccRecipients: [String]?, bccRecipients: [String]?, body: String, isHTML: Bool) {

        let mfMailComposeViewController = MFMailComposeViewController()
        mfMailComposeViewController.mailComposeDelegate = self

        mfMailComposeViewController.setSubject(subject)
        mfMailComposeViewController.setToRecipients(toRecipients)
        mfMailComposeViewController.setCcRecipients(ccRecipients)
        mfMailComposeViewController.setBccRecipients(bccRecipients)
        mfMailComposeViewController.setMessageBody(body, isHTML: isHTML)

        if MFMailComposeViewController.canSendMail() {
            self.present(mfMailComposeViewController, animated: true, completion: nil)
        } else if let emailUrl = self.createEmailUrl(
            to: toRecipients?.first ?? "",
            subject: subject,
            body: body) {
            // Show third party email composer if default Mail app is not present
            UIApplication.shared.open(emailUrl)
        } else {
            self.alertView(message: "The device is not configured for sending email, Go to Settings > Mail")
        }
    }

    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    /// createEmailUrl is used to create mail url
    /// - Parameters:
    ///   - to: String, email id of to
    ///   - subject: String, subject of mail
    ///   - body: String, body text of mail
    /// - Returns: URL optional, return optional URL with email, subject and body
    private func createEmailUrl(
        to: String,
        subject: String,
        body: String) -> URL? {
            let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            let bodyEncoded = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            
            let gmailUrl = URL(string: "googlegmail://co?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
            let outlookUrl = URL(string: "ms-outlook://compose?to=\(to)&subject=\(subjectEncoded)")
            let yahooMail = URL(string: "ymail://mail/compose?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
            let sparkUrl = URL(string: "readdle-spark://compose?recipient=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
            let defaultUrl = URL(string: "mailto:\(to)?subject=\(subjectEncoded)&body=\(bodyEncoded)")
            
            if let gmailUrl = gmailUrl, UIApplication.shared.canOpenURL(gmailUrl) {
                return gmailUrl
            } else if let outlookUrl = outlookUrl, UIApplication.shared.canOpenURL(outlookUrl) {
                return outlookUrl
            } else if let yahooMail = yahooMail, UIApplication.shared.canOpenURL(yahooMail) {
                return yahooMail
            } else if let sparkUrl = sparkUrl, UIApplication.shared.canOpenURL(sparkUrl) {
                return sparkUrl
            }
            return defaultUrl
        }
}

// MARK: - --------------- Document Directory
extension UIViewController {
    func applicationDocumentsDirectory() -> String? {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let basePath = paths.count > 0 ? paths[0] : nil
        return basePath
    }

    func checkfileExistInDocumentDirectory(_ filePath: String?) -> Bool {
        let fileManager = FileManager()
        return fileManager.fileExists(atPath: filePath!)
    }

    func removeFileAtPathFromDocumentDirectory(_ outputPath : String?) {
        let fileManager = FileManager()

        if (fileManager.fileExists(atPath: outputPath!)) {

            if (fileManager.isDeletableFile(atPath: outputPath!)) {
                do {
                    try fileManager.removeItem(atPath: outputPath!)
                } catch let error as NSError {
                    print("Ooops! Something went wrong: \(error)")
                }

            }
        }
    }
}

// This extension for load viewcontroller from xib
extension UIViewController {
    static func loadFromNib() -> Self {
        func instantiateFromNib<T: UIViewController>() -> T {
            return T.init(nibName: String(describing: T.self), bundle: nil)
        }
        
        return instantiateFromNib()
    }
}
