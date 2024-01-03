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
            .setData([FirestoreConstants.uuid: UUID().uuidString,
                      FirestoreConstants.nickname: nickname,
                      FirestoreConstants.imageData: imageUrl], merge: true)
    }
    
    func isRegisteredUser(_ wallet: String) async throws -> Bool {
        if wallet.isEmpty { return false }
        return try await baseDB.collection(FirestoreConstants.users)
            .document(wallet)
            .getDocument()
            .exists
    }
    
    func isRegistrationCompleted(_ wallet: String) async throws -> Bool {
        let document = try await baseDB.collection(FirestoreConstants.users)
            .document(wallet)
            .getDocument()
        
        let data = document.data()
        return data?[FirestoreConstants.nickname] != nil
    }
    
}

extension FirestoreManager {
    func updateUserInfo(of wallet: String, nickname: String, profileImage: String) async throws {
        try await baseDB.collection(FirestoreConstants.users)
            .document(wallet)
            .updateData([FirestoreConstants.nickname: nickname,
                         FirestoreConstants.imageData: profileImage])
    }
}

extension FirestoreManager {
    func retrieveUserInfo(of wallet: String) async throws -> User {
        if try await !isRegisteredUser(wallet) {
            throw FirestoreErrorCode(.notFound)
        }
        let document = try await baseDB.collection(FirestoreConstants.users)
            .document(wallet)
            .getDocument()
        
        var user = try document.data(as: User.self)
        user.address = wallet
        return user
    }
}

extension FirestoreManager {
    func deleteUserInfo(of wallet: String) async throws {
        let docRef = baseDB
            .collection(FirestoreConstants.users)
            .document(wallet)
        
        if try await docRef
            .getDocument()
            .exists {
            try await baseDB
                .collection(FirestoreConstants.users)
                .document(wallet)
                .delete()
            return
        }
        
        throw FirestoreErrorCode(.notFound)
    }
}
