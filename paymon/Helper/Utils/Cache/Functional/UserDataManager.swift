//
//  UserDataManager.swift
//  paymon
//
//  Created by Maxim Skorynin on 17/10/2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation
import CoreStore

class UserDataManager {
    
    static let shared = UserDataManager()
    
    func setUserDataInfo(userData : UserData, userObject : RPC.UserObject) {
        userData.name = userObject.first_name
        userData.surname = userObject.last_name
        userData.id = userObject.id
        userData.email = userObject.email
        userData.isEmailHidden = userObject.isEmailHidden
        userData.login = userObject.login
        userData.photoUrl = userObject.photoUrl.url
        userData.isContact = false
        userData.btcAddress = userObject.btcAddress ?? ""
        userData.ethAddress = userObject.ethAddress ?? ""
        userData.pmntAddress = userObject.pmntAddress ?? ""
    }
    
    func setUserDataInfo(userData : UserData, userObject : UserData) {
        userData.name = userObject.name
        userData.surname = userObject.surname
        userData.id = userObject.id
        userData.email = userObject.email
        userData.isEmailHidden = userObject.isEmailHidden
        userData.login = userObject.login
        userData.photoUrl = userObject.photoUrl
        userData.isContact = true
        userData.btcAddress = userObject.btcAddress 
        userData.ethAddress = userObject.ethAddress
        userData.pmntAddress = userObject.pmntAddress
    }
    
    func updateOrCreateUser(userObject : RPC.UserObject) {
        do {
            try CacheManager.shared.dataStack.perform(synchronous: {(transaction) -> Void in
                
                if let userData = transaction.fetchOne(From<UserData>().where(\.id == userObject.id)) {
                    self.setUserDataInfo(userData: userData, userObject: userObject)
                    
                } else {
                    let userData = transaction.create(Into<UserData>())
                    self.setUserDataInfo(userData: userData, userObject: userObject)
                    
                }
            })
        } catch let error {
            print("Couldn't update or create user", error)
        }
    }
    
    func updateUser(userObject : UserData) {
        do {
            try CacheManager.shared.dataStack.perform(synchronous: {(transaction) -> Void in
                let userData = transaction.fetchOne(From<UserData>().where(\.id == userObject.id))
                self.setUserDataInfo(userData: userData!, userObject: userObject)
            })
        } catch let error {
            print("couldn't update user", error)
        }
        
    }
    
    func createUser(userObject : RPC.UserObject) {
        do {
            try CacheManager.shared.dataStack.perform(synchronous: {(transaction) -> Void in
                
                let userData = transaction.create(Into<UserData>())
                self.setUserDataInfo(userData: userData, userObject: userObject)
                
            })
        } catch let error {
            print("Couldn't create user", error)
        }
    }
    
    
    func updateUserPhotoUrl(id : Int32, url : String) {
        CacheManager.shared.dataStack.perform(asynchronous: {(transaction) -> Void in
            if let userData = transaction.fetchOne(From<UserData>().where(\.id == id)) {
                userData.photoUrl = url
            }
        }, completion: { _ in
            ChatsDataManager.shared.updateСhatPhotoUrl(id: id, url: url)
        })
    }
    
    func updateUserContact(id : Int32, isContact : Bool) {
        CacheManager.shared.dataStack.perform(asynchronous: {(transaction) -> Void in
            if let userContatctData = transaction.fetchOne(From<UserData>().where(\.id == id)) {
                userContatctData.isContact = isContact
            }
        }, completion: { _ in})
    }
    
    func getUserByIdSync(id : Int32) -> UserData? {
        
        var result : UserData! = nil
        
        DispatchQueue.main.sync {
            if let user = CacheManager.shared.dataStack.fetchOne(
                From<UserData>()
                    .where(\.id == id)
                ) as UserData? {
                result = user
            }
        }
        return result
    }
    
    func getUserById(id : Int32) -> UserData? {
        
        guard let user = CacheManager.shared.dataStack.fetchOne(
            From<UserData>()
                .where(\.id == id)
            ) as UserData? else {
                return nil
        }
        
        return user
    }
    
    func getUserByContact(isContact : Bool) -> [UserData]? {
        
        if let result = CacheManager.shared.dataStack.fetchAll(From<UserData>()
            .where(\.isContact == isContact)) as [UserData]? {
            
            return result
        } else {
            print("Could not get all chats")
            return nil
        }
    }
    
    func getAllUsers() -> [UserData] {
        
        guard let result = CacheManager.shared.dataStack.fetchAll(From<UserData>()) else {
            print("Could not get all user contacts")
            return [UserData]()
        }
        
        return result
    }
    
    func updateUsers(_ users:[RPC.UserObject]) {
        for user in users {
            if !user.login.isEmpty {
                updateOrCreateUser(userObject: user)
            }
        }
    }
}
