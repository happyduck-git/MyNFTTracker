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
    static let chainId = "chain-id"
    static let theme = "app-theme"
}

enum NotificationConstants {
    static let theme = "default-theme"
    static let userInfo = "user-info"
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

enum MainViewConstants {
    static let welcome = String(localized: "반갑습니다! %@\n가지고 계신 NFT를 구경해 보세요.")
    static let noNft = String(localized: "아직 보유하고 계신 NFT가 없습니다.")
}

enum LoginConstants {
    static let failedToConnectWallet = String(localized: "지갑 연결 실패")
    static let userNotFound = String(localized: "등록되지 않은 사용자")
    static let tryAgain = String(localized: "다시 한번 시도해주세요.")
    static let confirm = String(localized: "확인")
    static let retryTitle = String(localized: "재시도 요청")
}

enum SettingsConstants {
    static let selectTheme = "Select Theme"
    static let themeSection = String(localized: "앱 테마")
    static let darkMode = String(localized: "다크 모드")
    static let lightMode = String(localized: "라이트 모드")
    static let edit = String(localized: "수정하기")
}

enum SideMenuConstants {
    static let menu = String(localized: "나의 메뉴")
    static let signout = String(localized: "로그아웃")
    static let signoutMessage = String(localized: "로그아웃 하시겠습니까?")
    static let cancel = String(localized: "취소")
}

enum EditConstants {
    static let nickname = String(localized: "닉네임")
    static let save = String(localized: "저장하기")
    static let updateConfirm = String(localized: "수정 하시겠습니까?")
    static let updateConfirmMsg = String(localized: "변경된 내용으로 정보를 수정합니다.")
    static let updateCompleted = String(localized: "수정 완료")
    static let updateCompletedMsg = String(localized: "정보가 정상적으로 수정되었습니다.")
    static let confirm = String(localized: "확인")
    static let cancel = String(localized: "취소")
}

enum FirestoreConstants {
    static let users = "users"
    static let uuid = "id"
    static let nickname = "nickname"
    static let imageData = "imageData"
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
