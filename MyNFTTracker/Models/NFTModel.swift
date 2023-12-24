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
    let metadata: MetadataContent?
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
    let tokenId: Value?
    let contractMetadata: ContractMetadata?
}

struct NFTAttribute: Codable {
    let value: Value
    let traitType: String
}

struct ContractMetadata: Codable {
    let name: String
    let symbol: String
    let tokenType: String
}

enum MetadataContent: Codable {
    case object(NFTMetadata)
    case htmlString(String)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        // Attempt to decode as structured object first
        if let metadata = try? container.decode(NFTMetadata.self) {
            self = .object(metadata)
            return
        }
        // Fall back to decoding as a string
        if let htmlString = try? container.decode(String.self) {
            self = .htmlString(htmlString)
            return
        }
        throw DecodingError.typeMismatch(MetadataContent.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected object or HTML string for metadata"))
    }
}

enum Value: Codable {
    case string(String)
    case number(Int)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        if let x = try? container.decode(Int.self) {
            self = .number(x)
            return
        }
        throw DecodingError.typeMismatch(Value.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for Value"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let x):
            try container.encode(x)
        case .number(let x):
            try container.encode(x)
        }
    }
}
