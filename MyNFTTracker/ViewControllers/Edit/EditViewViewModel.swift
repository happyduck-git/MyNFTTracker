//
//  EditViewViewModel.swift
//  MyNFTTracker
//
//  Created by HappyDuck on 12/3/23.
//

import Foundation
import Combine

final class EditViewViewModel {
    
    private let firestoreManager = FirestoreManager.shared
    
    var selectedAvatarIndex: IndexPath?
    @Published var theme: Theme = .black
    @Published var address: String?
    
    var nickname: String?
    var profileImageDataString: String?
    @Published var newNickname: String?
    @Published var newProfileImageDataString: String?
    @Published var isNicknameChanged: Bool = false
    @Published var isProfileChanged: Bool = false
    
    @Published var showPickerView: Bool?
    @Published var canShowPickerView: Bool = true
    @Published var user: User
    
    private(set) lazy var infoChanged = Publishers.CombineLatest($isNicknameChanged, $isProfileChanged)
        .map {
            return $0 || $1
        }
        .eraseToAnyPublisher()
    
    init(userInfo: User) {
        self.user = userInfo
        self.updateTheme()
    }
}

extension EditViewViewModel {
    func updateUserInfo() async throws {
        guard let oldNickname = self.nickname,
              let oldImageData = self.profileImageDataString,
              let address = self.address
        else { return }
        
        let nickname = self.newNickname ?? oldNickname
        let profileImageDataString = self.newProfileImageDataString ?? oldImageData
        try await self.firestoreManager.updateUserInfo(of: address,
                                                       nickname: nickname,
                                                       profileImage: profileImageDataString)
    }
}

extension EditViewViewModel {
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
