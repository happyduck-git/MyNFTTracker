//
//  MainViewViewModel.swift
//  MyNFTTracker
//
//  Created by HappyDuck on 11/8/23.
//

import UIKit.UIImage
import Combine

final class MainViewViewModel {
    
    @Published var user: User?
    @Published var username: String = "USER-NAME"
    @Published var profileImageDataString: String?
    @Published var nfts: [OwnedNFT] = [] {
        didSet {
            selectedNfts = Array(repeating: false, count: nfts.count)
        }
    }
    @Published var imageStrings: [String] = []
    
    var selectedNfts: [Bool] = []
    var address: String = ""
    
    init() {
        Task {
            async let userInfo = self.getUserInfo()
            async let nftList = self.getOwnedNfts()
            
            self.user = await userInfo
            self.nfts = await nftList
        }
    }
    
    
}

extension MainViewViewModel {

    func buildPinataUrl(from string: String) -> String {
        let ipfsPrefix = "ipfs://"
        let pinataPrefix = "https://gateway.pinata.cloud/ipfs/"
        return pinataPrefix + string.replacingOccurrences(of: ipfsPrefix, with: "")
    }
    
}

extension MainViewViewModel {
    private func getUserInfo() async -> User {
        do {
            let wallet = UserDefaults.standard.string(forKey: UserDefaultsConstants.walletAddress) ?? "no-address"
            self.address = wallet
            return try await FirestoreManager.shared.retrieveUserInfo(of: wallet)
        }
        catch {
            print("Error -- \(error)")
            return User(id: UUID().uuidString, nickname: "no-nickname", imageData: "no-image")
        }
    }
    
}

extension MainViewViewModel {
    private func getOwnedNfts() async -> [OwnedNFT] {
        do {
            //        let owner = UserDefaults.standard.string(forKey: UserDefaultsConstants.walletAddress) ?? "no-address"
            let owner = "0x04dBF23edb725fe9C859908D76E9Ccf38BC80a13"
            let result = try await AlchemyServiceManager.shared.requestOwnedNFTs(ownerAddress: owner)
            print("result: \(result.ownedNfts.count)")
            return result.ownedNfts
        }
        catch {
            print("Error -- \(error)")
            return []
        }

    }
}
