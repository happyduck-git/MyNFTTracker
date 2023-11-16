//
//  ContentsSideMenuViewViewModel.swift
//  MyNFTTracker
//
//  Created by HappyDuck on 11/16/23.
//

import Foundation

struct ContentsSideMenuViewViewModel {
    enum Contents: CaseIterable {
        case main
        case settings
        
        //TODO: Change Icon Name
        var displayIcon: String {
            switch self {
            case .main:
                "Main Page"
            case .settings:
                "Settings"
            }
        }
        
        var displayText: String {
            switch self {
            case .main:
                String(localized: "Main Page")
            case .settings:
                String(localized: "Settings")
            }
        }
    }
    
    let menuList: [Contents] = Contents.allCases
    
}
