//
//  EthTransaction.swift
//  paymon
//
//  Created by Maxim Skorynin on 26/11/2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation
import BlockiesSwift

public class EthTransaction : Codable {
    var blockNumber : String
    var timeStamp : String
    var hash : String
    var nonce : String
    var from : String
    var to : String
    var value : String
    var gas : String
    var gasPrice : String
    var isError : String
    var gasUsed : String
    var confirmations : String
}

public class PmntTransaction : Codable {
    var blockNumber : String
    var timeStamp : String
    var hash : String
    var nonce : String
    var from : String
    var to : String
    var contractAddress : String
    var value : String
    var tokenSymbol : String
    var gas : String
    var gasPrice : String
    var gasUsed : String
    var confirmations : String
}

public class EthResult : Codable {
    let result: [EthTransaction]
}

public class PmntResult : Codable {
    let result : [PmntTransaction]
}

class EthTransactions {
    
    public class func getTransactions(isPmnt : Bool, completionHandler: @escaping ([Transaction]) -> ()){
        var result : [Transaction] = []
        
        if !isPmnt {
            for tx in EthereumManager.shared.ethTransactions {
                
                let blockies = Blockies(seed: tx.from)
                var image = UIImage()
                if let bimage = blockies.createImage() {
                    image = bimage
                }
                
                let transactionType : TransactionType = tx.from.lowercased() == EthereumManager.shared.ethSender!.address.lowercased() ? .sent : .received
                let value = Decimal(tx.value) / Decimal(Money.fromWei)
                
                result.append(Transaction(type: transactionType, from: tx.from, amount: String(value.double), time: Utils.formatDateTime(timestamp: Int32(tx.timeStamp)!), avatar: image, txEthInfo : tx, txPmntInfo: nil))
            }
        } else {
            for tx in EthereumManager.shared.pmntTransactions {
                
                let blockies = Blockies(seed: tx.from)
                var image = UIImage()
                if let bimage = blockies.createImage() {
                    image = bimage
                }
                
                let transactionType : TransactionType = tx.from.lowercased() == EthereumManager.shared.ethSender!.address.lowercased() ? .sent : .received
                let value = Decimal(tx.value) / Decimal(Money.fromGwei)
                
                result.append(Transaction(type: transactionType, from: tx.from, amount: String(value.double), time: Utils.formatDateTime(timestamp: Int32(tx.timeStamp)!), avatar: image, txEthInfo : nil, txPmntInfo: tx))
            }
        }
        
        completionHandler(result)
    }
}
