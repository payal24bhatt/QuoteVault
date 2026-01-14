//
//  URL+Extension.swift
//

import Foundation
import UIKit

extension URL {

    func canOpen() -> Bool {
        return Constants.sharedApplication.canOpenURL(self)
    }

    func open() {
        Constants.sharedApplication.open(self, options: [:], completionHandler: nil)
    }
}

extension URL {

    enum FileExtension: String {
        case jpg = "jpg"
        case jpeg = "jpeg"
        case png = "png"
        case gif = "gif"
        case heic = "heic"
        case unsupported
    }

    func getFileExtension() -> FileExtension {

        let lowercasedAbsoluteString = self.absoluteString.lowercased()
        if lowercasedAbsoluteString.hasSuffix("jpg") {
            return .jpg
        } else if lowercasedAbsoluteString.hasSuffix("jpeg") {
            return .jpeg
        } else if lowercasedAbsoluteString.hasSuffix("png") {
            return .png
        } else if lowercasedAbsoluteString.hasSuffix("gif") {
            return .gif
        } else if lowercasedAbsoluteString.hasSuffix("heic") {
            return .heic
        } else {
            return .unsupported
        }
    }
}

extension URL {

    /// A Computed Property (only getter) of URL For getting the String value from URL.
    /// This Computed Property (only getter) returns String? , it means this Computed Property (only getter) return nil value also , while using this Computed Property (only getter) please use if let.
    /// If you are not using if let and if this Computed Property (only getter) returns nil and when you are trying to unwrapped this value("String!") then application will crash.
    var toString: String? {
        return self.absoluteString
    }
}
