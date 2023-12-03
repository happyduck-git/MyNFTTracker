//
//  AlchemyServiceManager.swift
//  MyNFTTracker
//
//  Created by HappyDuck on 11/7/23.
//

import Foundation

final actor AlchemyServiceManager {
    
    enum ChanId: String {
        case eth = "0x1"
        case polygon = "0x89"
        case sepolia = "0xaa36a7"
        case goerli = "0x5"
        case mumbai = "0x13881"
        
        var chain: String {
            switch self {
            case .eth:
                "eth-mainnet"
            case .polygon:
                "ploygon-mainnet"
            case .sepolia:
                "eth-sepolia"
            case .goerli:
                "arb-goerli"
            case .mumbai:
                "polygon-mumbai"
            }
        }
    }
    
    // MARK: - Init
    static let shared = AlchemyServiceManager()
    private init() {}
    
    // MARK: - URL Constant
    private let baseUrl = "https://%@.g.alchemy.com"
    private let chain = "polygon"
    private let network = "mumbai"
    private let acceptKey = "application/json"
    private let headerFieldContentTypeKey = "content-Type"
    
}

// Get NFT Data Related
extension AlchemyServiceManager {
    
    /// Request NFT request
    /// - Returns: Owned NFTs
    func requestOwnedNFTs(ownerAddress: String) async throws -> OwnedNFTs {
      
        let urlRequest = try self.buildUrlRequest(method: .get,
                                                  chain: .eth,
                                                  network: .mainnet,
                                                  api: .nftList,
                                                  queryParameters: [
                                                    URLQueryItem(name: "owner", value: ownerAddress),
                                                    URLQueryItem(name: "withMetadata", value: "true"),
                                                    URLQueryItem(name: "pageSize", value: "100")
                                                  ])
        
        
        do {
            return try await NetworkServiceManager.execute(
                expecting: OwnedNFTs.self,
                request: urlRequest
            )
        }
        catch {
            AppLogger.logger.error("Error requesting Alchemy Service -- \(String(describing: error))")
            throw AlchemyServiceError.wrongRequest
        }
    }
    
    func requestNftMetadata(contractAddress: String, tokenId: String) async throws -> OwnedNFT {
        let urlRequest = try self.buildUrlRequest(method: .get,
                                                  chain: .polygon,
                                                  network: .mumbai,
                                                  api: .singleNftMetaData,
                                                  queryParameters: [
                                                    URLQueryItem(name: "contractAddress", value: contractAddress),
                                                    URLQueryItem(name: "tokenId", value: tokenId)
                                                  ])
        
        
        do {
            return try await NetworkServiceManager.execute(
                expecting: OwnedNFT.self,
                request: urlRequest
            )
        }
        catch {
            AppLogger.logger.error("Error requesting Alchemy Service -- \(String(describing: error))")
            throw AlchemyServiceError.wrongRequest
        }
    }
    
}

extension AlchemyServiceManager {
    
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
    }
    
    enum Chain: String {
        case polygon
        case eth
    }
    
    enum Network: String {
        case mumbai
        case mainnet
    }
    
    enum AlchemyAPI {
        case transfers
        case nftList
        case singleNftMetaData
        
        var endpoint: String? {
            switch self {
            case .nftList:
                return "getNFTs"
            case .singleNftMetaData:
                return "getNFTMetadata"
            default:
                return nil
            }
        }
    }
    
    private func buildUrlRequest(method: HTTPMethod,
                                 chain: Chain,
                                 network: Network,
                                 api: AlchemyAPI,
                                 requests: [String: String] = [:],
                                 pathComponents: [String] = [],
                                 queryParameters: [URLQueryItem] = [],
                                 requestBody: [String: Any] = [:])
    throws -> URLRequest {
        
        let urlString = self.builUrlString(chain: chain,
                                           network: network,
                                           api: api,
                                           requests: requests,
                                           pathComponents: pathComponents,
                                           queryParameters: queryParameters)
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.allHTTPHeaderFields = requests
        
        urlRequest.addValue(acceptKey, forHTTPHeaderField: headerFieldContentTypeKey)
        
        switch method {
        case .get:
            break
        case .post:
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        }
        
        return urlRequest
    }
    
    func builUrlString(chain: Chain,
                       network: Network,
                       api: AlchemyAPI,
                       requests: [String: String] = [:],
                       pathComponents: [String] = [],
                       queryParameters: [URLQueryItem] = [])
    -> String {
        let chainAndNetwork: String = chain.rawValue + "-" + network.rawValue
        var urlString = String(format: self.baseUrl, chainAndNetwork)
        let apiVersion = "v2"
        
        switch api {
        case .transfers:
            break
        default:
            urlString += ("/" + "nft")
        }

        urlString += ("/" + apiVersion + "/" + EnvironmentConfig.alchemyAPIKey)
        
        if let endpoint = api.endpoint {
            urlString += ("/" + endpoint)
        }
        
        if !pathComponents.isEmpty {
            pathComponents.forEach {
                urlString += "/\($0)"
            }
        }
        
        if !queryParameters.isEmpty {
            urlString += "?"
            let argumentString = queryParameters.compactMap {
                guard let value = $0.value else { return nil }
                return "\($0.name)=\(value)"
            }.joined(separator: "&")
            
            urlString += argumentString
        }

        return urlString
    }
}

extension AlchemyServiceManager {
    enum AlchemyServiceError: Error {
        case wrongRequest
    }
}
