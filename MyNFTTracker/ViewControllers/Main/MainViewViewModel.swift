//
//  MainViewViewModel.swift
//  MyNFTTracker
//
//  Created by HappyDuck on 11/8/23.
//

import UIKit.UIImage
import Combine
import FirebaseFirestore

final class MainViewViewModel {
    
    var user = PassthroughSubject<User?, Error>()
    var currentUserInfo: User?
    @Published var username: String = " "
    @Published var profileImageDataString: String?
    @Published var nfts: [OwnedNFT] = [] {
        didSet {
            selectedNfts = Array(repeating: false, count: nfts.count)
        }
    }
    @Published var imageStrings: [String] = []
    var errorFetchingUserInfo = PassthroughSubject<Error, Never>()
    
    var selectedNfts: [Bool] = []
    var address: String = ""
    
    init() {
        Task {
            
            async let userInfo = self.getUserInfo()
            async let nftList = self.getOwnedNfts()
      
            self.user.send(await userInfo)
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
    private func getUserInfo() async -> User? {
        do {
            let wallet = UserDefaults.standard.string(forKey: UserDefaultsConstants.walletAddress) ?? "no-address"
            self.address = wallet
            return try await FirestoreManager.shared.retrieveUserInfo(of: wallet)
        }
        catch {
            self.user.send(completion: .failure(error))
            return nil
        }
    }
    
}

extension MainViewViewModel {
    private func getOwnedNfts() async -> [OwnedNFT] {
        do {
            let chainId = UserDefaults.standard.string(forKey: UserDefaultsConstants.chainId) ?? Chain.eth.rawValue
            let owner = UserDefaults.standard.string(forKey: UserDefaultsConstants.walletAddress) ?? "no-address"
//            let owner = "0x04dBF23edb725fe9C859908D76E9Ccf38BC80a13"
            let result = try await AlchemyServiceManager.shared.requestOwnedNFTsOn(chainId, ownerAddress: owner)
            
            #if DEBUG
            print("Number of NFTs received: \(result.ownedNfts.count)")
            #endif
            
            return result.ownedNfts
        }
        catch {
            print("Error -- \(error)")
            return []
        }

    }
}
