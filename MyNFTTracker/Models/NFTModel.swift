//
//  NFTModel.swift
//  MyNFTTracker
//
//  Created by HappyDuck on 11/7/23.
//

import Foundation

struct OwnedNFTs: Codable {
    let ownedNfts: [OwnedNFT]
    let pageKey: String?
    let totalCount: Int
}

struct OwnedNFT: Codable {
    let contract: Contract
    let id: NFTId
    let title: String
    let description: String
    let metadata: NFTMetadata?
}

struct Contract: Codable {
    let address: String
}

struct NFTId: Codable {
    let tokenId: String
}

struct NFTMetadata: Codable {
    let image: String?
    let name: String?
    let description: String?
    let attributes: [NFTAttribute]?
    let tokenId: Int?
    let contractMetadata: ContractMetadata?
}

struct NFTAttribute: Codable {
    let value: String
    let traitType: String
}

struct ContractMetadata: Codable {
    let name: String
    let symbol: String
    let tokenType: String
}
