//
//  RegisterViewViewModel.swift
//  MyNFTTracker
//
//  Created by HappyDuck on 12/1/23.
//

import Foundation
import UIKit.UIImage
import Combine

final class RegisterViewViewModel {
        
    private let avatarManager = AvatarServiceManager.shared
    
    let walletAddres: String
    @Published var nickname: String = ""
    @Published var isNicknameFilled: Bool = false
    @Published var appTheme: Theme = .black
    @Published var profileImage: UIImage?
    
    init(walletAddres: String) {
        self.walletAddres = walletAddres
        self.retrieveTheme()
        
        Task {
            self.profileImage = await fetchRandomAvatar(AvatarConstants.avatarList.randomElement() ?? "Chloe")
        }
    }
    
}

extension RegisterViewViewModel {
    private func fetchRandomAvatar(_ name: String) async -> UIImage? {
        do {
            return try await self.avatarManager.retrieveSingleAvatar(name)
        }
        catch {
            AppLogger.logger.error("Error fetching a single avatar -- \(error)")
            return nil
        }
    }
}

extension RegisterViewViewModel {
    private func retrieveTheme() {
        guard let themeString = UserDefaults.standard.string(forKey: UserDefaultsConstants.theme),
              let theme = Theme(rawValue: themeString)
        else {
            self.appTheme = .black
            return
        }
        
        self.appTheme = theme
    }
}
