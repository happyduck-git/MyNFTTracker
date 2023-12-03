//
//  SettingsViewViewModel.swift
//  MyNFTTracker
//
//  Created by HappyDuck on 11/16/23.
//

import Foundation
import UIKit.UIImage
import Combine

enum Theme: String, CaseIterable {
    case black = "black"
    case white = "white"
}

final class SettingsViewViewModel {
    
    enum Settings: CaseIterable {
        case appTheme
        
        var sectionTitle: String {
            switch self {
            case .appTheme:
                return SettingsConstants.themeSection
            }
        }
    }
    
    let sections: [Settings] = Settings.allCases
    
    @Published var theme: Theme = .black
    @Published var clipboardTapped: Bool = false
    @Published var userInfo: User
    @Published var profileImage: UIImage?
    @Published var walletAddress: String = ""
    
    init(userInfo: User?, address: String) {
        if let user = userInfo {
            self.walletAddress = address
            self.userInfo = user
            self.profileImage = UIImage.convertBase64StringToImage(user.imageData)
        } else {
            self.userInfo = User(id: UUID().uuidString, nickname: "no-username", imageData: "no-image")
        }
        self.updateTheme()
    }
}


extension SettingsViewViewModel {
    private func updateTheme() {
        guard let themeString = UserDefaults.standard.string(forKey: UserDefaultsConstants.theme),
              let theme = Theme(rawValue: themeString)
        else {
            self.theme = .black
            return
        }
        
        self.theme = theme
    }
}
