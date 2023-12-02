//
//  AvatarCollectionViewViewModel.swift
//  MyNFTTracker
//
//  Created by HappyDuck on 12/1/23.
//

import Foundation
import UIKit.UIImage
import Combine

final class AvatarCollectionViewViewModel {
    
    private let avatarManager = AvatarServiceManager.shared
    
    @Published var avatarImages: [UIImage?] = []
    var selectedCell = 0
    var cellStatus: [Bool] = []
    
    init() {
        Task {
            do {
                avatarImages = try await self.retrieveAvatarImages(AvatarConstants.avatarList)
            }
            catch {
                AppLogger.logger.error("Error fetching multiple avatar -- \(error)")
            }
        }
    }
}

extension AvatarCollectionViewViewModel {
    
    func retrieveAvatarImages(_ nameList: [String]) async throws -> [UIImage?] {
        return try await self.avatarManager.retrieveMultipleAvatar(nameList)
    }
}
