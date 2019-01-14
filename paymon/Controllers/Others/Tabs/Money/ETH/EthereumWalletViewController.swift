//
//  EthereumWalletViewController.swift
//  paymon
//
//  Created by Maxim Skorynin on 23/11/2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation
import DeckTransition

class EthereumWalletViewController: PaymonViewController {
    
    @IBOutlet weak var tableTransactionsView: WalletTableInfoUIView!
    @IBOutlet weak var balanceView: UIView!
    @IBOutlet weak var fiatSymbol: UILabel!
    
    @IBOutlet weak var cryptoBalance: UILabel!
    
    @IBOutlet weak var fiatBalance: UILabel!
    private var walletWasCreated: NSObjectProtocol!
    private var updateBalance: NSObjectProtocol!
    @IBOutlet weak var needBackUp: UIButton!
    @IBOutlet weak var needBackUpHeight: NSLayoutConstraint!
    
    var publicKey : String!
    var isPmnt = false
    
    @IBAction func needBackUpClick(_ sender: Any) {
        self.showBackupWallet()
    }
    
    func showBackupWallet() {
        guard let backupViewController = self.storyboard?.instantiateViewController(withIdentifier: VCIdentifier.backupEthWalletViewController) as? BackupEthWalletViewController else {return}
            backupViewController.isPmnt = self.isPmnt
        self.navigationController?.pushViewController(backupViewController, animated: true)
    }
    
    @IBAction func qrCodeClick(_ sender: Any) {
        guard let keysViewController = StoryBoard.money.instantiateViewController(withIdentifier: VCIdentifier.keysViewController) as? KeysViewController else {return}
        keysViewController.keyValue = self.publicKey
        keysViewController.currency = Money.eth
        
        let transitionDelegate = DeckTransitioningDelegate()
        keysViewController.transitioningDelegate = transitionDelegate
        keysViewController.modalPresentationStyle = .custom
        present(keysViewController, animated: true, completion: nil)
    }
    
    @IBAction func funcsClick(_ sender: Any) {
        let funcsMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancel = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)
        let backup = UIAlertAction(title: "Backup".localized, style: .default, handler: { (alert: UIAlertAction!) -> Void in
            self.showBackupWallet()
        })
        let delete = UIAlertAction(title: "Delete".localized, style: .destructive, handler: { (alert: UIAlertAction!) -> Void in
            
            let alertRemove = UIAlertController(title: "Remove wallet".localized, message: "Before removing your wallet, make sure you back up your wallet".localized, preferredStyle: UIAlertController.Style.alert)
            
            alertRemove.addAction(UIAlertAction(title: "Backup".localized, style: .default, handler: { (action) in
                self.showBackupWallet()
            }))
            
            alertRemove.addAction(UIAlertAction(title: "Remove".localized, style: .default, handler: { (action) in
                if !self.isPmnt {
                    let alertController = UIAlertController(title: "Remove wallet".localized, message: "Enter password".localized, preferredStyle: .alert)
                    alertController.addTextField { textField in
                        textField.placeholder = "Password".localized
                        textField.isSecureTextEntry = true
                    }
                    let confirmAction = UIAlertAction(title: "OK", style: .default) { [weak alertController] _ in
                        guard let alertController = alertController, let textField = alertController.textFields?.first else { return }
                        if textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == User.shared.passwordEthWallet {
                            EthereumManager.shared.deleteEthWallet() { isDeleted in
                                if isDeleted {
                                    User.shared.deleteEthWallet()
                                    DispatchQueue.main.async {
                                        self.navigationController?.popViewController(animated: true)
                                    }
                                    self.navigationController?.popViewController(animated: true)
                                } else {
                                    _ = SimpleOkAlertController.init(title: "Remove wallet".localized, message: "Failed to delete wallet. Try later.".localized, vc: self)
                                }
                            }
                        } else {
                            _ = SimpleOkAlertController.init(title: "Remove wallet".localized, message: "Incorrect password".localized, vc: self)
                        }
                    }
                    let cancelAction = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)
                    alertController.addAction(confirmAction)
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                } else {
                    
                    let alertController = UIAlertController(title: "Remove wallet".localized, message: "Enter password".localized, preferredStyle: .alert)
                    alertController.addTextField { textField in
                        textField.placeholder = "Password".localized
                        textField.isSecureTextEntry = true
                    }
                    let confirmAction = UIAlertAction(title: "OK", style: .default) { [weak alertController] _ in
                        guard let alertController = alertController, let textField = alertController.textFields?.first else { return }
                        if textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == User.shared.passwordPmntWallet {
                            EthereumManager.shared.deletePmntWallet() { isDeleted in
                                if isDeleted {
                                    User.shared.deletePmntWallet()
                                    DispatchQueue.main.async {
                                        self.navigationController?.popViewController(animated: true)
                                    }
                                } else {
                                    _ = SimpleOkAlertController.init(title: "Remove wallet".localized, message: "Failed to delete wallet. Try later.".localized, vc: self)
                                }
                            }
                        } else {
                            _ = SimpleOkAlertController.init(title: "Remove wallet".localized, message: "Incorrect password".localized, vc: self)
                        }
                    }
                    let cancelAction = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)
                    alertController.addAction(confirmAction)
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                }
                
            }))
            alertRemove.addAction(UIAlertAction(title: "Cancel".localized, style: .destructive, handler: nil))
            
