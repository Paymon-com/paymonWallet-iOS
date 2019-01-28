//
// Created by Vladislav on 23/08/2017.
// Copyright (c) 2017 Paymon. All rights reserved.
//

import Foundation

class User {
    
    static let shared = User()
    
     var currentUser: RPC.PM_userSelf!
     var isAuthenticated = false
     var notificationWorry = true
     var notificationVibration = true
//     var notificationTransactions = false
//     var notificationMessageSound = ""
//     var notificationTransactionSound = ""

     var securityPasscode = false
     var securityPasscodeValue = ""
     var timeFormatIs24 = true
     var userId : String = ""
     var currencyCode : String = "USD"
     var currencyCodeSymb : String = "$"
    
     var passwordBtcWallet : String = ""
     var passwordEthWallet : String = ""
     var passwordPmntWallet : String = ""

     var symbCount : Int32 = 2
//     var rowSeed : String = ""
//     var isBackupBtcWallet : Bool = false
     var isBackupEthWallet : Bool = false
     var isBackupPmntWallet : Bool = false
    
    var isPmntCreatedFromEth = false

    var isSettingsWasSet = false
    
     func saveConfig() {
        if currentUser != nil {

            let stream = SerializedStream()
        
            currentUser!.serializeToStream(stream: stream!)
            
            let userString = stream!.out.base64EncodedString()

            KeychainWrapper.standard.set(userString, forKey: "user", withAccessibility: KeychainItemAccessibility.always)
        } else {
            KeychainWrapper.standard.removeObject(forKey: "user")
        }
        
    }

     func loadConfig() {
        print("load config")
        if currentUser == nil {

            if let retrievedString = KeychainWrapper.standard.string(forKey: "user", withAccessibility: KeychainItemAccessibility.always) {
                let data = Data(base64Encoded: retrievedString)
                let stream = SerializedStream(data: data)
                if let deserialize = try? RPC.UserObject.deserialize(stream: stream!, constructor: stream!.readInt32(nil)) {
                    if deserialize is RPC.PM_userSelf {
                        currentUser = deserialize as? RPC.PM_userSelf
                        self.setUserSettings()
                        
                        stream!.close()
                        return
                    } else {
                        currentUser = nil
                        stream!.close()
                        return
                    }
                } else {
                    print("Error deser user")
                    stream!.close()
                    return
                }
            } else {
                guard let window = UIApplication.shared.delegate?.window else {return}
                window!.rootViewController = StoryBoard.main.instantiateViewController(withIdentifier: VCIdentifier.mainNavigationController)
                return
            }
        } else {
            self.setUserSettings()
        }
    }
    
     func setCurrencyCodeSymb() {
        switch currencyCode {
        case Money.rub: currencyCodeSymb = "₽"
        case Money.usd: currencyCodeSymb = "$"
        default:
            break
        }
    }
    
     func setUserSettings() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .setMainController, object: nil)
        }

        if !isSettingsWasSet {

            if !CacheManager.isAddedStorage {
                print("init DB")
                CacheManager.shared.initDb()
            }
            
            self.userId = String(currentUser.id)
            
            isPmntCreatedFromEth = KeychainWrapper.standard.bool(forKey: UserDefaultKey.IS_PMNT_CREATED_FROM_ETH + userId) ?? false

            isBackupEthWallet = KeychainWrapper.standard.bool(forKey: UserDefaultKey.IS_ETH_WALLET_BACKUP + userId) ?? false
            print("isBeckup eth wallet - \(isBackupEthWallet)")
            isBackupPmntWallet = KeychainWrapper.standard.bool(forKey: UserDefaultKey.IS_PMNT_WALLET_BACKUP + userId) ?? false
            
            //        isBackupBtcWallet = KeychainWrapper.standard.bool(forKey: UserDefaultKey.IS_BTC_WALLET_BACKUP + userId) ?? false
            //        rowSeed = KeychainWrapper.standard.string(forKey: UserDefaultKey.ROW_SEED_FOR_BACKUP + userId) ?? ""
            //        passwordBtcWallet = KeychainWrapper.standard.string(forKey: UserDefaultKey.PASSWORD_BTC_WALLET + userId) ?? ""
            passwordEthWallet = KeychainWrapper.standard.string(forKey: UserDefaultKey.PASSWORD_ETH_WALLET + userId) ?? ""
            passwordPmntWallet = KeychainWrapper.standard.string(forKey: UserDefaultKey.PASSWORD_PMNT_WALLET + userId) ?? ""
            
            currencyCode = KeychainWrapper.standard.string(forKey: UserDefaultKey.CURRENCY_CODE + userId) ?? "USD"
            symbCount = Int32(KeychainWrapper.standard.integer(forKey: UserDefaultKey.SYMB_COUNT + userId) ?? 2)
            timeFormatIs24 = KeychainWrapper.standard.bool(forKey: UserDefaultKey.TIME_FORMAT + userId) ?? true
            securityPasscode = KeychainWrapper.standard.bool(forKey: UserDefaultKey.SECURITY_PASSCODE + userId) ?? false
            securityPasscodeValue = KeychainWrapper.standard.string(forKey: UserDefaultKey.SECURITY_PASSCODE_VALUE + userId) ?? ""
            setCurrencyCodeSymb()
            isSettingsWasSet = true
        }
    }
    
     func savePasscode(passcodeValue : String, setPasscode : Bool) {
        securityPasscode = setPasscode
        securityPasscodeValue = passcodeValue
        KeychainWrapper.standard.set(setPasscode, forKey: UserDefaultKey.SECURITY_PASSCODE + userId)
        KeychainWrapper.standard.set(passcodeValue, forKey: UserDefaultKey.SECURITY_PASSCODE_VALUE + userId)
    }
    
     func saveTimeFormat(is24 : Bool) {
        timeFormatIs24 = is24
        KeychainWrapper.standard.set(is24, forKey: UserDefaultKey.TIME_FORMAT + userId)
    }
    
     func saveCurrencyCode(currencyCode: String) {
        self.currencyCode = currencyCode
        setCurrencyCodeSymb()
        KeychainWrapper.standard.set(currencyCode, forKey: UserDefaultKey.CURRENCY_CODE + userId)
    }
    
     func saveSymbCount(symbCount : Int32) {
        self.symbCount = symbCount
        KeychainWrapper.standard.set(Int(symbCount), forKey: UserDefaultKey.SYMB_COUNT + userId)
    }
    
