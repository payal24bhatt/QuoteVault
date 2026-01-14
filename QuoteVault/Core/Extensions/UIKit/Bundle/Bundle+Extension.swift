import Foundation
import UIKit

/// While using these below properties, please use if let. If you are not using if let and if this returns nil and when you are trying to unwrapped this value then application will crash.

extension Bundle {

    static var MainBundle: Bundle {
        return Bundle.main
    }

    static var BundleIdentifier: String? {
        return MainBundle.bundleIdentifier
    }

    static var BundleInfoDictionary: [String: Any]? {
        return MainBundle.infoDictionary
    }

    static var VersionNumber: String? {
        return BundleInfoDictionary?.valueForString(key: "CFBundleShortVersionString")
    }

    static var BuildNumber: String? {
        return BundleInfoDictionary?.valueForString(key: "CFBundleVersion")
    }

    static var ApplicationName: String? {
        return BundleInfoDictionary?.valueForString(key: "CFBundleDisplayName")
    }

    static func loadView<T>(fromNib name: String, withType type: T.Type) -> T {
        if let view = Bundle.main.loadNibNamed(name, owner: nil, options: nil)?.first as? T {
            return view
        }

        fatalError("Could not load view with type " + String(describing: type))
    }

}
