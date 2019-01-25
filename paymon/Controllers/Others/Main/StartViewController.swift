//
// Created by Vladislav on 24/08/2017.
// Copyright (c) 2017 Paymon. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {

    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var signInBtn: UIButton!
    
    @IBOutlet weak var stackButtons: UIView!
    
    var isNeedReconnect = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if isNeedReconnect {
            NetworkManager.shared.reconnect()
        }
        setLayoutOptions()
    }

    func setLayoutOptions() {
        
        signInBtn.setTitle("sign in".localized, for: .normal)
        signUpBtn.setTitle("sign up".localized, for: .normal)
        
        stackButtons.layer.masksToBounds = true
        stackButtons.layer.cornerRadius = 30
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.view.addUIViewBackground(name: "MainBackground")
        print(navigationController?.viewControllers.count ?? 101)

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

}
