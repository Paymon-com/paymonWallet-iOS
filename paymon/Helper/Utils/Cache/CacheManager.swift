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
    var dataStack : DataStack!
    let queue = OperationQueue()

    
    func initDb() {
        queue.qualityOfService = .background
        queue.maxConcurrentOperationCount = 1
        print("Start init")
        queue.addOperation {
            let dataStack = DataStack(xcodeModelName: "paymon")
            
            let _ = dataStack.addStorage(SQLiteStore(fileName: "Paymon_\(String(describing: User.shared.currentUser.id!)).sqlite",
                localStorageOptions: .recreateStoreOnModelMismatch),
                completion: { (result) -> Void in
                    guard case .success = result else {
                        return
                    }
                    self.dataStack = dataStack
                    CacheManager.isAddedStorage = true
                    UserDataManager.shared.updateOrCreateUser(userObject: User.shared.currentUser)
                    
                    print("Storage was added")
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: .coreStoreWasCreated, object: nil)
                    }
                    
            })
        }
        
    }
    
    func removeDb() {
        queue.addOperation {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .removeObserver, object: nil)
            }
            
            self.dataStack = nil
            CacheManager.isAddedStorage = false
        }
    }
}
