//
//  Constants.swift
//  paymon
//
//  Created by Jogendar Singh on 26/06/18.
//  Copyright © 2018 Semen Gleym. All rights reserved.
//

import Foundation
import web3swift

struct PushNotification {
    
    struct Category {
        
        static let messages = "messages"
    }
    
    struct Action {
        static let answer = "answer"
        static let skip = "skip"
        static let mute = "mute"
    }
    
    struct Keys {
        static let APS = "aps"
        static let ALERT = "alert"
        
        static let CHAT_ID = "chat_id"
        
        static let TITLE = "title"
        static let SUBTITLE = "subtitle"
        static let BODY = "body"
        static let SOUND = "sound"
        
        static let CATEGORY = "category"
        static let MESSAGE_FROM_GROUP = "message_from_group"
        static let MESSAGE_FROM_USER = "message_from_user"

    }
    
}

struct VCIdentifier {
    static let startViewController = "StartViewController"
    static let tabsViewController = "TabsViewController"
    static let signInViewController = "SignInViewController"
    static let signUpViewController = "SignUpViewController"
    static let registrViewController = "RegistrViewController"
    static let profileViewController = "ProfileViewController"
    static let settingsViewController = "SettingsViewController"
    static let updateProfileViewController = "UpdateProfileViewController"
    
    static let forgotPasswordEmailViewController = "ForgotPasswordEmailViewController"
    static let forgotPasswordCodeViewController = "ForgotPasswordCodeViewController"
    static let forgotPasswordChangeViewController = "ForgotPasswordChangeViewController"
    
    static let countryPickerViewController = "CountryPickerViewController"
    
    static let bitcoinTransferViewController = "BitcoinTransferViewController"
    static let receiveEthernVC = "ReceiveViewController"
    static let sendVCStoryID = "SendViewController"
    static let scanVCStoryID = "ScanViewControllerID"
    static let chooseCurrencyVCStoryID = "ChooseCurrencyViewController"
    static let CoinDetailsVCStoryID = "CoinDetailsViewController"
    
    static let qrScanViewController = "QRScannerViewController"
    static let keysViewController = "KeysViewController"
    
    static let ethereumTransferInformationViewController = "EthereumTransferInformationViewController"
    static let chatViewController = "ChatViewController"
    static let chatsViewController = "ChatsViewController"

    
    static let contactDetailViewController = "ContactDetailViewController"
    
    static let groupSettingViewController = "GroupSettingViewController"
    static let friendProfileViewController = "FriendProfileViewController"
    static let passcodeViewController = "PasscodeViewController"
    static let mainNavigationController = "MainNavigationController"
    static let createNewBtcWalletViewController = "CreateNewBtcWalletViewController"
    static let createNewEthWalletViewController = "CreateNewEthWalletViewController"

    static let backupBtcWalletViewController = "BackupBtcWalletViewController"
    static let backupEthWalletViewController = "BackupEthWalletViewController"
    
    static let restoreBtcViewController = "RestoreBtcViewController"
    static let restoreEthViewController = "RestoreEthViewController"
    
    static let paymentSuccessViewController = "PaymentSuccessViewController"
    
    static let ethTxInfoViewController = "EthTxInfoViewController"
    static let officialDocsViewController = "OfficialDocsViewController"
    
    static let ethereumWalletViewController = "EthereumWalletViewController"


}

struct UserDefaultKey {
    static let ethernAddress = "ethernAdd"
    static let NOTIFICATION_WORRY = "notification_worry_"
    static let NOTIFICATION_VIBRATION = "notification_vibration_"
    static let NOTIFICATION_MESSAGE_SOUND = "notification_message_sound_"

    static let NOTIFICATION_TRANSACTIONS = "notification_transactions_"
    static let NOTIFICATION_TRANSACTIONS_SOUND = "notification_transactions_sound_"
    
    static let SECURITY_PASSCODE = "security_password_protected_"
    static let SECURITY_PASSCODE_VALUE = "security_passcode_value_"
    
    static let TIME_FORMAT = "time_format_"
//    static let BITCOIN_PRIVATE_KEY = "bitcoin_private_key_"
    static let CURRENCY_CODE = "currency_code_"
    static let SYMB_COUNT = "symb_count_"
//    static let PASSWORD_BTC_WALLET = "password_btc_wallet_"
    static let PASSWORD_ETH_WALLET = "password_eth_wallet_"
    static let PASSWORD_PMNT_WALLET = "password_pmnt_wallet_"

//    static let ROW_SEED_FOR_BACKUP = "row_seed_for_backup_"
//    static let IS_BTC_WALLET_BACKUP = "is_btc_wallet_backup_"
    static let IS_ETH_WALLET_BACKUP = "is_eth_wallet_backup_"
    static let IS_PMNT_WALLET_BACKUP = "is_pmnt_wallet_backup_"
    static let IS_PMNT_CREATED_FROM_ETH = "is_pmnt_created_from_eth_"

}

