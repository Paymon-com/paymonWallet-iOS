//
//  MoneyViewController.swift
//  paymon
//
//  Created by Maxim Skorynin on 01.08.2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import UIKit

class MoneyViewController: PaymonViewController, UITableViewDelegate, UITableViewDataSource {
    
    var moneyArray : [CellMoneyData]!
    
    @IBOutlet weak var moneyTableView: UITableView!
    private var walletWasCreated: NSObjectProtocol!
    private var updateBalance: NSObjectProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        ExchangeRateParser.shared.parseCourseForWallet(crypto: Money.eth, fiat: User.shared.currencyCode)

        moneyTableView.delegate = self
        moneyTableView.dataSource = self

        navigationItem.title = "Wallet".localized
        
        self.view.setGradientLayer(frame: self.view.bounds, topColor: UIColor.AppColor.Black.primaryBlackLight.cgColor, bottomColor: UIColor.AppColor.Black.primaryBlack.cgColor)
        
        moneyArray = [CellMoneyData]()
        getWalletsInfo()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(walletWasCreated)
        NotificationCenter.default.removeObserver(updateBalance)
    }
    
    func getWalletsInfo() {
        if moneyArray != nil {
            moneyArray.removeAll()
            /* We get the data using the class CryptoManager*/
//            moneyArray.append(CryptoManager.shared.getBitcoinWalletInfo())
            moneyArray.append(CryptoManager.shared.getEthereumWalletInfo())
            moneyArray.append(CryptoManager.shared.getPaymonWalletInfo())
        }
        DispatchQueue.main.async {
            if self.moneyTableView != nil {
                self.moneyTableView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getWalletsInfo()
        walletWasCreated = NotificationCenter.default.addObserver(forName: .ethWalletWasCreated, object: nil, queue: nil) {
            notification in

            self.getWalletsInfo()
        }
        
        updateBalance = NotificationCenter.default.addObserver(forName: .updateBalance, object: nil, queue: nil) {
            notification in
            print("update balance")
            self.getWalletsInfo()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return moneyArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let data = moneyArray[indexPath.row] as? CellCreatedMoneyData {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellCreated") as? MoneyCreatedTableViewCell else {return UITableViewCell()}
            cell.configure(data: data)
            return cell
            
        } else {
            let data = moneyArray[indexPath.row]
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellNotCreated") as? MoneyNotCreatedTableViewCell else {return UITableViewCell()}
            cell.configure(data: data, vc: self)
            return cell
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            if let cell = tableView.cellForRow(at: indexPath) as? MoneyCreatedTableViewCell {
                
                switch cell.cryptoType {
                case .paymon?:
                    if CryptoManager.shared.pmntInfoIsLoaded {
                        guard let ethereumWalletViewController = StoryBoard.ethereum.instantiateViewController(withIdentifier: VCIdentifier.ethereumWalletViewController) as? EthereumWalletViewController else {return}
                        ethereumWalletViewController.isPmnt = true
                        
                        DispatchQueue.main.async {
                            self.navigationController?.pushViewController(ethereumWalletViewController, animated: true)
                        }
                    } else {
                        print("eth info dont loaded")
                    }
                case .ethereum?:
                    if CryptoManager.shared.ethInfoIsLoaded {
                        guard let ethereumWalletViewController = StoryBoard.ethereum.instantiateViewController(withIdentifier: VCIdentifier.ethereumWalletViewController) as? EthereumWalletViewController else {return}
                        
                        DispatchQueue.main.async {
                            self.navigationController?.pushViewController(ethereumWalletViewController, animated: true)
                        }
                    } else {
                        print("eth info dont loaded")
                    }
                default:
                    break
                }
                
            }
        }
    }
}
