//
//  Constants.swift
//  MyNFTTracker
//
//  Created by HappyDuck on 11/7/23.
//

import Foundation

enum DemoConstants {
//    static let dummyWallet = "0x9Ff63e20Ec8c6eA59116a49d5D68fa91d579114D"
    static let dummyWallet = "0x0097b9cFE64455EED479292671A1121F502bc954"
}
enum UserDefaultsConstants {
    static let walletAddress = "walletAddress"
    static let chainId = "chain-id"
    static let theme = "app-theme"
}

enum NotificationConstants {
    static let theme = "default-theme"
    static let userInfo = "user-info"
    static let metamaskConnection = "metamask-connection"
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
    static let welcomeDesc = String(localized: "계정을 등록하고 보유하고 계신 NFT 앨범을 구경해보세요 :)")
}

enum MainViewConstants {
    static let welcome = String(localized: "반갑습니다! %@\n가지고 계신 NFT를 구경해 보세요.")
    static let noNft = String(localized: "아직 보유하고 계신 NFT가 없습니다.")
    static let connectedChain = String(localized: "연결된 체인")
    static let notConnected = String(localized: "연결되지 않음")
    static let confirm = String(localized: "확인")
}

enum LoginConstants {
    static let failedToConnectWallet = String(localized: "지갑 연결 실패")
    static let userNotFound = String(localized: "등록되지 않은 사용자")
    static let tryAgain = String(localized: "Metask 종료 후 다시 한번 시도해주세요.")
    static let confirm = String(localized: "확인")
    static let retryTitle = String(localized: "재시도 요청")
    static let selectChain = String(localized: "체인 선택")
    static let or = String(localized: "OR")
    static let login = String(localized: "로그인")
    static let address = String(localized: "지갑 주소 0xabcd...")
    static let wrongAddress = String(localized: "올바르지 않은 지갑주소 형식입니다.")
}

enum SettingsConstants {
    static let selectTheme = "Select Theme"
    static let themeSection = String(localized: "앱 테마")
    static let darkMode = String(localized: "다크 모드")
    static let lightMode = String(localized: "라이트 모드")
    static let edit = String(localized: "수정하기")
    static let deleteAccount = String(localized: "계정 삭제")
    static let deleteAccountAlertTitle = String(localized: "계정 삭제")
    static let deleteAccountAlertMsg = String(localized: "계정 삭제 후 복구가 되지 않습니다. 정말로 삭제 하시겠습니까?")
    static let delete = String(localized: "삭제")
    static let cancel = String(localized: "취소")
    static let errorInDeletionAlertTitle = String(localized: "계정 삭제 오류")
    static let errorInDeletionAlertMsg = String(localized: "계정 삭제 중 오류가 발생했습니다. 다시 시도해 주시기 바랍니다.")
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
