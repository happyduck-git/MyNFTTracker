//
//  User.swift
//  MyNFTTracker
//
//  Created by HappyDuck on 12/2/23.
//

import Foundation

struct User: Codable {
    let id: String
    var address: String?
    let nickname: String
    let imageData: String
}
