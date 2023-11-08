//
//  NFTCardViewViewModel.swift
//  MyNFTTracker
//
//  Created by HappyDuck on 11/7/23.
//

import Foundation
import Combine

final class NFTCardViewViewModel {
    
    @Published var nfts: [OwnedNFT] = []
    
    func getNfts(of wallet: String, completion: @escaping ([OwnedNFT])->()) {


    }
    
}
