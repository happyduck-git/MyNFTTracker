//
//  SettingsViewViewModel.swift
//  MyNFTTracker
//
//  Created by HappyDuck on 11/16/23.
//

import Foundation
import Combine

enum Theme: String, CaseIterable {
    case black = "black"
    case white = "white"
}

final class SettingsViewViewModel {
    
    @Published var theme: Theme = .black
    
    enum Settings: CaseIterable {
        case appTheme
        
        var sectionTitle: String {
            switch self {
            case .appTheme:
                return SettingsConstants.themeSection
            }
        }
    }
    
    let settingContents: [Settings] = Settings.allCases
    
    init() {
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
