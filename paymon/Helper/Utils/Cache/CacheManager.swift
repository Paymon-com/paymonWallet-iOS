////
////  CacheManager.swift
////  paymon
////
////  Created by Maxim Skorynin on 06/10/2018.
////  Copyright © 2018 Maxim Skorynin. All rights reserved.
////
//

import Foundation
import CoreStore
import CoreData

public class CacheManager {
    
    static let shared = CacheManager()
    static var isAddedStorage = false
    private var dataStack : DataStack!
    private var store : SQLiteStore!
    
    func initDb() {
        print("Start init")
        if dataStack == nil {
            dataStack = DataStack(
                xcodeModelName: "paymon",
                migrationChain: []
            )
        }
        
        store = SQLiteStore(fileName: "Paymon_\(String(describing: User.shared.currentUser.id!)).sqlite",
            localStorageOptions: .recreateStoreOnModelMismatch)
        
//        do {
            dataStack.addStorage(store) { _ in
                CoreStore.defaultStack = self.dataStack
                CacheManager.isAddedStorage = true
                UserDataManager.shared.updateOrCreateUser(userObject: User.shared.currentUser)
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .setMainController, object: nil)
                }
            }
//        } catch let error {
//            print("Error init db", error)
//        }
        
        
    }
    
    func removeDb() {
        CoreStore.defaultStack = DataStack()
        CacheManager.isAddedStorage = false
    }
}
