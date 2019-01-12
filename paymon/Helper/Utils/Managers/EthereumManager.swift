//
// Created by Vladislav on 06/12/2017.
// Copyright (c) 2017 Semen Gleym. All rights reserved.
//

import Foundation
import BigInt
import web3swift
import Alamofire

struct RestoreResult {
    static let success = "success"
    static let errorPassword = "errorPassword"
    static let invalidAccount = "invalidAccount"
    static let someError = "someError"
    static let errorEncode = "errorEncode"
}

class EthereumManager {
    
    static let shared = EthereumManager()
    
    let queue = OperationQueue()
    
    var EthKs : EthereumKeystoreV3!
    var EthOldKs : EthereumKeystoreV3!
    
    var PmntKs : EthereumKeystoreV3!
    var PmntOldKs : EthereumKeystoreV3!
    
    var EthKeystoreManager : KeystoreManager!
    var PmntKeystoreManager : KeystoreManager!
    
    var EthBalance : BigUInt! = 0
    var PmntBalance : BigUInt! = 0

    var EthCryptoBalance : Double! = 0.0
    var PmntCryptoBalance : Double! = 0.0

    var web3 : Web3!
    
    let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    var EthKeyPath : String!
    var PmntKeyPath : String!

    var transactions : [EthTransaction] = [] {
        didSet {
            self.updateEthBalance()
            NotificationCenter.default.post(name: .updateEthTransactions, object: nil)
        }
    }
    
    func walletDidCreated() {
        DispatchQueue.main.async {
            ExchangeRateParser.shared.parseCourseForWallet(crypto: Money.pmnt, fiat: User.currencyCode)
            NotificationCenter.default.post(name: .ethWalletWasCreated, object: nil)
        }
    }
    
    var EthSender : Address? {
        didSet {
            walletDidCreated()
        }
    }
    
    var PmntSender : Address? {
        didSet {
            walletDidCreated()
        }
    }
    
    func fiatBalanceDidUpdate() {
        DispatchQueue.main.async {
            CryptoManager.shared.ethInfoIsLoaded = true;
            NotificationCenter.default.post(name: .updateBalance, object: nil)
        }
    }
    
    var EthFiatBalance : Double! = 0.0 {
        didSet {
            fiatBalanceDidUpdate()
        }
    }
    
    var PmntFiatBalance : Double! = 0.0 {
        didSet {
            fiatBalanceDidUpdate()
        }
    }
    
    var EthCourse : Double! {
        didSet {
            self.updateEthBalance()
        }
    }
    
    var PmntCourse : Double! {
        didSet {
            self.updatePmntBalance()
        }
    }
    
    func initWeb() {
        queue.qualityOfService = .background
        queue.maxConcurrentOperationCount = 1
        queue.addOperation {
            self.EthKeyPath = self.userDir + "/keystore_\(User.currentUser.id!)"+"/key_eth.json"
            self.EthKeystoreManager = KeystoreManager.managerForPath(self.userDir + "/keystore_eth_\(User.currentUser.id!)")
            
            self.PmntKeyPath = self.userDir + "/keystore_\(User.currentUser.id!)"+"/key_pmnt.json"
            self.PmntKeystoreManager = KeystoreManager.managerForPath(self.userDir + "/keystore_pmnt_\(User.currentUser.id!)")
            
            Web3.default = Web3(infura: .mainnet)
            self.web3 = Web3.default
            self.web3.addKeystoreManager(self.EthKeystoreManager!)
            self.web3.addKeystoreManager(self.PmntKeystoreManager!)
        }
    }
    
    func initEthWallet() {
        initWeb()
        if EthSender == nil {
            queue.addOperation {
                if (self.EthKeystoreManager?.addresses.count == 0) {
                    return
                } else {
                    self.EthKs = self.EthKeystoreManager?.walletForAddress((self.EthKeystoreManager?.addresses[0])!) as? EthereumKeystoreV3
                }
                guard let EthSender = self.EthKs?.addresses.first else {return}
                self.EthSender = EthSender

                print("Eth sender \(EthSender)")
            }
        }
    }
    
    func initPmntWallet() {
        initWeb()
        if PmntSender == nil {
            queue.addOperation {
                if (self.PmntKeystoreManager?.addresses.count == 0) {
                    return
                } else {
                    self.PmntKs = self.PmntKeystoreManager?.walletForAddress((self.PmntKeystoreManager?.addresses[0])!) as? EthereumKeystoreV3
                }
                guard let PmntSender = self.PmntKs?.addresses.first else {return}
                self.PmntSender = PmntSender
                
                print("Eth sender \(PmntSender)")
            }
        }
    }
    
    
    
