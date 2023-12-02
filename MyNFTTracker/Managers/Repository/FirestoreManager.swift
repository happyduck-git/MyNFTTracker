//
//  FirestoreManager.swift
//  MyNFTTracker
//
//  Created by HappyDuck on 11/30/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

final class FirestoreManager {

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
    
    func isRegisteredUser(_ wallet: String) async throws -> Bool {
        return try await baseDB.collection(FirestoreConstants.users)
            .document(wallet)
            .getDocument()
            .exists
    }
    
}

