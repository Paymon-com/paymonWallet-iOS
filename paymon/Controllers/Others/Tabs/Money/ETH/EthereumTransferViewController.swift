//
//  EthereumTransferViewController.swift
//  paymon
//
//  Created by Maxim Skorynin on 26/11/2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation
import DeckTransition

class EthereumTransferViewController : UIViewController, UITextFieldDelegate {
    @IBOutlet weak var yourWallet: UIButton!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var cryptoHint: UILabel!
    @IBOutlet weak var fiatHint: UILabel!
    @IBOutlet weak var addressView: UIView!
    @IBOutlet weak var amountAndWalletView: UIView!
    
    @IBOutlet weak var walletPicture: UIImageView!
    @IBOutlet weak var walletPictureWidth: NSLayoutConstraint!
    @IBOutlet weak var gasPriceHint: UILabel!
    @IBOutlet weak var address: UITextField!
    @IBOutlet weak var fiat: UITextField!
    @IBOutlet weak var feeView: UIView!
    @IBOutlet weak var feeSwitch: UISwitch!
    @IBOutlet weak var gasLimit: UITextField!
    @IBOutlet weak var feeHint: UILabel!
    
    @IBOutlet weak var line: UIView!
    @IBOutlet weak var walletInfoView: UIView!
    @IBOutlet weak var amountView: UIView!
    @IBOutlet weak var sendBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var send: UIButton!
    @IBOutlet weak var sendImage: UIImageView!
    @IBOutlet weak var crypto: UITextField!
    @IBOutlet weak var yourWalletBalance: UILabel!
    @IBOutlet weak var gasPriceView: UIView!
    @IBOutlet weak var gasPrice: UILabel!
    
    @IBOutlet weak var gasPriceSlider: UISlider!
    
    var isPmnt = false
    
    let minValueFee:Double! = 21000
    
    var cryptoValue : Double! = 0.0
    var fiatValue : Double! = 0.0
    var gasLimitValue : Double! = 21000
    
    var addressIsNotEmpty = false
    var amountIsCorrect = false
    
    var course : Double!
    
    var publicKey : String!
    var yourWalletBalanceValue : Double!
    var toAddress:String! = ""

    
    @IBAction func infoClick(_ sender: Any) {
        guard let infoViewController = self.storyboard!.instantiateViewController(withIdentifier: "GasInfoViewController") as? GasInfoViewController else {return}
        
        let transitionDelegate = DeckTransitioningDelegate()
        infoViewController.transitioningDelegate = transitionDelegate
        infoViewController.modalPresentationStyle = .custom
        present(infoViewController, animated: true, completion: nil)
    }
    @IBAction func feeSwitchClick(_ sender: Any) {
        if feeSwitch.isOn {
            gasLimit.text = ""
            gasLimit.isEnabled = true
            gasLimit.font = UIFont(name: (gasLimit.font?.fontName)!, size: 22)
            gasLimit.textColor = UIColor.white.withAlphaComponent(0.75)
            gasLimit.text = "\(21000)"
        } else {
            gasLimit.text = "Standart fee".localized
            gasLimit.isEnabled = false
            gasLimit.font = UIFont(name: (gasLimit.font?.fontName)!, size: 14)
            gasLimit.textColor = UIColor.white.withAlphaComponent(0.4)
            gasLimitValue = 21000
        }
    }
    
    @IBAction func yourWalletClick(_ sender: Any) {
        guard let keysViewController = StoryBoard.money.instantiateViewController(withIdentifier: VCIdentifier.keysViewController) as? KeysViewController else {return}
        
        keysViewController.keyValue = self.publicKey
        keysViewController.currency = Money.eth
        
        let transitionDelegate = DeckTransitioningDelegate()
        keysViewController.transitioningDelegate = transitionDelegate
        keysViewController.modalPresentationStyle = .custom
        present(keysViewController, animated: true, completion: nil)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        
        let crypto = !isPmnt ? Money.eth : Money.pmnt
        ExchangeRateParser.shared.parseCourse(crypto: crypto, fiat: User.shared.currencyCode) { result in
            self.course = result
            
            DispatchQueue.main.async {
                self.loading.stopAnimating()
                self.showAmountAndInfoView()
            }
        }
    }
    
