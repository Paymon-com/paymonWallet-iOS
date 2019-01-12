import UIKit
import Foundation
import MBProgressHUD

class UpdateProfileInfoTableViewController : UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var surnameInfo: UITextField!
    @IBOutlet weak var nameInfo: UITextField!
    @IBOutlet weak var ethInfo: UITextField!
    @IBOutlet weak var pmntInfo: UITextField!
    @IBOutlet weak var btcInfo: UITextField!
    
    private var observerUpdateProfile : NSObjectProtocol!

    var nameString = ""
    var surnameString = ""
    var eth = ""
    var pmnt = ""
    var btc = ""
    
    static var needRemoveObservers = true
    
    @objc func endEditing() {
        self.view.endEditing(true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        textField.resignFirstResponder()
        if textField == nameInfo {
            surnameInfo.becomeFirstResponder()
        } else if textField == surnameInfo {
            ethInfo.becomeFirstResponder()
        } else if textField == ethInfo {
            pmntInfo.becomeFirstResponder()
        } else if textField == pmntInfo {
            btcInfo.becomeFirstResponder()
        } else if textField == btcInfo {
            self.endEditing()
        }
        return true

    }

    @objc func textFieldDidChanged(_ textField : UITextField) {
        
        if (nameInfo.text != nameString || surnameInfo.text != surnameString || ethInfo.text != eth || pmntInfo.text != pmnt || btcInfo.text != btc) {

            NotificationCenter.default.post(name: .updateProfileInfoTrue, object: nil)

        } else {

            NotificationCenter.default.post(name: .updateProfileInfoFalse, object: nil)

        }
    }
    
    func updateString() {
        
        guard let user = User.shared.currentUser as RPC.UserObject? else {
            return
        }
        
        nameString = user.first_name ?? ""
        surnameString = user.last_name ?? ""
        eth = user.ethAddress ?? ""
        btc = user.btcAddress ?? ""
        pmnt = user.pmntAddress ?? ""
    }

    func updateView () {
        
        DispatchQueue.main.async {
            self.nameInfo.text = self.nameString
            self.surnameInfo.text = self.surnameString
            self.ethInfo.text = self.eth
            self.btcInfo.text = self.btc
            self.pmntInfo.text = self.pmnt

        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        UpdateProfileInfoTableViewController.needRemoveObservers = true
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        observerUpdateProfile = NotificationCenter.default.addObserver(forName: .updateProfile, object: nil, queue: nil ){ notification in
            DispatchQueue.main.async {
                let _ = MBProgressHUD.showAdded(to: self.parent!.parent!.view, animated: true)
            }

            User.shared.currentUser!.first_name = self.nameInfo.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            User.shared.currentUser!.last_name = self.surnameInfo.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            User.shared.currentUser!.ethAddress = self.ethInfo.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            User.shared.currentUser!.btcAddress = self.btcInfo.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            User.shared.currentUser!.pmntAddress = self.pmntInfo.text?.trimmingCharacters(in: .whitespacesAndNewlines)

            
            UserManager.shared.updateProfileInfo() { isUpdated in
                DispatchQueue.main.async {
                    MBProgressHUD.hide(for: self.parent!.parent!.view, animated: true)
                }
                
                if isUpdated {
                    User.shared.saveConfig()
                    DispatchQueue.main.async {
                        
                        Utils.showSuccesHud(vc: self.parent!.parent!)
                        self.updateView()
                        self.updateString()
                    }
                    print("profile update success")
                } else {
                    _ = SimpleOkAlertController.init(title: "Update failed".localized, message: "An error occurred during the update".localized, vc: self.parent!.parent!)
                    print("profile update error")
                }
                
            }
        }

        let tapper = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        tapper.cancelsTouchesInView = false
        view.addGestureRecognizer(tapper)

        self.nameInfo.delegate = self
        self.surnameInfo.delegate = self
        self.ethInfo.delegate = self
        self.btcInfo.delegate = self
        self.pmntInfo.delegate = self
        
        self.nameInfo.placeholder = "Name".localized
        self.surnameInfo.placeholder = "Surname".localized
        self.ethInfo.placeholder = "Ethereum wallet".localized
        self.btcInfo.placeholder = "Bitcoin wallet".localized
        self.pmntInfo.placeholder = "Paymon Token wallet".localized


        nameInfo.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)
        surnameInfo.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)
        ethInfo.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)
        btcInfo.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)
        pmntInfo.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)

        updateString()
        updateView()
        
    }
    
    @objc func postNotificationForShowCountryPicker() {
        NotificationCenter.default.post(name: .showCountryPicker, object: nil)
    
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        if UpdateProfileInfoTableViewController.needRemoveObservers {
            NotificationCenter.default.removeObserver(observerUpdateProfile)
        }
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        
        switch (textField) {
        case nameInfo:
            return newLength <= 128
        case surnameInfo:
            return newLength <= 128
        case ethInfo:
            return newLength <= 50
        case btcInfo:
            return newLength <= 50
        case pmntInfo:
            return newLength <= 50
        default: break
        }
        
        return true
    }


}
