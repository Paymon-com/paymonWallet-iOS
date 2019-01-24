//
//  ContactDetailViewController.swift
//  paymon
//
//  Created by SHUBHAM AGARWAL on 02/09/18.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import UIKit

class ContactDetailViewController: UIViewController {

    @IBOutlet weak var contactName: UILabel!
    
    @IBOutlet weak var contactNumber: UILabel!
    @IBOutlet weak var avatar: CircularImageView!
    
    @IBOutlet weak var phoneView: UIView!
    @IBOutlet weak var inviteToPaymon: UIButton!
    // Data Coming from previous controller.
    var contact: Contact?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contactName.text = contact?.name ?? "N/A"
        contactNumber.text = contact?.phone ?? "N/A"
        
        setLayoutOptions()
        
    }
    
    func setLayoutOptions() {
        self.title = "Info".localized
        self.inviteToPaymon.setTitle("Invite to Paymon".localized, for: .normal)

        self.view.setGradientLayer(frame: self.view.bounds, topColor: UIColor.AppColor.Black.primaryBlackLight.cgColor, bottomColor: UIColor.AppColor.Black.primaryBlack.cgColor)
        
        self.phoneView.layer.cornerRadius = phoneView.frame.height/2
    }

    @IBAction func onClickInvitePaymon(_ sender: Any) {
        let shareActivity = UIActivityViewController(activityItems: ["Hello! Have you seen the new crypto messenger Paymon? This is the fastest, most secure and most convenient application for communication and exchange of crypto-currencies. Join us!".localized,"\n","Android:",Urls.playMarket,"\n","iOS:",Urls.appStore], applicationActivities: [])
        
        shareActivity.popoverPresentationController?.sourceView = self.view
        shareActivity.popoverPresentationController?.sourceRect = self.view.bounds
        
        present(shareActivity, animated: true)
    }
}
