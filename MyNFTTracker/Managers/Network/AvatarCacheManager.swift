//
//  AvatarCacheManager.swift
//  MyNFTTracker
//
//  Created by HappyDuck on 12/2/23.
//

import Foundation

final class AvatarCacheManager {
    private var cacheDictionary = NSCache<NSString, NSData>()
    
    static let shared = AvatarCacheManager()
    private init() {}
}

extension AvatarCacheManager {
    //MARK: - Public
    
    /// Get Cache
    /// Check if there is something available in the cache dictionary
    public func cachedResponse(for url: URL?) -> Data? {
        guard let url = url else { return nil }
        let key = url.absoluteString as NSString
        return cacheDictionary.object(forKey: key) as? Data
    }
    
    /// Set Cache
    /// - Parameters:
    ///   - endpoint: endpoint of request
    ///   - url: url
    ///   - data: data to save in NSCache
    public func setCache(for url: URL?, data: Data?) {
        guard let url = url,
              let data = data else { return }
        let key = url.absoluteString as NSString
        let nsdata = data as NSData
        cacheDictionary.setObject(nsdata, forKey: key)
    }
}
