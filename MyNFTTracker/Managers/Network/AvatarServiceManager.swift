//
//  AvatarServiceManager.swift
//  MyNFTTracker
//
//  Created by HappyDuck on 12/1/23.
//

import Foundation
import UIKit.UIImage
import Nuke

final actor AvatarServiceManager {
    
    static let shared = AvatarServiceManager()
    private init() {}
    
    private let cacheManager = AvatarCacheManager.shared
    private let baseUrl = "https://api.dicebear.com/7.x/lorelei/png?seed=%@"
    
    enum AvatarServiceError: Error {
        case invalidUrl
    }
    
}

extension AvatarServiceManager {
    
    struct ImageResult {
        let name: String
        let image: UIImage?
    }
    
    func retrieveMultipleAvatar(_ nameList: [String]) async throws -> [String: UIImage?] {
        
        try await withThrowingTaskGroup(of: ImageResult.self) { [weak self] group in
            guard let `self` = self else { return [:] }
            for name in nameList {
                group.addTask {
                    ImageResult(name: name,
                                image: try await self.retrieveSingleAvatar(name))
                }
            }
            
            var result: [String: UIImage?] = [:]
            for try await value in group {
                result[value.name] = value.image
            }
            return result
        }
    }
    
    func retrieveSingleAvatar(_ name: String) async throws -> UIImage? {
        let urlString = String(format: baseUrl, name)
        guard let url = URL(string: urlString) else {
            throw AvatarServiceError.invalidUrl
        }
        
        if let data = self.cacheManager.cachedResponse(for: url) {
            return UIImage(data: data)
        }
        
        let image = try await ImagePipeline.shared.image(for: url)
        self.cacheManager.setCache(for: url, data: image.pngData())
        return image
    }
}
