//
//  LoginViewViewModel.swift
//  MyNFTTracker
//
//  Created by HappyDuck on 11/6/23.
//

import UIKit
import Combine

final class LoginViewViewModel {
    // Metamask
    private let metamaskManager = MetamaskManager.shared
    
    // Firebase
    private let firestoreManager = FirestoreManager.shared
    
    // Combine
    private var bindings = Set<AnyCancellable>()
    
    @Published var signInTapped: Bool = false
    @Published var walletConnected: Bool = false
//    @Published var isFirstVisit: Bool = false
    @Published var signInCompleted: Bool = false
    @Published var address: String = ""
    @Published var selectedChain: String = ""
    @Published var isAddressLogin: Bool = false
     
    var isFirstVisit = PassthroughSubject<Bool, Never>()
    var walletSigninTapped = PassthroughSubject<String, Never>()
    var metamaskSigninTapped = PassthroughSubject<Void, Never>()
    var walletConnection = PassthroughSubject<Bool, Never>()
    var errorTracker = PassthroughSubject<Error, Never>()
    
    private(set) lazy var activateLoginButton = Publishers.CombineLatest($selectedChain, $address)
        .map { chainId, address -> Bool in
            return !chainId.isEmpty && !address.isEmpty ? true : false
        }
        .eraseToAnyPublisher()

}

extension LoginViewViewModel {
    
    func transform() {
        let metamask = metamaskManager.metaMaskSDK
        
        // Login Handling
        metamaskSigninTapped
            .sink { [weak self] _ in
                guard let `self` = self else { return }
                Task {
                    metamask.useDeeplinks = false
                    let result = await metamask.connect()
                    switch result {
                    case .success(let address):
                        self.address = address.lowercased()
                        self.selectedChain = metamask.chainId
                        
                    case .failure(let error):
                        self.errorTracker.send(error)
                        #if DEBUG
                        AppLogger.logger.error("Connection error: \(String(describing: error))")
                        #endif
                    }
                }
            }
            .store(in: &bindings)
        
        walletSigninTapped
            .sink { [weak self] address in
                guard let `self` = self else { return }
                self.address = address.lowercased()
            }
            .store(in: &bindings)
        
        // Address and chainID validation
        Publishers.CombineLatest($address, $selectedChain).sink { [weak self] add, chain in
            guard let `self` = self else { return }
            if self.isHexString(add) && self.isValidChain(chain) {
                self.walletConnection.send(true)
            } else {
                self.walletConnection.send(false)
            }
        }
        .store(in: &bindings)
        
        // Check User Registration
        self.walletConnection
            .sink { [weak self] isConnected in
                guard let `self` = self else { return }
                
                if isConnected {
                    Task {
                        do {
                            self.isFirstVisit.send(try await !self.firestoreManager.isRegisteredUser(self.address) ? true : false)
                        }
                        catch {
                            AppLogger.logger.error("Error: \(error)")
                            self.errorTracker.send(error)
                        }
                    }
                    
                } else {
                    self.errorTracker.send(LoginError.walletNotConnected)
                }
                
            }
            .store(in: &bindings)

    }
    
    func saveAddressAndChainId(address: String?, chainId: String) {
        UserDefaults.standard.set(address, forKey: UserDefaultsConstants.walletAddress)
        UserDefaults.standard.set(chainId, forKey: UserDefaultsConstants.chainId)
        #if DEBUG
        AppLogger.logger.log("Wallet address saved to UserDefaults -- \(String(describing: address))\n and Chain Id -- \(String(describing: chainId))")
        #endif
    }
}

extension LoginViewViewModel {
    
    enum LoginError: Error {
        case wrongAddressFormat
        case walletNotConnected
    }
    
    func isHexString(_ string: String) -> Bool {
        let pattern = "^0x[a-fA-F0-9]+$"
        if let _ = string.range(of: pattern, options: .regularExpression) {
            return true
        } else {
            return false
        }
    }
    
    func isValidChain(_ chain: String) -> Bool {
        guard let _ = Chain(rawValue: chain) else {
            return false
        }
        return true
    }
}
