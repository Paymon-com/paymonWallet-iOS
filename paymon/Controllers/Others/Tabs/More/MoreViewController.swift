//
//  MoreViewController.swift
//  paymon
//
//  Created by Maxim Skorynin on 15.09.2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import UIKit

class MoreViewController: PaymonViewController {

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var avatar: CircularImageView!
    @IBOutlet weak var login: UILabel!
    @IBOutlet weak var name: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        setLayoutOptions()
    }
    
    @IBAction func settingsClick(_ sender: Any) {
        guard let settingsViewController = StoryBoard.setting.instantiateViewController(withIdentifier: VCIdentifier.settingsViewController) as? SettingsViewController else {return}
        self.navigationController?.pushViewController(settingsViewController, animated: true)
    }
    
    @IBAction func openProfile(_ sender: Any) {
        guard let profileViewController = StoryBoard.user.instantiateViewController(withIdentifier: VCIdentifier.profileViewController) as? ProfileViewController else {return}
        self.navigationController?.pushViewController(profileViewController, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let user = User.shared.currentUser as RPC.UserObject? else {
            return
        }
        DispatchQueue.main.async {
            
            self.avatar.loadPhoto(url: user.photoUrl.url)
            self.name.text! = Utils.formatUserName(user)
            self.login.text = "@\(user.login!)"
        }
    }
    
    func setLayoutOptions(){
        self.view.setGradientLayer(frame: self.view.bounds, topColor: UIColor.AppColor.Black.primaryBlackLight.cgColor, bottomColor: UIColor.AppColor.Black.primaryBlack.cgColor)
        
        self.headerView.layer.cornerRadius = 30
        
        let widthScreen = UIScreen.main.bounds.width
        
        self.headerView.setGradientLayer(frame: CGRect(x: 0, y: 0, width: widthScreen, height: self.headerView.frame.height), topColor: UIColor.white.cgColor, bottomColor: UIColor.AppColor.Blue.primaryBlueUltraLight.cgColor)
        
        self.navigationItem.title = "More".localized
        
    }
}
