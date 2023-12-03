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
    var selectedCell: IndexPath?
    var cellStatus: [Bool] = []
    
    init(selectedCell: IndexPath?) {
        self.selectedCell = selectedCell
        
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
        let imageResult = try await self.avatarManager.retrieveMultipleAvatar(nameList)
        return self.sortDictionay(imageResult)
    }
    
    func sortDictionay(_ dictionary: [String: UIImage?]) -> [UIImage?] {
        let sortedKeys = dictionary.keys.sorted()

        var images: [UIImage?] = []
        for key in sortedKeys {
            guard let image = dictionary[key] else { continue }
            images.append(image)
        }
        return images
    }

}
