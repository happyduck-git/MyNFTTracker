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
}
