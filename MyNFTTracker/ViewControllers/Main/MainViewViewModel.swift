//
//  MainViewViewModel.swift
//  MyNFTTracker
//
//  Created by HappyDuck on 11/8/23.
//

import UIKit.UIImage
import Combine

final class MainViewViewModel {
    
    @Published var nfts: [OwnedNFT] = []
    @Published var imageStrings: [String] = []
    
    init() {
        Task {
            nfts = await getOwnedNfts()
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
    private func getOwnedNfts() async -> [OwnedNFT] {
        do {
            //        let owner = UserDefaults.standard.string(forKey: UserDefaultsConstants.walletAddress) ?? "no-address"
            let owner = "0xdDC3BA83b44Ad769f7994dDC38d5cC7dC77001EF"
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
