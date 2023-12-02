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
    
    private let baseUrl = "https://api.dicebear.com/7.x/lorelei/png?seed=%@"
    
    enum AvatarServiceError: Error {
        case invalidUrl
    }
    
}

extension AvatarServiceManager {
    
    func retrieveMultipleAvatar(_ nameList: [String]) async throws -> [UIImage?] {
        
        try await withThrowingTaskGroup(of: UIImage?.self) { [weak self] group in
            guard let `self` = self else { return [] }
            for name in nameList {
                group.addTask {
                    try await self.retrieveSingleAvatar(name)
                }
            }
            
            var images: [UIImage?] = []
            for try await image in group {
                images.append(image)
            }
            return images
        }
    }
    
    func retrieveSingleAvatar(_ name: String) async throws -> UIImage? {
        let urlString = String(format: baseUrl, name)
        guard let url = URL(string: urlString) else {
            throw AvatarServiceError.invalidUrl
        }
        return try await ImagePipeline.shared.image(for: url)
    }
}
