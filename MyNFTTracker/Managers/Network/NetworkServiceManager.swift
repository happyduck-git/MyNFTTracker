//
//  NetworkServiceManager.swift
//  MyNFTTracker
//
//  Created by HappyDuck on 11/7/23.
//

import Foundation

final actor NetworkServiceManager {
    static func execute<T: Decodable>(expecting type: T.Type,
                                      request: URLRequest) async throws -> T {
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
            throw URLError(.cannotParseResponse)
        }
        if 200..<300 ~= statusCode {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(type.self, from: data)
        } else {
            AppLogger.logger.error("Bad status code: \(String(describing: statusCode))")
            throw URLError(.badServerResponse)
        }
        
    }
    
    enum NetworkServiceError: Error {
        case dataError
    }
}
