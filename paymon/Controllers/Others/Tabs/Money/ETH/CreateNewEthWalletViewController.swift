//
//  CreateNewEthWalletViewController.swift
//  paymon
//
//  Created by Maxim Skorynin on 22/11/2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation
import UIKit
import MBProgressHUD

class CreateNewEthWalletViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var hint: UILabel!
    @IBOutlet weak var repeatPassword: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var stackViews: UIView!
    @IBOutlet weak var passwordHint: UILabel!
    @IBOutlet weak var useMyEtherWallet: UIButton!
    @IBOutlet weak var hintUseMyEtherWallet: UILabel!
    
    var password : String! = ""
    var repeatPasswordString: String! = ""
    var isPmnt = false
    var isPmntCreatedFromEth = false
    
    private var ethwalletWasCreated: NSObjectProtocol!
    
    override func viewDidLoad() {
        ethwalletWasCreated = NotificationCenter.default.addObserver(forName: .ethWalletWasCreated, object: nil, queue: nil) {
            notification in
            self.walletCreated()
        }
        newPassword.delegate = self
        repeatPassword.delegate = self
        setLayoutOptions()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(ethwalletWasCreated)
    }
    
    func setLayoutOptions() {
        newPassword.placeholder = "New password".localized
        repeatPassword.placeholder = "Repeat password".localized
        passwordHint.text = "Create a password for new Ethereum wallet".localized
        hint.text = "Use this password when recovering your wallet and when sending tokens".localized
        hintUseMyEtherWallet.text = "If your PMNT tokens are stored on the main Ethereum wallet, click the \"Use my Etereum wallet\" button to display the PMNT wallet balance".localized
        useMyEtherWallet.setTitle("Use my Etereum wallet".localized, for: .normal)
        
        self.view.setGradientLayer(frame: self.view.bounds, topColor: UIColor.AppColor.Black.primaryBlackLight.cgColor, bottomColor: UIColor.AppColor.Black.primaryBlack.cgColor)
        
        if !isPmnt {
            self.title = "New Ethereum wallet".localized
        } else {
            if EthereumManager.shared.ethSender != nil {
                self.title = "New Paymon Token wallet".localized
                useMyEtherWallet.isHidden = false
                hintUseMyEtherWallet.isHidden = false
            }
        }
        
        stackViews.layer.cornerRadius = 30
        useMyEtherWallet.layer.cornerRadius = useMyEtherWallet.frame.height/2
    }
    
    func checkInputPassword() -> Bool {
        password = newPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        repeatPasswordString = repeatPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if password.isEmpty {
            newPassword.shake()
            return false
        }
        
        if repeatPasswordString.isEmpty || repeatPasswordString != password {
            repeatPassword.shake()
            return false
        }
        
        return true
    }
    
    @IBAction func createWallet(_ sender: Any) {
        
        if self.checkInputPassword() {
            DispatchQueue.main.async {
                let _ = MBProgressHUD.showAdded(to: self.view, animated: true)
            }
            
            if !isPmnt {
                EthereumManager.shared.createEthWallet(password: password)
            } else {
                EthereumManager.shared.createPmntWallet(password: password)
            }
        }
    }
    
    @IBAction func createPmntWalletByEther(_ sender: Any) {
        if self.checkInputPassword() {
            isPmntCreatedFromEth = true
            if User.shared.passwordEthWallet == self.password {
                DispatchQueue.main.async {
                    let _ = MBProgressHUD.showAdded(to: self.view, animated: true)
                    EthereumManager.shared.createPmntWalletByEthereum()
                }
            } else {
                _ = SimpleOkAlertController.init(title: "Restore wallet".localized, message: "Incorrect password".localized, vc: self)
            }
        }
    }
    
    func walletCreated() {
        DispatchQueue.main.async {
            if !self.isPmnt {
                User.shared.saveEthPasswordWallet(password: self.password)
            } else {
                User.shared.savePmntPasswordWallet(password: self.password, isCreatedFromEth: self.isPmntCreatedFromEth)
            }
            MBProgressHUD.hide(for: self.view, animated: true)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        
        switch (textField) {
        case newPassword:
            return newLength <= 96
        case repeatPassword:
            return newLength <= 96
        default: break
        }
        
        return true
    }
}
