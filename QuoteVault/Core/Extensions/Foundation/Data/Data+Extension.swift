//
//  Data+Extension.swift
//

import Foundation

extension Data {

    func decoded<T: Decodable>() throws -> T {
        return try JSONDecoder().decode(T.self,from:self)
    }

    var formattedLength: String {
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useAll]
        bcf.countStyle = .file
        return bcf.string(fromByteCount: Int64(self.count))
    }

    func toString() -> String {
        return String(data: self, encoding: .utf8)!
    }
}
