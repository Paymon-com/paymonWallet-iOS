//
//  ExchangeRatesParser.swift
//  ExchangeRatesParser
//
//  Created by Maxim Skorynin on 10.07.2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

struct ExchangeRate {
    let crypto : String
    let fiat : String
    let value : Double
}

class ExchangeRateParser{
    
    static let shared = ExchangeRateParser()
    
    func parseCourse(crypto: String, fiat: String, completionHandler: @escaping (Double) -> ()) {
        var result : Double!
        
        let urlString = "https://min-api.cryptocompare.com/data/pricemulti?fsyms=\(crypto)&tsyms=\(fiat)"
        Alamofire.request(urlString, method: .get).response(completionHandler: { response in
            if response.error == nil && response.data != nil{
            
            do {
                guard let json = try JSONSerialization.jsonObject(with: response.data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any] else {return}
                if let rates = json[crypto] as? [String: Any] {
                    result = rates[fiat] as? Double
                }
                completionHandler(result)
                
            } catch let jsonError{
                print("Error srializing json:", jsonError)
            }
            
            } else {
                print("Error parse http", response.error!)
            }
        })
    }
    
    func parseCourseForWallet(crypto: String, fiat: String) {
        let urlString = "https://min-api.cryptocompare.com/data/pricemulti?fsyms=\(crypto)&tsyms=\(fiat)"
        Alamofire.request(urlString, method: .get).response(completionHandler: { response in
            if response.error == nil && response.data != nil {
                do {
                    guard let json = try JSONSerialization.jsonObject(with: response.data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any] else {return}
                    if let rates = json[crypto] as? [String: Any] {
                        if let result = rates[fiat] as? Double {
                            switch crypto {
                            case Money.eth: EthereumManager.shared.ethCourse = result
                            case Money.pmnt: EthereumManager.shared.pmntCourse = result
                            default: break
                            }
                        }
                    }
                    
                } catch let jsonError{
                    print("Error srializing json:", jsonError)
                }
            } else {
                print("Error parse http", response.error!)
            }
        })
    }
    
    func parseAllExchangeRates(completionHandler: @escaping ([ExchangeRate]) -> ()){
        var result : [ExchangeRate] = [ExchangeRate]()
        
        let urlString = "https://min-api.cryptocompare.com/data/pricemulti?fsyms=BTC,ETH,PMNT&tsyms=USD,EUR,RUB"
        Alamofire.request(urlString, method: .get).response(completionHandler: { response in
            if response.error == nil && response.data != nil {
                do {
                    guard let json = try JSONSerialization.jsonObject(with: response.data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any] else {return}
                    if let rates = json[Money.btc] as? [String: Any] {
                        for rate in rates {
                            result.append(ExchangeRate(crypto: Money.btc, fiat: rate.key, value: rate.value as? Double ?? Double(rate.value as! Int)))
                        }
                    }
                    
                    if let rates = json[Money.eth] as? [String: Any] {
                        for rate in rates {
                            result.append(ExchangeRate(crypto: Money.eth, fiat: rate.key, value: rate.value as? Double ?? Double(rate.value as! Int)))
                        }
                    }
                    
                    if let rates = json[Money.pmnt] as? [String: Any] {
                        for rate in rates {
                            result.append(ExchangeRate(crypto: Money.pmnt, fiat: rate.key, value: rate.value as? Double ?? Double(rate.value as! Int)))
                        }
                    }
                    completionHandler(result)
                    
                } catch let jsonError{
                    print("Error srializing json:", jsonError)
                }
                
            } else {
                print("Error parse http", response.error!)
            }
        })
            
    }
}
