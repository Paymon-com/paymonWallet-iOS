import UIKit

class SettingsTableViewController : UITableViewController {
    
    @IBOutlet weak var notifications: UILabel!
    @IBOutlet weak var account: UILabel!
    @IBOutlet weak var wallet: UILabel!
    
    @IBOutlet weak var aboutApp: UILabel!
    @IBOutlet weak var security: UILabel!
    
    @IBOutlet weak var logOut: UIButton!
    @IBOutlet weak var logOutCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notifications.text = "Notifications".localized
        account.text = "Account".localized
        wallet.text = "Wallet".localized
        security.text = "Security".localized
        aboutApp.text = "About the application".localized
        logOut.setTitle("Log out".localized, for: .normal)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 4
    }
    
    @IBAction func logOutClick(_ sender: Any) {
        let logOutMenu = UIAlertController(title: "Logged in as ".localized+"\(Utils.formatUserName(User.shared.currentUser))", message: nil, preferredStyle: .actionSheet)
        
        let cancel = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)
        let logOut = UIAlertAction(title: "Log out".localized, style: .destructive, handler: { (alert: UIAlertAction!) -> Void in
//            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            if let startViewController = StoryBoard.main.instantiateViewController(withIdentifier: VCIdentifier.startViewController) as? StartViewController {
                User.shared.clearConfig()
                
                MessageManager.dispose()
                startViewController.isNeedReconnect = true
                DispatchQueue.main.async {
                    self.navigationController?.setViewControllers([startViewController], animated: true)
                }
            }
        })
        
        logOutMenu.addAction(cancel)
        logOutMenu.addAction(logOut)
        
        if let popoverController = logOutMenu.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        self.present(logOutMenu, animated: true, completion: nil)
    }
}
