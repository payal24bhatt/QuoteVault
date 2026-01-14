//
//  AppImages.swift
//  
//
//  Created by Payal Bhatt on 10/11/25.
//

import Foundation
import UIKit

enum AppImages: String {
    case hidePassword = "ic_hide_password"
    case showPassword = "ic_showpassword"
    case profileMask = "img_profile_mask"
    case placeholder = "img_placeholder"
    case emptyList = "ic_emptylist"
}

extension UIImage {
    convenience init?(appImage: AppImages) {
        self.init(named: appImage.rawValue)
    }
}
