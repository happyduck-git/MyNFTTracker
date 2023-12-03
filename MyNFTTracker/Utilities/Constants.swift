//
//  Constants.swift
//  MyNFTTracker
//
//  Created by HappyDuck on 11/7/23.
//

import Foundation

enum DemoConstants {
    static let dummyWallet = "0xf9C6e0F084c03e54a1E744e42B47C338A5FFc34D"
}
enum UserDefaultsConstants {
    static let walletAddress = "walletAddress"
    static let theme = "app-theme"
}

enum NotificationConstants {
    static let theme = "default-theme"
}

enum ImageAssets {
    static let clipboardFill = "doc.on.clipboard.fill"
    static let editFill = "pencil.circle.fill"
}

enum RegisterViewConstants {
    static let next = String(localized: "다음")
    static let skip = String(localized: "건너뛰기")
}

enum WelcomeConstants {
    static let welcome = String(localized: "환영합니다!")
}

enum SettingsConstants {
    static let selectTheme = "Select Theme"
    static let themeSection = String(localized: "앱 테마")
    static let darkMode = String(localized: "다크 모드")
    static let lightMode = String(localized: "라이트 모드")
}

enum SideMenuConstants {
    static let menu = String(localized: "나의 메뉴")
    static let signout = String(localized: "로그아웃")
    static let signoutMessage = String(localized: "로그아웃 하시겠습니까?")
    static let cancel = String(localized: "취소")
}

enum FirestoreConstants {
    static let users = "users"
    static let uuid = "id"
    static let nickname = "nickname"
    static let imageUrl = "imageUrl"
}

enum AvatarConstants {
    static let title = String(localized: "캐릭터를 고르세요")
    static let avatarList = ["Simon",
                             "Bella",
                             "Zoey",
                             "Charlie",
                             "George",
                             "Miss kitty",
                             "Scooter",
                             "Lola",
                             "Missy",
                             "Spooky",
                             "Cuddles",
                             "Maggie",
                             "Gracie",
                             "Mimi",
                             "Toby",
                             "Loki",
                             "Kiki",
                             "Snickers",
                             "Lily",
                             "Shadow"]
}