    func getYourWalletInfo() {
        
        yourWalletBalanceValue = !isPmnt ? Double(EthereumManager.shared.ethFiatBalance) : Double(EthereumManager.shared.pmntFiatBalance)
        yourWalletBalance.text = String(format: "\(User.shared.currencyCodeSymb) %.2f", yourWalletBalanceValue)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getYourWalletInfo()
        setLayoutOptions()
        self.loading.startAnimating()
        
        self.view.addEndEditingTapper()
        
        fiat.delegate = self
        crypto.delegate = self
        address.delegate = self
        
        fiat.addTarget(self, action: #selector(fiatDidChanged(_:)), for: .editingChanged)
        crypto.addTarget(self, action: #selector(cryptoDidChanged(_:)), for: .editingChanged)
        address.addTarget(self, action: #selector(addressDidChanged(_:)), for: .editingChanged)
        gasLimit.addTarget(self, action: #selector(feeDidChanged(_:)), for: .editingChanged)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    @IBAction func gasPriceChange(_ sender: Any) {
        gasPrice.text = String(Int(gasPriceSlider.value))
    }
    
    func setLayoutOptions() {
        self.addressView.layer.cornerRadius = 30
        gasLimit.text = "Standart fee".localized
        gasLimit.isEnabled = false
        let widthScreen = UIScreen.main.bounds.width
        
        self.addressView.setGradientLayer(frame: CGRect(x: 0, y: 0, width: widthScreen, height: self.addressView.frame.height), topColor: UIColor.AppColor.Blue.ethereumBalanceLight.cgColor, bottomColor: UIColor.AppColor.Blue.ethereumBalanceDark.cgColor)
        
        self.send.setGradientLayer(frame: CGRect(x: 0, y: 0, width: send.frame.width, height: self.send.frame.height), topColor: UIColor.AppColor.Blue.ethereumBalanceLight.cgColor, bottomColor: UIColor.AppColor.Blue.ethereumBalanceDark.cgColor)
        
        self.send.layer.cornerRadius = self.send.frame.width/2
        self.feeView.layer.cornerRadius = self.feeView.frame.height/2
        self.gasPriceView.layer.cornerRadius = self.feeView.frame.height/2
        
        self.view.setGradientLayer(frame: self.view.bounds, topColor: UIColor.AppColor.Black.primaryBlackLight.cgColor, bottomColor: UIColor.AppColor.Black.primaryBlack.cgColor)
        
        self.amountAndWalletView.setGradientLayer(frame: CGRect(x: 0, y: 0, width: widthScreen, height: self.amountAndWalletView.frame.height), topColor: UIColor.AppColor.Black.walletTableInfoLight.cgColor, bottomColor: UIColor.AppColor.Black.walletTableInfoDark.cgColor)
        
        self.amountAndWalletView.layer.cornerRadius = 30
        
        self.title = "Transfer".localized
        self.address.placeholder = !isPmnt ? "Ethereum address".localized : "Paymon Token address".localized
        self.yourWallet.setTitle("Your wallet".localized, for: .normal)
        self.cryptoHint.text = !isPmnt ? Money.eth : Money.pmnt
        self.fiatHint.alpha = 0
        self.cryptoHint.alpha = 0
        self.send.alpha = 0
        self.sendImage.alpha = 0
        self.amountView.alpha = 0
        self.walletInfoView.alpha = 0
        self.line.alpha = 0
        
        self.fiatHint.text = User.shared.currencyCode
        self.fiat.placeholder = User.shared.currencyCode
        self.crypto.placeholder = isPmnt ? Money.pmnt : Money.eth
        self.walletPicture.image = isPmnt ? UIImage(named: "PaymonClear") : UIImage(named: "EtherClear")
        self.walletPictureWidth.constant = isPmnt ? 24 : 17
        self.feeHint.text = "Network fee".localized
        self.gasLimit.placeholder = "Gas limit".localized
        self.gasPriceHint.text = "Gas price (Gwei)".localized
        self.feeSwitch.onTintColor = UIColor.AppColor.Blue.ethereumBalanceDark
        
        self.send.isEnabled = false
    }
    
    @objc func feeDidChanged(_ textField : UITextField) {
        
        guard let feeString = textField.text?.replacingOccurrences(of: ",", with: ".") else {return}
        textField.text = feeString
        print(feeString)
        if !feeString.isEmpty && feeString != "." && feeString.components(separatedBy: ".").count < 3 {
            gasLimitValue = Double(feeString)!
        } else {
            gasLimitValue = 21000
        }
        print(gasLimit)
    }
    
    @objc func fiatDidChanged(_ textField : UITextField) {
        
        guard let fiatString = textField.text?.replacingOccurrences(of: ",", with: ".") else {return}
        textField.text = fiatString
        
        if !fiatString.isEmpty && fiatString != "." && fiatString.components(separatedBy: ".").count < 3 {
            fiatValue = Double(fiatString)
            crypto.text = String(format: "%.7f", fiatValue / course)
            cryptoValue = fiatValue / course
            
            amountIsCorrect = true
        } else {
            amountIsCorrect = false
            crypto.text = ""
        }
        showSendButton()
        showHints(isEmpty: !(fiat.text?.isEmpty)! && !(crypto.text?.isEmpty)!)
        
    }
    
    @objc func cryptoDidChanged(_ textField : UITextField) {
        
        guard let cryptoString = textField.text?.replacingOccurrences(of: ",", with: ".") else {return}
        textField.text = cryptoString
        
        if !cryptoString.isEmpty && cryptoString != "." && cryptoString.components(separatedBy: ".").count < 3 {
            cryptoValue = Double(cryptoString)
            fiat.text = String(format: "%.2f", cryptoValue * course)
            fiatValue = cryptoValue * course
            amountIsCorrect = true
            
        } else {
            amountIsCorrect = false
            
            fiat.text = ""
        }
        
        showSendButton()
        showHints(isEmpty: !(fiat.text?.isEmpty)! && !(crypto.text?.isEmpty)!)
    }
    
    @objc func addressDidChanged(_ textField : UITextField) {
        toAddress = textField.text
                addressIsNotEmpty = !(toAddress?.isEmpty)! && (toAddress?.matches(Money.ETHEREUM_WALLET_REGEX))!

        showSendButton()
        
    }
    
    @IBAction func sendClick(_ sender: Any) {
        
        if isPmnt && EthereumManager.shared.pmntCryptoBalance.isLess(than: cryptoValue) {
            _ = SimpleOkAlertController.init(title: "Transfer".localized, message: "You do not have enough PMNT tokens".localized, vc: self)
            return
        }
        
        if gasLimitValue < minValueFee {
            _ = SimpleOkAlertController.init(title: "Network fee".localized, message: "The minimum gas limit is 21000 Gwei".localized, vc: self)
            return
        }
        
        let value = !isPmnt ? Decimal(cryptoValue) * Decimal(Money.fromWei) : 0
        let fee = Decimal(gasLimitValue) * Decimal(gasPrice.text!) * Decimal(Money.fromGwei)
        let ethBalance = Decimal(EthereumManager.shared.ethBalance.description)
        
        if value + fee < ethBalance {
//            print("balance \(Decimal(balance) * Decimal(Money.fromGwei))")
//            print("value + fee \(value + fee)")
            let transferInfoVC = StoryBoard.ethereum.instantiateViewController(withIdentifier: VCIdentifier.ethereumTransferInformationViewController) as! EthereumTransferInformationViewController
            transferInfoVC.isPmnt = isPmnt
            transferInfoVC.toAddress = toAddress
            transferInfoVC.balanceValue = EthereumManager.shared.ethFiatBalance
            transferInfoVC.amountToSend = cryptoValue
            transferInfoVC.gasLimit = gasLimitValue
            transferInfoVC.gasPrice = Int64(gasPrice.text!)! * Int64(Money.fromGwei)
            
            self.navigationController?.pushViewController(transferInfoVC, animated: true)
            
        } else {
            _ = SimpleOkAlertController.init(title: "Transfer".localized, message: "You do not have enough ETH tokens".localized, vc: self)
        }
    }
    
    func showHints(isEmpty : Bool) {
        if isEmpty {
            UIView.animate(withDuration: 0.3, delay: 0, animations: {
                self.fiatHint.alpha = 1
                self.cryptoHint.alpha = 1
            })
        } else {
            UIView.animate(withDuration: 0.3, delay: 0, animations: {
                self.fiatHint.alpha = 0
                self.cryptoHint.alpha = 0
            })
        }
        
        self.view.layoutIfNeeded()
    }
    
    func showSendButton() {
        if addressIsNotEmpty && amountIsCorrect {
            UIView.animate(withDuration: 0.3, delay: 0, animations: {
                self.send.alpha = 1
                self.sendImage.alpha = 1
                self.send.isEnabled = true
                
            })
        } else {
            UIView.animate(withDuration: 0.3, delay: 0, animations: {
                self.send.alpha = 0
                self.sendImage.alpha = 0
                self.send.isEnabled = false
                
            })
        }
        
        self.view.layoutIfNeeded()
    }
    
    func showAmountAndInfoView() {
        
        UIView.animate(withDuration: 0.3, delay: 0, animations: {
            self.amountView.alpha = 1
            self.walletInfoView.alpha = 1
            self.line.alpha = 1
        })
        
        self.view.layoutIfNeeded()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let qrScanViewController = segue.destination as? QRScannerViewController else {return}
        qrScanViewController.currency = Money.eth
    }

    @objc func handleKeyboard(notification: NSNotification) {

        if let userInfo = notification.userInfo {
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect

            sendBottomConstraint.constant = notification.name == UIResponder.keyboardWillShowNotification ? keyboardFrame!.height - 16 : 16

            UIView.animate(withDuration: 0,
                           delay: 0,
                           options: UIView.AnimationOptions.curveEaseOut,
                           animations: {
                            self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
}
