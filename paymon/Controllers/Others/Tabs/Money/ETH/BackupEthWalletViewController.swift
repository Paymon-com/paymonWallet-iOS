//
//  BackupEthWalletViewController.swift
//  paymon
//
//  Created by Maxim Skorynin on 23/11/2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation

import Foundation
import UIKit

class BackupEthWalletViewController: UIViewController, UITextFieldDelegate, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var seedHint: UILabel!
    @IBOutlet weak var backup: UIButton!
    @IBOutlet weak var stackViews: UIView!
    @IBOutlet weak var enterPassword: UITextField!
    @IBOutlet weak var repeatPassword: UITextField!
    
    var password : String! = ""
    var repeatPasswordString: String! = ""
    var isPmnt = false
    
    override func viewDidLoad() {
        setLayoutOptions()
    }
    
    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        popoverPresentationController.sourceView = seedHint
    }
    
    @IBAction func backupClick(_ sender: Any) {
        
        password = enterPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        repeatPasswordString = repeatPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if password.isEmpty {
            enterPassword.shake()
            return
        }
        
        if repeatPasswordString.isEmpty || repeatPasswordString != password {
            repeatPassword.shake()
            return
        }
        
        if !isPmnt {
            if password == User.shared.passwordEthWallet {
                if let url = EthereumManager.shared.getUrlEthWallet() {
                    let shareActivity = UIActivityViewController(activityItems: ["Backup Ethereum wallet from the Paymon app".localized, url], applicationActivities: nil)
                    shareActivity.popoverPresentationController?.delegate = self
                    shareActivity.completionWithItemsHandler = { (activity, success, items, error) in
                        if success {
                            User.shared.backUpEthWallet()
                            self.navigationController?.popViewController(animated: true)
                        } else if error != nil {
                            _ = SimpleOkAlertController.init(title: "Backup".localized, message: "Backup failed. Try later.".localized, vc: self)
                        }
                    }
                    
                    self.present(shareActivity, animated: true)
                } else {
                    _ = SimpleOkAlertController.init(title: "Backup".localized, message: "The file does not exist".localized, vc: self)
                }
            } else {
                _ = SimpleOkAlertController.init(title: "Backup".localized, message: "Incorrect password".localized, vc: self)
            }
        } else {
            if password == User.shared.passwordPmntWallet {
                if let url = EthereumManager.shared.getUrlPmntWallet() {
                    let shareActivity = UIActivityViewController(activityItems: ["Backup Ethereum wallet from the Paymon app".localized, url], applicationActivities: nil)
                    shareActivity.popoverPresentationController?.delegate = self

                    shareActivity.completionWithItemsHandler = { (activity, success, items, error) in
                        if success {
                            User.shared.backUpPmntWallet()
                            self.navigationController?.popViewController(animated: true)
                        } else if error != nil {
                            _ = SimpleOkAlertController.init(title: "Backup".localized, message: "Backup failed. Try later.".localized, vc: self)
                        }
                    }

                    self.present(shareActivity, animated: true)
                } else {
                    _ = SimpleOkAlertController.init(title: "Backup".localized, message: "The file does not exist".localized, vc: self)
                }
            } else {
                _ = SimpleOkAlertController.init(title: "Backup".localized, message: "Incorrect password".localized, vc: self)
            }
        }
    }
    
    func setLayoutOptions() {
        
        enterPassword.placeholder = "Enter password".localized
        repeatPassword.placeholder = "Repeat password".localized
        seedHint.text = "Enter the password of the wallet".localized
        
        self.view.setGradientLayer(frame: self.view.bounds, topColor: UIColor.AppColor.Black.primaryBlackLight.cgColor, bottomColor: UIColor.AppColor.Black.primaryBlack.cgColor)
        
        self.title = "Backup".localized
        backup.setTitle("Backup".localized, for: .normal)
        backup.layer.cornerRadius = backup.frame.height/2
        stackViews.layer.cornerRadius = 30
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        
        switch (textField) {
        case enterPassword:
            return newLength <= 96
        case repeatPassword:
            return newLength <= 96
        default: break
        }
        
        return true
    }
    
}
