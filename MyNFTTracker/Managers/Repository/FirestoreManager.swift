//
//  FirestoreManager.swift
//  MyNFTTracker
//
//  Created by HappyDuck on 11/30/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

final actor FirestoreManager {

    static let shared = FirestoreManager()
    private init() {}
    
    private let baseDB = Firestore.firestore()
    
}

extension FirestoreManager {
    
    func saveWalletAddress(_ wallet: String) async throws {
        try await baseDB.collection(FirestoreConstants.users)
            .document(wallet)
            .setData([FirestoreConstants.uuid: UUID().uuidString], merge: true)
    }
    
    func saveUserInfo(of wallet: String, imageUrl: String, nickname: String) async throws {
        try await baseDB.collection(FirestoreConstants.users)
            .document(wallet)
            .setData([FirestoreConstants.nickname: nickname,
                      FirestoreConstants.imageUrl: imageUrl], merge: true)
    }
    
    func isRegisteredUser(_ wallet: String) async throws -> Bool {
        return try await baseDB.collection(FirestoreConstants.users)
            .document(wallet)
            .getDocument()
            .exists
    }
    
}

extension FirestoreManager {
    func retrieveUserInfo(of wallet: String) async throws -> User {
        let document = try await baseDB.collection(FirestoreConstants.users)
            .document(wallet)
            .getDocument()
        
        return try document.data(as: User.self)
    }
}