    func setETHSender() {
        guard let ETHSender = self.EthKs?.addresses.first else {return}
        self.EthSender = ETHSender
        print("ETH sender \(ETHSender)")
    }
    
    func setPmntSender() {
        guard let PmntSender = self.PmntKs?.addresses.first else {return}
        self.PmntSender = PmntSender
        print("PMNT sender \(PmntSender)")
    }
    
    func createEthWallet(password : String) {
        initWeb()
        queue.addOperation {
            if (self.EthKeystoreManager?.addresses.count == 0) {
                self.EthKs = try! EthereumKeystoreV3(password: password)
                let keydata = try! JSONEncoder().encode(self.EthKs!.keystoreParams)
                FileManager.default.createFile(atPath: self.EthKeyPath, contents: keydata, attributes: nil)
            } else {
                return
            }
            
            self.setETHSender()
        }
    }
    
    func createPmntWallet(password : String) {
        initWeb()
        queue.addOperation {
            if (self.PmntKeystoreManager?.addresses.count == 0) {
                self.PmntKs = try! EthereumKeystoreV3(password: password)
                let keydata = try! JSONEncoder().encode(self.PmntKs!.keystoreParams)
                FileManager.default.createFile(atPath: self.PmntKeyPath, contents: keydata, attributes: nil)
            } else {
                return
            }
            
            self.setPmntSender()
        }
    }
    
    func getUrlEthWallet() -> URL? {
        if let url = URL(fileURLWithPath: self.EthKeyPath) as URL? {
            return url
        }
        return nil
    }
    
    func getUrlPmntWallet() -> URL? {
        if let url = URL(fileURLWithPath: self.PmntKeyPath) as URL? {
            return url
        }
        return nil
    }
    
    func deleteEthWallet(completionHandler: @escaping (Bool) -> ()) {
        queue.addOperation {
            do {
                try FileManager.default.removeItem(atPath: self.EthKeyPath)
                self.EthSender = nil
                completionHandler(true)
            } catch {
                completionHandler(false)
            }
        }
    }
    
    func deletePmntWallet(completionHandler: @escaping (Bool) -> ()) {
        queue.addOperation {
            do {
                try FileManager.default.removeItem(atPath: self.PmntKeyPath)
                self.PmntSender = nil
                completionHandler(true)
            } catch {
                completionHandler(false)
            }
        }
    }
    
    func restoreEthWallet(jsonData: Data, password : String, completionHandler: @escaping ((Bool,String)) -> ()) {
        initWeb()
        queue.addOperation {
            
            self.EthOldKs = self.EthKs
            self.EthKs = nil
            self.EthKs = EthereumKeystoreV3(jsonData)
            if self.EthKs != nil {
                do {
                    if let privateKey = try self.EthKs.UNSAFE_getPrivateKeyData(password: password, account: self.EthKs.addresses.first!) as Data? {
                        self.EthKs = try EthereumKeystoreV3(privateKey: privateKey)
                        
                        let keydata = try JSONEncoder().encode(self.EthKs!.keystoreParams)
                        FileManager.default.createFile(atPath: self.EthKeyPath, contents: keydata, attributes: nil)
                        self.setETHSender()

                        completionHandler((true, RestoreResult.success))
                    }
                } catch AbstractKeystoreError.invalidPasswordError {
                    print("Error restore wallet: invalidPasswordError")
                    completionHandler((false, RestoreResult.errorPassword))

                } catch AbstractKeystoreError.invalidAccountError {
                    print("Error restore wallet: invalidAccountError")
                    completionHandler((false, RestoreResult.invalidAccount))

                } catch EncodingError.invalidValue {
                    completionHandler((false, RestoreResult.errorEncode))

                    print("Error restore wallet(encode): EncodingError.invalidValue")
                } catch let error {
                    completionHandler((false, RestoreResult.someError))

                    print("Some error: ", error)

                }
            } else {
                self.EthKs = self.EthOldKs
                print("error encode")
                completionHandler((false, RestoreResult.someError))

            }
        }
    }
    