            DispatchQueue.main.async {
                self.present(alertRemove, animated: true) {
                    () -> Void in
                }
            }
        })
        
        
        let recovery = UIAlertAction(title: "Recovery".localized, style: .default, handler: { (alert: UIAlertAction!) -> Void in
            guard let restoreEthViewController = StoryBoard.ethereum.instantiateViewController(withIdentifier: VCIdentifier.restoreEthViewController) as? RestoreEthViewController else {return}
            restoreEthViewController.isPmnt = self.isPmnt
            self.navigationController?.pushViewController(restoreEthViewController, animated: true)
        })
        
        funcsMenu.addAction(cancel)
        funcsMenu.addAction(recovery)
        
        funcsMenu.addAction(backup)
        funcsMenu.addAction(delete)
        
        
        self.present(funcsMenu, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {

        setLayoutOptions()
        getWalletInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if fiatSymbol != nil {
            getWalletInfo()
        }
        
        if needBackUp != nil {
            if isPmnt {
                if User.shared.isPmntCreatedFromEth {
                    self.needBackUpHeight.constant = !User.shared.isBackupEthWallet ? 40 : 0
                } else {
                    self.needBackUpHeight.constant = !User.shared.isBackupPmntWallet ? 40 : 0
                }
            } else {
                self.needBackUpHeight.constant = !User.shared.isBackupEthWallet ? 40 : 0
            }
            
        }
        
        walletWasCreated = NotificationCenter.default.addObserver(forName: .ethWalletWasCreated, object: nil, queue: nil) {
            notification in
            self.dismiss(animated: true, completion: nil)
        }
        
        updateBalance = NotificationCenter.default.addObserver(forName: .updateBalance, object: nil, queue: nil) { notification in
            self.getWalletInfo()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(walletWasCreated)
        NotificationCenter.default.removeObserver(updateBalance)
    }
    
    func setLayoutOptions() {
        
        self.balanceView.layer.cornerRadius = 30
        let widthScreen = UIScreen.main.bounds.width
        
        self.balanceView.setGradientLayer(frame: CGRect(x: 0, y: 0, width: widthScreen, height: self.balanceView.frame.height), topColor: UIColor.AppColor.Blue.ethereumBalanceLight.cgColor, bottomColor: UIColor.AppColor.Blue.ethereumBalanceDark.cgColor)
        
        self.view.setGradientLayer(frame: self.view.bounds, topColor: UIColor.AppColor.Black.primaryBlackLight.cgColor, bottomColor: UIColor.AppColor.Black.primaryBlack.cgColor)
        
        self.title = !isPmnt ? "Ethereum wallet".localized : "Paymon Token wallet".localized
        self.needBackUp.layer.cornerRadius = needBackUp.frame.height/2
        self.needBackUp.setTitle("We strongly recommend making a backup!".localized, for: .normal)
        self.needBackUp.titleLabel?.numberOfLines = 0
        self.needBackUp.titleLabel?.textAlignment = .center
        self.needBackUp.titleLabel?.adjustsFontSizeToFitWidth = true
        
        self.needBackUp.setGradientLayer(frame: CGRect(x: 0, y: 0, width: widthScreen, height: self.needBackUp.frame.height), topColor: UIColor.white.cgColor, bottomColor: UIColor.AppColor.Blue.primaryBlueUltraLight.cgColor)
        self.needBackUpHeight.constant = !User.shared.isBackupEthWallet ? 40 : 0
        
    }
    
    func getWalletInfo() {
        DispatchQueue.main.async {
            self.fiatSymbol.text = User.shared.currencyCodeSymb
            self.cryptoBalance.text = !self.isPmnt ? String(format: "%.\(User.shared.symbCount)f", EthereumManager.shared.ethCryptoBalance) : String(format: "%.\(User.shared.symbCount)f", EthereumManager.shared.pmntCryptoBalance)

            self.fiatBalance.text = !self.isPmnt ? String(format: "%.2f", EthereumManager.shared.ethFiatBalance) : String(format: "%.2f", EthereumManager.shared.pmntFiatBalance)
        }
        publicKey = !self.isPmnt ? EthereumManager.shared.ethSender?.address : EthereumManager.shared.pmntSender?.address
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let transferViewController = segue.destination as? EthereumTransferViewController {
            transferViewController.publicKey = publicKey
        } else if let txViewController = segue.destination as? EthereumTransactionsViewController {
            if isPmnt {
                txViewController.isPmnt = true
            }
        }
    }
    
    @IBAction func unWindToFinance(_ segue: UIStoryboardSegue) {
        
    }
}
