//
//  LoginViewViewModel.swift
//  MyNFTTracker
//
//  Created by HappyDuck on 11/6/23.
//

import UIKit
import Combine

final class LoginViewViewModel {
    
    @Published var signInTapped: Bool = false
    @Published var walletConnected: Bool = false
    @Published var isFirstVisit: Bool = false
    @Published var signInCompleted: Bool = false
    var receivedError = PassthroughSubject<Error, Never>()
    
    var address: String?
}

extension LoginViewViewModel {
    func saveAddressAndChainId(address: String?, chainId: String) {
        UserDefaults.standard.set(address, forKey: UserDefaultsConstants.walletAddress)
        UserDefaults.standard.set(chainId, forKey: UserDefaultsConstants.chainId)
        #if DEBUG
        AppLogger.logger.log("Wallet address saved to UserDefaults -- \(String(describing: address))\n and Chain Id -- \(String(describing: chainId))")
        #endif
    }
}
