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
    @Published var imageStrings: [String] = []
    @Published var chainId: String = ""
    var errorFetchingUserInfo = PassthroughSubject<Error, Never>()
    var nftIsLoaded = PassthroughSubject<Bool, Error>()
    
    var selectedNfts: [Bool] = []
    var address: String = ""
    
    @Published var nfts: [OwnedNFT] = [] {
        didSet {
            self.selectedNfts = Array(repeating: false, count: nfts.count)
            self.imageStrings = self.nfts.compactMap { extractImageString(fromMetadata: $0.metadata) }
        }
    }
    
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
    
    // Helper function to extract image string from NFTMetadata
    private func extractImageString(fromMetadata metadata: MetadataContent?) -> String {
        guard let metadata = metadata else { return "" }
        
        switch metadata {
        case .object(let data):
            return processImageString(data.image)
        case .htmlString:
            return ""
        }
    }

    // Helper function to process image string, including handling IPFS URLs
    private func processImageString(_ imageString: String?) -> String {
        guard let imageString = imageString else { return "" }
        return imageString.hasPrefix("ipfs://") ? buildPinataUrl(from: imageString) : imageString
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

            let result = try await AlchemyServiceManager.shared.requestOwnedNFTsOn(chainId, ownerAddress: owner)
            #if DEBUG
            print("Number of NFTs received: \(result.ownedNfts.count)")
            #endif
            
            return result.ownedNfts
        }
        catch {
            print("Error -- \(error)")
            self.nftIsLoaded.send(completion: .failure(error))
            return []
        }

    }
}
