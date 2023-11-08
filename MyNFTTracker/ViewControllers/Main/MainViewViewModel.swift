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
    private func getOwnedNfts() async -> [OwnedNFT] {
        do {
            //        let owner = UserDefaults.standard.string(forKey: UserDefaultsConstants.walletAddress) ?? "no-address"
            let owner = "0x04dBF23edb725fe9C859908D76E9Ccf38BC80a13"
            let result = try await AlchemyServiceManager.shared.requestOwnedNFTs(ownerAddress: owner)
            print("result: \(result)")
            return result.ownedNfts
        }
        catch {
            print("Error -- \(error)")
            return []
        }

    }
}
