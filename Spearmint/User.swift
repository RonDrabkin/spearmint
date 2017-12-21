//
//  User.swift
//  Spearmint
//
//  Created by Sebastian Shanus on 12/9/17.
//  Copyright © 2017 Sebastian Shanus. All rights reserved.
//

import FirebaseDatabase
import Foundation

struct User {
    var uid: String
    var accessToken: String
    var hasLinkedBankAccount: Bool
}

struct UserContext {
    private let reference = Database.database().reference()
    fileprivate var usersReference : DatabaseReference {
        return reference.child(FirebaseIdentifiers.Users.identifier)
    }
    
    func user(from uid: String) -> User {
        usersReference
            .child(uid)
            .observeSingleEvent(of: .value, with: { (snapshot) in
                guard let data = snapshot.value as? [String : Any] else {
                    fatalError("Could not retrieve user data snapshot.")
                }
                return dataToUser(data, uid: uid)
        })
    }
    
    @discardableResult
    func createUser(from uid: String) -> User {
        let userData : [String : Any] =
            [FirebaseIdentifiers.Users.hasLinkedBankAccountKey : false,
             FirebaseIdentifiers.Users.accessTokenKey : ""]
        usersReference
            .child(uid)
            .setValue(userData)
        return User(uid: uid, accessToken: "", hasLinkedBankAccount: false)
    }
    
    func update(_ user: User) {
        let data = userToData(user)
        usersReference.child(user.uid).setValue(data)
    }
    
    private func userToData(_ user: User) -> [String : Any] {
        return [
            FirebaseIdentifiers.Users.hasLinkedBankAccountKey : user.hasLinkedBankAccount,
            FirebaseIdentifiers.Users.hasLinkedBankAccountKey : user.accessToken
        ]
    }
    
    private func dataToUser(_ data: [String : Any], uid: String) -> User {
        guard let hasLinkedBankAccount = data[FirebaseIdentifiers.Users.hasLinkedBankAccountKey] as? Bool else {
            fatalError("Could not find object or cast.")
        }
        guard let accessToken = data[FirebaseIdentifiers.Users.accessTokenKey] as? String else {
            fatalError("Could not find object or cast.")
        }
        return User(uid: uid, accessToken: accessToken, hasLinkedBankAccount: hasLinkedBankAccount)
    }
}