//     func saveBtcPasswordWallet(password : String) {
//        self.passwordBtcWallet = password
//        KeychainWrapper.standard.set(password, forKey: UserDefaultKey.PASSWORD_BTC_WALLET + userId)
//    }
    
//     func saveSeed(rowSeed : String) {
//        self.rowSeed = rowSeed
//        self.isBackupBtcWallet = false
//        KeychainWrapper.standard.set(rowSeed, forKey: UserDefaultKey.ROW_SEED_FOR_BACKUP + userId)
//        KeychainWrapper.standard.set(false, forKey: UserDefaultKey.IS_BTC_WALLET_BACKUP + userId)
//    }
//
//     func backUpBtcWallet() {
//        self.isBackupBtcWallet = true
//        self.rowSeed = ""
//        KeychainWrapper.standard.removeObject(forKey: UserDefaultKey.ROW_SEED_FOR_BACKUP + userId)
//        KeychainWrapper.standard.set(true, forKey: UserDefaultKey.IS_BTC_WALLET_BACKUP + userId)
//    }
    
     func saveEthPasswordWallet(password : String) {
        self.passwordEthWallet = password
        KeychainWrapper.standard.set(password, forKey: UserDefaultKey.PASSWORD_ETH_WALLET + userId)
    }
    
    func savePmntPasswordWallet(password : String, isCreatedFromEth : Bool) {
        self.passwordPmntWallet = password
        self.isPmntCreatedFromEth = isCreatedFromEth
        KeychainWrapper.standard.set(isCreatedFromEth, forKey: UserDefaultKey.IS_PMNT_CREATED_FROM_ETH + userId)
        KeychainWrapper.standard.set(password, forKey: UserDefaultKey.PASSWORD_PMNT_WALLET + userId)
    }
    
     func backUpEthWallet() {
        self.isBackupEthWallet = true
        KeychainWrapper.standard.set(true, forKey: UserDefaultKey.IS_ETH_WALLET_BACKUP + userId)
    }
    
     func backUpPmntWallet() {
        self.isBackupPmntWallet = true
        KeychainWrapper.standard.set(true, forKey: UserDefaultKey.IS_PMNT_WALLET_BACKUP + userId)
    }
    
     func deleteEthWallet() {
        self.isBackupEthWallet = false
        self.passwordEthWallet = ""
        KeychainWrapper.standard.set(false, forKey: UserDefaultKey.IS_ETH_WALLET_BACKUP + userId)
        KeychainWrapper.standard.set("", forKey: UserDefaultKey.PASSWORD_ETH_WALLET + userId)
    }
    
     func deletePmntWallet() {
        self.isBackupPmntWallet = false
        self.passwordPmntWallet = ""
        KeychainWrapper.standard.set(false, forKey: UserDefaultKey.IS_PMNT_WALLET_BACKUP + userId)
        KeychainWrapper.standard.set("", forKey: UserDefaultKey.PASSWORD_PMNT_WALLET + userId)
    }
    

     func clearConfig() {
        isAuthenticated = false
        currentUser = nil
        notificationWorry = true
        notificationVibration = true
//        notificationTransactions = false
//        notificationMessageSound = "Note.mp3"
        securityPasscode = false
        securityPasscodeValue = ""
        timeFormatIs24 = true
        currencyCode = "USD"
        passwordBtcWallet = ""
        passwordEthWallet = ""
        passwordPmntWallet = ""
        symbCount = 2
//        rowSeed = ""
        isBackupEthWallet = false
        isBackupPmntWallet = false
        isPmntCreatedFromEth = false
//        isBackupBtcWallet = false
        
        CacheManager.shared.removeDb()
        
        EthereumManager.shared.deinitWallet()
        isSettingsWasSet = false
        saveConfig()
    }
}
