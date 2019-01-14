//
//  EthTxInfoViewController.swift
//  paymon
//
//  Created by Maxim Skorynin on 25/12/2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation
import UIKit

class EthTxInfoViewController : PaymonViewController, UITableViewDelegate, UITableViewDataSource  {
    @IBOutlet weak var tableView: UITableView!
    
    var txEth : EthTransaction!
    var txPmnt : PmntTransaction!
    var txInfo : [EthTxInfoData] = []
    
    var isPmnt = false
    
    override func viewDidLoad() {
        setLayoutOptions()
        tableView.delegate = self
        tableView.dataSource = self
        
        txInfo.append(EthTxInfoData(title: "Hash".localized, info: !isPmnt ? txEth.hash : txPmnt.hash))
        txInfo.append(EthTxInfoData(title: "Confirmations".localized, info: !isPmnt ? txEth.confirmations : txPmnt.confirmations))
        txInfo.append(EthTxInfoData(title: "Date".localized, info: !isPmnt ? txEth.timeStamp : txPmnt.timeStamp))
        txInfo.append(EthTxInfoData(title: "From".localized, info: !isPmnt ? txEth.from : txPmnt.from))
            txInfo.append(EthTxInfoData(title: "To".localized, info: !isPmnt ? txEth.to : txPmnt.to))
        txInfo.append(EthTxInfoData(title: "Value".localized, info: !isPmnt ? txEth.value : txPmnt.value))
        txInfo.append(EthTxInfoData(title: "Gas Limit".localized, info: !isPmnt ? txEth.gas : txPmnt.gas))
        txInfo.append(EthTxInfoData(title: "Gas Used By Transaction".localized, info: !isPmnt ? txEth.gasUsed : txPmnt.gasUsed))
        txInfo.append(EthTxInfoData(title: "Gas Price".localized, info: !isPmnt ? txEth.gasPrice : txPmnt.gasPrice))

        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return txInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "txInfoCell") as? TxInfoTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(isPmnt : self.isPmnt, data: txInfo[indexPath.row], row: indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let alert = UIAlertController(title: "Etherscan info".localized, message: "Open in browser?".localized, preferredStyle: .alert)
            let ok = UIAlertAction(title: "Open".localized, style: .default, handler: { _ in
                if let hash = self.txInfo[0].info {
                    UIApplication.shared.open(URL(string: "https://etherscan.io/tx/\(hash)")!, options: [:], completionHandler: nil)
                }
            })
            let cancel = UIAlertAction(title: "Cancel".localized, style: .default, handler: nil)
            alert.addAction(cancel)
            alert.addAction(ok)
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func setLayoutOptions() {
        self.title = "Информация о транзакции"
        self.view.setGradientLayer(frame: self.view.bounds, topColor: UIColor.AppColor.Black.primaryBlackLight.cgColor, bottomColor: UIColor.AppColor.Black.primaryBlack.cgColor)
    }
}

