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
    @Published var chainId: String = ""
    var errorFetchingUserInfo = PassthroughSubject<Error, Never>()
    
    var selectedNfts: [Bool] = []
    var address: String = ""
    
    deinit {
        print("Main View Model Deinit")
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
    func getUserInfo() async -> User? {
        do {
            let wallet = UserDefaults.standard.string(forKey: UserDefaultsConstants.walletAddress) ?? "no-address"
            self.address = wallet
            
            let chainId = UserDefaults.standard.string(forKey: UserDefaultsConstants.chainId) ?? "no-chainId"
            self.chainId = chainId
            
            return try await FirestoreManager.shared.retrieveUserInfo(of: wallet)
        }
        catch {
            self.user.send(completion: .failure(error))
            return nil
        }
    }
    
}

extension MainViewViewModel {
    func getOwnedNfts() async -> [OwnedNFT] {
        do {
            let chainId = UserDefaults.standard.string(forKey: UserDefaultsConstants.chainId) ?? Chain.eth.rawValue
            let owner = UserDefaults.standard.string(forKey: UserDefaultsConstants.walletAddress) ?? "no-address"

//            let result = try await AlchemyServiceManager.shared.requestOwnedNFTsOn(chainId, ownerAddress: owner)
            let result = try await AlchemyServiceManager.shared.requestOwnedNFTsOn(chainId, ownerAddress: DemoConstants.dummyWallet)
            #if DEBUG
            print("Number of NFTs received: \(result.ownedNfts.count)")
            result.ownedNfts.forEach({ ele in
                ele.metadata?.attributes
            })
            #endif
            
            return result.ownedNfts
        }
        catch {
            print("Error -- \(error)")
            return []
        }

    }
}
