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
                String(localized: "메인 페이지")
            case .settings:
                String(localized: "설정")
            }
        }
    }
    
    let menuList: [Contents] = Contents.allCases
    
}
