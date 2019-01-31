//
//  MainNavigationController.swift
//  paymon
//
//  Created by Maxim Skorynin on 04/10/2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation

class MainNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isLoggedIn() {
                    
            if User.shared.securityPasscode {
                let passcodeViewController = StoryBoard.passcode.instantiateViewController(withIdentifier: VCIdentifier.passcodeViewController) as! PasscodeViewController
                DispatchQueue.main.async {
                    self.pushViewController(passcodeViewController, animated: true)
                }
            } else {
                let tabsViewController = StoryBoard.main.instantiateViewController(withIdentifier: VCIdentifier.tabsViewController) as! TabsViewController
                DispatchQueue.main.async {
                    self.pushViewController(tabsViewController, animated: true)
                }
            }
        } else {
            self.navigationBar.isHidden = false
            let startViewController = StoryBoard.main.instantiateViewController(withIdentifier: VCIdentifier.startViewController) as! StartViewController
            DispatchQueue.main.async {
                self.pushViewController(startViewController, animated: true)
            }
        }
        
    }
    
    func isLoggedIn() -> Bool {
        return User.shared.currentUser != nil
    }
}
