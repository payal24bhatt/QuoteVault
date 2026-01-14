//
//  NetworkManager.swift
//  
//
//  Created by Payal Bhatt on 10/11/25.
//

import Foundation

final class NetworkManager {
    static let shared = NetworkManager()
    private init() {}

    func fetchUsers(results: Int = 5000, completion: @escaping (Swift.Result<[Result], Error>) -> Void) {
        let urlStr = "https://randomuser.me/api/?results=\(results)"
        guard let url = URL(string: urlStr) else {
            completion(.failure(NSError(domain: "bad url", code: -1, userInfo: nil)))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, err in
            if let err = err {
                completion(.failure(err))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "nodata", code: -1, userInfo: nil)))
                return
            }
            
            do {
                let response = try JSONDecoder().decode(Welcome.self, from: data)
                completion(.success(response.results))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
