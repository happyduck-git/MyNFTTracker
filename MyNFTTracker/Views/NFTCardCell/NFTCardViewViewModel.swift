//
//  NFTCardViewViewModel.swift
//  MyNFTTracker
//
//  Created by HappyDuck on 11/7/23.
//

import Foundation
import Combine

final class NFTCardViewViewModel {
    
    weak var delegate: NFTCardViewModelDelegate?
    @Published var nfts: [NFTModel] = []
    
    func getNfts(of wallet: String, completion: @escaping ([NFTModel])->()) {


    }
    
}
