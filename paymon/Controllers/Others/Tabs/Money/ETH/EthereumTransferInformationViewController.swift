//
//  TransferInformationViewController.swift
//  paymon
//
//  Created by Maxim Skorynin on 30.08.2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import UIKit
import BigInt
import MBProgressHUD

class EthereumTransferInformationViewController: UIViewController {
    
    @IBOutlet weak var sendImage: UIImageView!
    @IBOutlet weak var send: UIButton!
    @IBOutlet weak var totalAmount: UILabel!
    @IBOutlet weak var totalAmountHint: UILabel!
    @IBOutlet weak var networkFeeAmount: UILabel!
    @IBOutlet weak var networkFeeHint: UILabel!
    @IBOutlet weak var toWallet: UILabel!
    @IBOutlet weak var toHint: UILabel!
    @IBOutlet weak var yourWallet: UILabel!
    @IBOutlet weak var yourWalletBalance: UILabel!
    @IBOutlet weak var fromHint: UILabel!
    
    @IBOutlet weak var toWalletPicture: UIImageView!
    @IBOutlet weak var yourWalletPicture: UIImageView!
    @IBOutlet weak var yourWalletPictureWidth: NSLayoutConstraint!
    @IBOutlet weak var toWalletPictureWidth: NSLayoutConstraint!
    
    @IBOutlet weak var stackView: UIView!

    var balanceValue : Double!
    var toAddress : String!
    var totalAmountValue : Double!
    var amountToSend: Double!
    var gasLimit:Double!
    var course:Double!
    
    var gasPrice : Int64!
    var isPmnt = false
    var user : User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        user = User.shared
        toWallet.text = toAddress
        course = EthereumManager.shared.ethCourse
        
        let feeForView = gasLimit * Double(gasPrice) / Money.fromWei * course
        totalAmountValue = amountToSend * (!isPmnt ? course : EthereumManager.shared.pmntCourse) + feeForView
        
        networkFeeAmount.text = String(format: "≈ \(user.currencyCodeSymb) %.\(user.symbCount)f", feeForView)
        yourWalletBalance.text = String(format: "\(user.currencyCodeSymb) %.\(user.symbCount)f", balanceValue)
        totalAmount.text = String(format: "≈ \(user.currencyCodeSymb) %.\(user.symbCount)f",totalAmountValue)
        
        setLayoutOptions()
    }
    
    @IBAction func sendClick(_ sender: Any) {
        self.checkPasswordWallet(vc: self, completionHandler: { (isSuccess:Bool) in
            if isSuccess {

                DispatchQueue.main.async {
                    let _ = MBProgressHUD.showAdded(to: self.view, animated: true)
                }
                
                if !self.isPmnt {
                    EthereumManager.shared.sendEth(gasPrice: BigUInt(String(self.gasPrice))!, gasLimit: Int64(self.gasLimit), value: Int64(self.amountToSend * Money.fromWei), toAddress: self.toAddress, password: self.user.passwordEthWallet) { (isSent, txid) in
                        DispatchQueue.main.async {
                            MBProgressHUD.hide(for: self.view, animated: true)
                        }
                        if isSent {
                            guard let paymentSuccessVC = self.storyboard?.instantiateViewController(withIdentifier: VCIdentifier.paymentSuccessViewController) as? PaymentSuccessViewController else {return}
                            
                            DispatchQueue.main.async {
                                self.navigationController?.pushViewController(paymentSuccessVC, animated: true)
                            }
                        } else {
                            DispatchQueue.main.async {
                                _ = SimpleOkAlertController.init(title: "Ethereum transfer".localized, message: "Failed transfer, try later".localized, vc: self)
                            }
                            
                        }
                    }
                } else {
                    EthereumManager.shared.sendPmnt(gasPrice: BigUInt(String(self.gasPrice))!, gasLimit: Int64(self.gasLimit), value: Int64(self.amountToSend), toAddress: self.toAddress, password: self.user.passwordPmntWallet) { (isSent, txid) in
                        DispatchQueue.main.async {
                            MBProgressHUD.hide(for: self.view, animated: true)
                        }
                        if isSent {
                            guard let paymentSuccessVC = self.storyboard?.instantiateViewController(withIdentifier: VCIdentifier.paymentSuccessViewController) as? PaymentSuccessViewController else {return}
                            
                            DispatchQueue.main.async {
                                self.navigationController?.pushViewController(paymentSuccessVC, animated: true)
                            }
                        } else {
                            DispatchQueue.main.async {
                                _ = SimpleOkAlertController.init(title: "Paymon token transfer".localized, message: "Failed transfer, try later".localized, vc: self)
                            }
                            
                        }
                    }
                }
                
            } else {
                _ = SimpleOkAlertController.init(title: "Security password".localized, message: "Incorrect password".localized, vc: self)
            }
        })
    }
    
    func checkPasswordWallet(vc: UIViewController, completionHandler: @escaping (Bool) -> ()) {
        let alertCheckPassword = UIAlertController(title: "Security password".localized, message: "Enter the password that was specified when creating or restoring the wallet".localized, preferredStyle: UIAlertController.Style.alert)
        
        alertCheckPassword.addAction(UIAlertAction(title: "Cancel".localized, style: .default, handler: nil))
        alertCheckPassword.addAction(UIAlertAction(title: "Ok".localized, style: .default, handler: { (nil) in
            let textField = alertCheckPassword.textFields![0] as UITextField
            let passwordForCheck = !self.isPmnt ? self.user.passwordEthWallet : self.user.passwordPmntWallet
            if passwordForCheck == textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
                completionHandler(true)
            } else {
                completionHandler(false)
            }
        }))
        alertCheckPassword.addTextField { (textField) in
            textField.placeholder = "Enter security password".localized
            textField.isSecureTextEntry = true
        }
        
        DispatchQueue.main.async {
            vc.present(alertCheckPassword, animated: true) {
                () -> Void in
            }
        }
    }
    
    func setLayoutOptions() {
        
        self.view.setGradientLayer(frame: self.view.bounds, topColor: UIColor.AppColor.Black.primaryBlackLight.cgColor, bottomColor: UIColor.AppColor.Black.primaryBlack.cgColor)
        
        let widthScreen = UIScreen.main.bounds.width

        self.stackView.setGradientLayer(frame: CGRect(x: 0, y: 0, width: widthScreen, height: self.stackView.frame.height), topColor: UIColor.AppColor.Black.walletTableInfoLight.cgColor, bottomColor: UIColor.AppColor.Black.walletTableInfoDark.cgColor)
        
        stackView.layer.cornerRadius = 30
        
        self.send.setGradientLayer(frame: CGRect(x: 0, y: 0, width: send.frame.width, height: self.send.frame.height), topColor: UIColor.AppColor.Blue.ethereumBalanceLight.cgColor, bottomColor: UIColor.AppColor.Blue.ethereumBalanceDark.cgColor)
        
        self.send.layer.cornerRadius = self.send.frame.width/2
        self.yourWalletPicture.image = isPmnt ? UIImage(named: "PaymonClear") : UIImage(named: "EtherClear")
        self.yourWalletPictureWidth.constant = isPmnt ? 24 : 17
        self.toWalletPicture.image = isPmnt ? UIImage(named: "PaymonClear") : UIImage(named: "EtherClear")
        self.toWalletPictureWidth.constant = isPmnt ? 24 : 17
        toHint.text = "To".localized
        fromHint.text = "From".localized
        yourWallet.text = "Your wallet".localized
        networkFeeHint.text = "Network fee".localized
        totalAmountHint.text = "Total amount".localized
        self.title = "Transfer info".localized
    }
}
