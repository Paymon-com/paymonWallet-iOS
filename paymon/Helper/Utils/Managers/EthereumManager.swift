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
    
    var ethKs : EthereumKeystoreV3!
    var ethOldKs : EthereumKeystoreV3!
    
    var pmntKs : EthereumKeystoreV3!
    var pmntOldKs : EthereumKeystoreV3!
    
    var ethKeystoreManager : KeystoreManager!
    var pmntKeystoreManager : KeystoreManager!
    
    var ethBalance : BigUInt! = 0
    var pmntBalance : BigUInt! = 0

    var ethCryptoBalance : Double! = 0.0
    var pmntCryptoBalance : Double! = 0.0

    var ethWeb3 : Web3!
    var pmntWeb3 : Web3!
    
    let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    var ethKeyPath : String!
    var pmntKeyPath : String!

    var ethTransactions : [EthTransaction] = [] {
        didSet {
            self.updateEthBalance()
            NotificationCenter.default.post(name: .updateEthTransactions, object: nil)
        }
    }
    
    var pmntTransactions : [PmntTransaction] = [] {
        didSet {
            self.updatePmntBalance()
            NotificationCenter.default.post(name: .updateEthTransactions, object: nil)
        }
    }
    
    func walletDidCreated(currency : String) {
        DispatchQueue.main.async {
            ExchangeRateParser.shared.parseCourseForWallet(crypto: [Money.eth, Money.pmnt], fiat: User.shared.currencyCode)
            NotificationCenter.default.post(name: .ethWalletWasCreated, object: nil)
        }
    }
    
    var ethSender : Address? {
        didSet {
            walletDidCreated(currency : Money.eth)
        }
    }
    
    var pmntSender : Address? {
        didSet {
            walletDidCreated(currency : Money.pmnt)
        }
    }
    
    func fiatBalanceDidUpdate(currency : String) {
        DispatchQueue.main.async {
            if currency == Money.eth {
                CryptoManager.shared.ethInfoIsLoaded = true;
            } else {
                CryptoManager.shared.pmntInfoIsLoaded = true;
            }
            NotificationCenter.default.post(name: .updateBalance, object: nil)
        }
    }
    
    var ethFiatBalance : Double! = 0.0 {
        didSet {
            fiatBalanceDidUpdate(currency : Money.eth)
        }
    }
    
    var pmntFiatBalance : Double! = 0.0 {
        didSet {
            fiatBalanceDidUpdate(currency : Money.pmnt)
        }
    }
    
    var ethCourse : Double! {
        didSet {
            self.updateEthBalance()
        }
    }
    
    var pmntCourse : Double! {
        didSet {
            print(pmntCourse)
            self.updatePmntBalance()
        }
    }
    
    func deinitWallet() {
        ethSender = nil
        pmntSender = nil
    }
    
    func initWeb() {
        queue.qualityOfService = .background
        queue.maxConcurrentOperationCount = 1
        queue.addOperation {
            self.ethKeyPath = self.userDir + "/keystore_eth_\(User.shared.currentUser.id!)"+"/key_eth.json"
            self.ethKeystoreManager = KeystoreManager.managerForPath(self.userDir + "/keystore_eth_\(User.shared.currentUser.id!)")
            
            self.pmntKeyPath = self.userDir + "/keystore_pmnt_\(User.shared.currentUser.id!)"+"/key_pmnt.json"
            self.pmntKeystoreManager = KeystoreManager.managerForPath(self.userDir + "/keystore_pmnt_\(User.shared.currentUser.id!)")
            
            Web3.default = Web3(infura: .mainnet)
            self.ethWeb3 = Web3.default
            self.pmntWeb3 = Web3.default
            
            self.ethWeb3.addKeystoreManager(self.ethKeystoreManager!)
            self.pmntWeb3.addKeystoreManager(self.pmntKeystoreManager!)
        }
    }
    
    func initEthWallet() {
        initWeb()
        if ethSender == nil {
            queue.addOperation {
                if (self.ethKeystoreManager?.addresses.count == 0) {
                    return
                } else {
                    self.ethKs = self.ethKeystoreManager?.walletForAddress((self.ethKeystoreManager?.addresses[0])!) as? EthereumKeystoreV3
                }
                guard let EthSender = self.ethKs?.addresses.first else {return}
                self.ethSender = EthSender

                print("Eth sender \(EthSender)")
            }
        }
    }
    
    func initPmntWallet() {
        initWeb()
        if pmntSender == nil {
            queue.addOperation {
                if (self.pmntKeystoreManager?.addresses.count == 0) {
                    print("Cant create pmnt sender")

                    return
                } else {
                    self.pmntKs = self.pmntKeystoreManager?.walletForAddress((self.pmntKeystoreManager?.addresses[0])!) as? EthereumKeystoreV3
                }
                guard let PmntSender = self.pmntKs?.addresses.first else {return}
                self.pmntSender = PmntSender
                
                print("Eth sender \(PmntSender)")
            }
        }
    }
    
    
    
    func setETHSender() {
        guard let ETHSender = self.ethKs?.addresses.first else {return}
        self.ethSender = ETHSender
        print("ETH sender \(ETHSender)")
    }
    
    func setPmntSender() {
        guard let PmntSender = self.pmntKs?.addresses.first else {return}
        self.pmntSender = PmntSender
        print("PMNT sender \(PmntSender)")
    }
    
    func createEthWallet(password : String) {
        initWeb()
        queue.addOperation {
            if (self.ethKeystoreManager?.addresses.count == 0) {
                self.ethKs = try! EthereumKeystoreV3(password: password)
                let keydata = try! JSONEncoder().encode(self.ethKs!.keystoreParams)
                FileManager.default.createFile(atPath: self.ethKeyPath, contents: keydata, attributes: nil)
            } else {
                return
            }
            
            self.setETHSender()
        }
    }
    
    func createPmntWallet(password : String) {
        initWeb()
        queue.addOperation {
            if (self.pmntKeystoreManager?.addresses.count == 0) {
                self.pmntKs = try! EthereumKeystoreV3(password: password)
                let keydata = try! JSONEncoder().encode(self.pmntKs!.keystoreParams)
                FileManager.default.createFile(atPath: self.pmntKeyPath, contents: keydata, attributes: nil)
            } else {
                return
            }
            
            self.setPmntSender()
        }
    }
    
    func createPmntWalletByEthereum() {
        self.pmntKs = self.ethKs
        let keydata = try! JSONEncoder().encode(self.pmntKs!.keystoreParams)
        FileManager.default.createFile(atPath: self.pmntKeyPath, contents: keydata, attributes: nil)
        self.setPmntSender()
    }
    
    func getUrlEthWallet() -> URL? {
        if let url = URL(fileURLWithPath: self.ethKeyPath) as URL? {
            return url
        }
        return nil
    }
    
    func getUrlPmntWallet() -> URL? {
        if let url = URL(fileURLWithPath: self.pmntKeyPath) as URL? {
            return url
        }
        return nil
    }
    
    func deleteEthWallet(completionHandler: @escaping (Bool) -> ()) {
        queue.addOperation {
            do {
                try FileManager.default.removeItem(atPath: self.ethKeyPath)
                self.ethSender = nil
                completionHandler(true)
            } catch {
                completionHandler(false)
            }
        }
    }
    
    func deletePmntWallet(completionHandler: @escaping (Bool) -> ()) {
        queue.addOperation {
            do {
                try FileManager.default.removeItem(atPath: self.pmntKeyPath)
                self.pmntSender = nil
                completionHandler(true)
            } catch {
                completionHandler(false)
            }
        }
    }
    
    func restoreEthWallet(jsonData: Data, password : String, completionHandler: @escaping ((Bool,String)) -> ()) {
        initWeb()
        queue.addOperation {
            
            self.ethOldKs = self.ethKs
            self.ethKs = nil
            self.ethKs = EthereumKeystoreV3(jsonData)
            if self.ethKs != nil {
                do {
                    if let privateKey = try self.ethKs.UNSAFE_getPrivateKeyData(password: password, account: self.ethKs.addresses.first!) as Data? {
                        self.ethKs = try EthereumKeystoreV3(privateKey: privateKey, password: password)
                        
                        let keydata = try JSONEncoder().encode(self.ethKs!.keystoreParams)
                        FileManager.default.createFile(atPath: self.ethKeyPath, contents: keydata, attributes: nil)
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
                self.ethKs = self.ethOldKs
                print("error encode")
                completionHandler((false, RestoreResult.someError))

            }
        }
    }
    
    func restorePmntWallet(jsonData: Data, password : String, completionHandler: @escaping ((Bool,String)) -> ()) {
        initWeb()
        queue.addOperation {
            
            self.pmntOldKs = self.pmntKs
            self.pmntKs = nil
            self.pmntKs = EthereumKeystoreV3(jsonData)
            if self.pmntKs != nil {
                do {
                    if let privateKey = try self.pmntKs.UNSAFE_getPrivateKeyData(password: password, account: self.pmntKs.addresses.first!) as Data? {
                        self.pmntKs = try EthereumKeystoreV3(privateKey: privateKey, password: password)
                        
                        let keydata = try JSONEncoder().encode(self.pmntKs!.keystoreParams)
                        FileManager.default.createFile(atPath: self.pmntKeyPath, contents: keydata, attributes: nil)
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
                self.pmntKs = self.pmntOldKs
                print("error encode")
                completionHandler((false, RestoreResult.someError))
                
            }
        }
    }
    
    func updateEthTxHistory() {
        
        let urlString = "https://api.etherscan.io/api?module=account&action=txlist&address=\(String(describing: ethSender!.address))&startblock=0&endblock=999999999&sort=desc&apikey=YourApiKeyToken"
        Alamofire.request(urlString, method: .get).response(completionHandler: { response in
            if response.error == nil && response.data != nil {
                do {
//                    guard let json = try JSONSerialization.jsonObject(with: response.data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any] else {return}
//                    print(json)
                    let ethResult : EthResult = try JSONDecoder().decode(EthResult.self, from: response.data!)
                    self.ethTransactions = ethResult.result
                } catch let error {
                    print("TxUpdate: Error decode json", error)
                }
            } else {
                print("Error parse http", response.error!)
            }
        })
    }
    
    func updatePmntTxHistory() {
        
        let urlString = "https://api.etherscan.io/api?module=account&action=tokentx&address=\(String(describing: pmntSender!.address))&startblock=0&endblock=999999999&sort=desc&apikey=YourApiKeyToken"
        Alamofire.request(urlString, method: .get).response(completionHandler: { response in
            if response.error == nil && response.data != nil {
                do {
                    guard let json = try JSONSerialization.jsonObject(with: response.data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any] else {return}
                    print(json)
                    let pmntResult : PmntResult = try JSONDecoder().decode(PmntResult.self, from: response.data!)
                    self.pmntTransactions = pmntResult.result
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
            if self.ethSender != nil {
                do {
                    let balance = try self.ethWeb3.eth.getBalance(address: self.ethSender!)
                    self.ethBalance = balance
                    self.ethCryptoBalance = Double(balance) / Money.fromWei
                    self.ethFiatBalance = self.ethCryptoBalance * self.ethCourse
                } catch let error {
                    print("Error get Balance for ETH", error)
                }
            }
        }
    }
    
    func updatePmntBalance() {
        queue.addOperation {
            if self.pmntSender != nil {
                let contract = ERC20(Money.pmntContract)
                do {
                    let PmntBalance = try contract.balance(of: self.pmntSender!)
                    self.pmntBalance = PmntBalance
                    self.pmntCryptoBalance = Double(self.pmntBalance) / Money.fromGwei
                    self.pmntFiatBalance = self.pmntCryptoBalance * self.pmntCourse
                } catch let error {
                    print("Error get Balance for Pmnt contract", error)
                }
                
                if self.ethSender == nil {
                    do {
                        let balance = try self.pmntWeb3.eth.getBalance(address: self.pmntSender!)
                        self.ethBalance = balance
                        self.ethCryptoBalance = Double(balance) / Money.fromWei
                        self.ethFiatBalance = self.ethCryptoBalance * self.ethCourse
                    } catch let error {
                        print("Error get Balance for ETH", error)
                    }
                }
            }
        }
    }
    
    func sendEth(gasPrice : BigUInt, gasLimit : Int64, value : Int64, toAddress : String, password : String, completionHandler: @escaping ((Bool,String)) -> ()) {
        queue.addOperation {
            let coldWalletABI = "[{\"payable\":true,\"type\":\"fallback\"}]"
            var options = Web3Options.default
            options.gasPrice = gasPrice
            options.gasLimit = BigUInt(gasLimit)
            options.value = BigUInt(value)
            options.from = self.ethSender
            options.to = Address(toAddress)
            let estimatedGas = try! self.ethWeb3.contract(coldWalletABI, at: self.ethSender).method(options: options).estimateGas(options: nil)
            options.gasLimit = estimatedGas
            let intermediateSend = try! self.ethWeb3.contract(coldWalletABI, at: self.ethSender).method(options: options)
            let sendingResult = try! intermediateSend.send(password: password)
            let txid = sendingResult.hash
            print("On Rinkeby TXid = " + txid)
            completionHandler((true, txid))
        }
    }
    
    func sendPmnt(gasPrice : BigUInt, gasLimit : Int64, value : Int64, toAddress : String, password : String, completionHandler: @escaping (Bool,String) -> ()) {
        queue.addOperation {
            let token = ERC20(Money.pmntContract, from: self.pmntSender!, password: password)
            token.options.gasPrice = gasPrice
            token.options.gasLimit = BigUInt(gasLimit)
            do {
                let transaction = try token.transfer(to: Address(toAddress), amount: NaturalUnits("\(value)"))
                print("On Paymon token TXid = \(transaction.hash)")
                completionHandler(true, transaction.hash)
            } catch let error {
                print("cant send pmnt \(error)")
                completionHandler(false, "")
            }
        }
    }
}
