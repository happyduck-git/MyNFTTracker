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
    private let firestoreManager = FirestoreManager.shared
    
    let walletAddres: String
    var selectedAvatarIndex: IndexPath?
    @Published var nickname: String = ""
    @Published var isNicknameFilled: Bool = false
    @Published var appTheme: Theme = .black
    @Published var profileImage: UIImage?
    @Published var showPickerView: Bool?
    @Published var canShowPickerView: Bool = true
    
    init(walletAddres: String) {
        self.walletAddres = walletAddres
        self.retrieveTheme()
        
        Task {
            self.profileImage = await fetchRandomAvatar(AvatarConstants.avatarList.randomElement() ?? "Chloe")
        }
    }
    
}

extension RegisterViewViewModel {
    func saveUserInfoOnFirestore(of wallet: String, username: String, imageUrl: String) async {
        do {
            try await firestoreManager.saveUserInfo(of: wallet, imageUrl: imageUrl, nickname: username)
        }
        catch {
            AppLogger.logger.error("Error saving user info -- \(error)")
        }
    }
    
    func saveAddressAndChainIdOnUserDefaults(address: String?, chainId: String) {
        UserDefaults.standard.set(address, forKey: UserDefaultsConstants.walletAddress)
        UserDefaults.standard.set(chainId, forKey: UserDefaultsConstants.chainId)
        #if DEBUG
        AppLogger.logger.log("Wallet address saved to UserDefaults -- \(String(describing: address))\n and Chain Id -- \(String(describing: chainId))")
        #endif
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
