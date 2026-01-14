//
//  Optional+Extension.swift
//

import Foundation

extension Optional where Wrapped == String {

    func isEmptyOrNil() -> Bool {
        guard let strongSelf = self else {
            return true
        }
        return strongSelf.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? true : false
    }
}