struct ExchangeRatesConst {
    static let urlChartsHour = "https://min-api.cryptocompare.com/data/histominute?aggregate=1&e=CCCAGG&extraParams=CryptoCompare&fsym=%@&limit=60&tryConversion=true&tsym=%@"
    static let urlChartsDay = "https://min-api.cryptocompare.com/data/histominute?aggregate=10&e=CCCAGG&extraParams=CryptoCompare&fsym=%@&limit=144&tryConversion=true&tsym=%@"
    static let urlChartsWeek = "https://min-api.cryptocompare.com/data/histohour?aggregate=1&e=CCCAGG&extraParams=CryptoCompare&fsym=%@&limit=168&tryConversion=true&tsym=%@"
    static let urlChartsOneMonth = "https://min-api.cryptocompare.com/data/histohour?aggregate=6&e=CCCAGG&extraParams=CryptoCompare&fsym=%@&limit=120&tryConversion=true&tsym=%@"
    static let urlChartsThreeMonths = "https://min-api.cryptocompare.com/data/histoday?aggregate=1&e=CCCAGG&extraParams=CryptoCompare&fsym=%@&limit=90&tryConversion=true&tsym=%@"
    static let urlChartsSixMonths = "https://min-api.cryptocompare.com/data/histoday?aggregate=1&e=CCCAGG&extraParams=CryptoCompare&fsym=%@&limit=180&tryConversion=true&tsym=%@"
    static let urlChartsYear = "https://min-api.cryptocompare.com/data/histoday?aggregate=1&e=CCCAGG&extraParams=CryptoCompare&fsym=%@&limit=365&tryConversion=true&tsym=%@"
    
    static let hour = "hour"
    static let day = "day"
    static let week = "week"
    static let oneMonth = "oneMonth"
    static let threeMonth = "threeMonth"
    static let sixMonth = "sixMonth"
    static let year = "year"
}

struct Urls {
    static let playMarket = "https://play.google.com/store/apps/details?id=ru.paymon.android.release"
    static let appStore = "https://itunes.apple.com/us/app/paymon/id1296873367"
    static let profitWeb = "https://profit.paymon.org/"
}

struct Money {
    static let btc = "BTC"
    static let eth = "ETH"
    static let pmnt = "PMNT"
    static let rub = "RUB"
    static let usd = "USD"
    static let eur = "EUR"
    
    static let pmntContract = Address("0x81b4d08645da11374a03749ab170836e4e539767")

    
    static let btcIcon = "Bitcoin"
    static let ethIcon = "Ethereum"
    static let pmntIcon = "PmncIcon"
    
    static let BITCOIN_WALLET_QR_REGEX = "(^(bitcoin:)?(BITCOIN:-)?[13][a-zA-Z0-9]{25,34}$)$"
    static let ETHEREUM_WALLET_QR_REGEX = "(^(ethereum:)?(ETHEREUM:-)?0x[a-fA-F0-9]{40,44}$)$"

    static let BITCOIN_WALLET_REGEX = "^[13][a-zA-Z0-9]{25,34}$"
    static let ETHEREUM_WALLET_REGEX = "^0x[a-fA-F0-9]{40,44}$"
    static let fromWei = 1000000000000000000.0
    static let fromGwei : Double = 1000000000.0
}

struct Transaction {
    var type : TransactionType
    var from : String
    var amount : String
    var time : String
    var avatar : UIImage
    var txEthInfo : EthTransaction?
    var txPmntInfo : PmntTransaction?
}

struct StoryBoard {
    static let main = UIStoryboard(name: "Main", bundle: Bundle.main)
    static var user : UIStoryboard!
    static let forgotPassword = UIStoryboard(name: "ForgotPassword", bundle: Bundle.main)
    static var money : UIStoryboard!
    static var chat : UIStoryboard!
    static let bitcoin = UIStoryboard(name: "Bitcoin", bundle: Bundle.main)
    static var ethereum : UIStoryboard!
    static var contacts : UIStoryboard!
    static var passcode : UIStoryboard!
    static var setting : UIStoryboard!
    static var more : UIStoryboard!
}

class SetterStoryboards {
    static let shared = SetterStoryboards()
    var isiPad = false

    func setStoryboard() {
        if !self.isiPad {
            StoryBoard.user = UIStoryboard(name: "User", bundle: Bundle.main)
            StoryBoard.chat = UIStoryboard(name: "Chats", bundle: Bundle.main)
            StoryBoard.contacts = UIStoryboard(name: "Contacts", bundle: Bundle.main)
            StoryBoard.more = UIStoryboard(name: "More", bundle: Bundle.main)
            StoryBoard.passcode = UIStoryboard(name: "Passcode", bundle: Bundle.main)
            StoryBoard.setting = UIStoryboard(name: "Setting", bundle: Bundle.main)
            StoryBoard.money = UIStoryboard(name: "Money", bundle: Bundle.main)
            StoryBoard.ethereum = UIStoryboard(name: "Ethereum", bundle: Bundle.main)

        } else {
            StoryBoard.user = UIStoryboard(name: "UseriPad", bundle: Bundle.main)
            StoryBoard.chat = UIStoryboard(name: "ChatsiPad", bundle: Bundle.main)
            StoryBoard.contacts = UIStoryboard(name: "ContactsiPad", bundle: Bundle.main)
            StoryBoard.more = UIStoryboard(name: "MoreiPad", bundle: Bundle.main)
            StoryBoard.passcode = UIStoryboard(name: "PasscodeiPad", bundle: Bundle.main)
            StoryBoard.setting = UIStoryboard(name: "SettingiPad", bundle: Bundle.main)
            StoryBoard.money = UIStoryboard(name: "MoneyiPad", bundle: Bundle.main)
            StoryBoard.ethereum = UIStoryboard(name: "EthereumiPad", bundle: Bundle.main)
        }
    }
}

