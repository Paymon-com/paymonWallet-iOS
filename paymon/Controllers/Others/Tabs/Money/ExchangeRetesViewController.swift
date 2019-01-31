//
//  ExchangeRetesViewController.swift
//  paymon
//
//  Created by Maxim Skorynin on 03.08.2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import UIKit

class ExchangeRetesViewController: PaymonViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var titleLabel: UITableView!
    
    @IBOutlet weak var ratesTableView: UITableView!
    
    var exchangeRates : [ExchangeRate] = []
    var showExchangeRates : [ExchangeRate] = []
    
    @IBAction func updateClick(_ sender: Any) {
        exchangeRates.removeAll()
        DispatchQueue.main.async {
            self.ratesTableView.reloadData()
            self.loading.startAnimating()
        }
        ExchangeRateParser.shared.parseAllExchangeRates() { result in
            self.exchangeRates = result
            self.showExchangeRates = result
            DispatchQueue.main.async {
                self.ratesTableView.reloadData()
                self.loading.stopAnimating()
            }
        }
    }
    
    func filterRates(currency : String) -> [ExchangeRate] {
        guard let filteredArray = self.exchangeRates.filter({transaction -> Bool in
            return transaction.fiat == currency
        }) as [ExchangeRate]? else {return []}
        return filteredArray
    }
    
    @IBAction func filterClick(_ sender: Any) {
        let filterMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancel = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)
        
        let rub = UIAlertAction(title: Money.rub, style: .default, handler: { (alert: UIAlertAction!) -> Void in
            self.showExchangeRates = self.filterRates(currency: Money.rub)
            self.ratesTableView.reloadData()
            
        })
        let usd = UIAlertAction(title: Money.usd, style: .default, handler: { (alert: UIAlertAction!) -> Void in
            self.showExchangeRates = self.filterRates(currency: Money.usd)
            self.ratesTableView.reloadData()
        })
        
        let eur = UIAlertAction(title: Money.eur, style: .default, handler: { (alert: UIAlertAction!) -> Void in
            self.showExchangeRates = self.filterRates(currency: Money.eur)
            self.ratesTableView.reloadData()
        })
        
        let all = UIAlertAction(title: "All".localized, style: .default, handler: { (alert: UIAlertAction!) -> Void in
            self.showExchangeRates = self.exchangeRates
            self.ratesTableView.reloadData()
        })
        
        filterMenu.addAction(cancel)
        filterMenu.addAction(usd)
        filterMenu.addAction(rub)
        filterMenu.addAction(eur)
        filterMenu.addAction(all)
        
        if let popoverController = filterMenu.popoverPresentationController {
            popoverController.barButtonItem = (sender as! UIBarButtonItem)
        }
        
        self.present(filterMenu, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ratesTableView.delegate = self
        ratesTableView.dataSource = self
        
        self.loading.startAnimating()
        
        navigationBar.setTransparent()
        navigationBar.topItem?.title = "Exchange rates".localized

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        ExchangeRateParser.shared.parseAllExchangeRates() { result in
            self.exchangeRates = result
            self.showExchangeRates = result
            DispatchQueue.main.async {
                self.ratesTableView.reloadData()
                self.loading.stopAnimating()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! ExchangeRatesTableViewCell
        
        if let chartsRatesViewController = self.storyboard?.instantiateViewController(withIdentifier: "ChartsRatesViewController")
            as? ChartsRatesViewController {
            chartsRatesViewController.crypto = cell.cryptoLabel.text!
            chartsRatesViewController.fiat = cell.fiatLabel.text!
            self.present(chartsRatesViewController, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return showExchangeRates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellExchange") as! ExchangeRatesTableViewCell
        
        cell.amount.setTitle("\(showExchangeRates[row].value)", for: .normal)
        cell.cryptoLabel.text = showExchangeRates[row].crypto
        cell.fiatLabel.text = showExchangeRates[row].fiat
        
        return cell
        
    }
}