    func restorePmntWallet(jsonData: Data, password : String, completionHandler: @escaping ((Bool,String)) -> ()) {
        initWeb()
        queue.addOperation {
            
            self.PmntOldKs = self.PmntKs
            self.PmntKs = nil
            self.PmntKs = EthereumKeystoreV3(jsonData)
            if self.PmntKs != nil {
                do {
                    if let privateKey = try self.PmntKs.UNSAFE_getPrivateKeyData(password: password, account: self.PmntKs.addresses.first!) as Data? {
                        self.PmntKs = try EthereumKeystoreV3(privateKey: privateKey)
                        
                        let keydata = try JSONEncoder().encode(self.PmntKs!.keystoreParams)
                        FileManager.default.createFile(atPath: self.PmntKeyPath, contents: keydata, attributes: nil)
                        self.setPmntSender()
                        
                        completionHandler((true, RestoreResult.success))
                    }
                } catch AbstractKeystoreError.invalidPasswordError {
                    print("Error restore wallet: invalidPasswordError")
                    completionHandler((false, RestoreResult.errorPassword))
                    
                } catch AbstractKeystoreError.invalidAccountError {
                    print("Error restore wallet: invalidAccountError")
                    completionHandler((false, RestoreResult.invalidAccount))
                    
                } catch EncodingError.invalidValue {
                    completionHandler((false, RestoreResult.errorEncode))
                    
                    print("Error restore wallet(encode): EncodingError.invalidValue")
                } catch let error {
                    completionHandler((false, RestoreResult.someError))
                    
                    print("Some error: ", error)
                }
            } else {
                self.PmntKs = self.PmntOldKs
                print("error encode")
                completionHandler((false, RestoreResult.someError))
                
            }
        }
    }
    
    func updateTxHistory() {
        
        let urlString = "https://api-rinkeby.etherscan.io/api?module=account&action=txlist&address=\(EthSender!.address)&startblock=0&endblock=99999999&sort=desc&apikey=YourApiKeyToken"
        Alamofire.request(urlString, method: .get).response(completionHandler: { response in
            if response.error == nil && response.data != nil {
                do {
//                    guard let json = try JSONSerialization.jsonObject(with: response.data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any] else {return}
//                    print(json)
                    let ethResult : EthResult = try JSONDecoder().decode(EthResult.self, from: response.data!)
                    self.transactions = ethResult.result
                } catch let error {
                    print("TxUpdate: Error decode json", error)
                }
            } else {
                print("Error parse http", response.error!)
            }
        })
    }
    
    func updateEthBalance() {
        queue.addOperation {
            if self.EthSender != nil {
                let balance = try! self.web3.eth.getBalance(address: self.EthSender!)
                self.EthBalance = balance
                self.EthCryptoBalance = Double(balance) / Money.fromWei
                self.EthFiatBalance = self.EthCryptoBalance * self.EthCourse
                //TODO вылетало
            }
        }
    }
    
    func updatePmntBalance() {
        queue.addOperation {
            if self.PmntSender != nil {
                let contract = ERC20(Money.pmntContract)
                do {
                    let PmntBalance = try contract.balance(of: self.PmntSender!)
                    
                    print("PMNT balance \(PmntBalance)")
                    self.PmntBalance = PmntBalance
                    self.PmntCryptoBalance = Double(self.EthCryptoBalance) / Money.fromWei
                    self.PmntFiatBalance = self.PmntCryptoBalance * self.PmntCourse
                } catch let error {
                    print("Error get Balance for Pmnt contract", error)
                }
            }
        }
    }
    
    func send(gasPrice : BigUInt, gasLimit : Int64, value : Int64, toAddress : String, password : String, completionHandler: @escaping ((Bool,String)) -> ()) {
        queue.addOperation {
            let coldWalletABI = "[{\"payable\":true,\"type\":\"fallback\"}]"
            var options = Web3Options.default
            options.gasPrice = gasPrice
            options.gasLimit = BigUInt(gasLimit)
            options.value = BigUInt(value)
            options.from = self.EthSender
            options.to = Address(toAddress)
            let estimatedGas = try! self.web3.contract(coldWalletABI, at: self.EthSender).method(options: options).estimateGas(options: nil)
            options.gasLimit = estimatedGas
            let intermediateSend = try! self.web3.contract(coldWalletABI, at: self.EthSender).method(options: options)
            let sendingResult = try! intermediateSend.send(password: password)
            let txid = sendingResult.hash
            //TODO: Notif tx was sent
            print("On Rinkeby TXid = " + txid)
            completionHandler((true, txid))
        }
    }
}
