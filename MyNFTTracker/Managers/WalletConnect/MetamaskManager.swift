//
//  MetamaskManager.swift
//  MyNFTTracker
//
//  Created by HappyDuck on 12/3/23.
//

import Foundation
import metamask_ios_sdk

final class MetamaskManager {
    static let shared = MetamaskManager()
    private let appMetadata = AppMetadata(name: "MyNFTTracker", url: "https://my-nft-tracker.com")
    let metaMaskSDK: MetaMaskSDK
    
    private init() {
        metaMaskSDK = MetaMaskSDK.shared(appMetadata)
    }
}

