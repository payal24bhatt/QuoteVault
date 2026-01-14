//
//  CryptoHelper.swift
//  
//
//  Created by Payal Bhatt on 10/11/25.
//

import Foundation
import CryptoKit


struct CryptoHelper {
    static func sha256String(_ input: String) -> String {
        let data = Data(input.utf8)
        let hashed = SHA256.hash(data: data)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
}
