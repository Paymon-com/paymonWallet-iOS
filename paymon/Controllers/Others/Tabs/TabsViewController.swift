//
// Created by Vladislav on 28/08/2017.
// Copyright (c) 2017 Paymon. All rights reserved.
//

import Foundation
import UIKit

class TabsViewController: UITabBarController {
    
    var isAfterPasscode = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setTabs()
    }
    
    func setTabs() {
        guard let chatsViewController = StoryBoard.chat.instantiateInitialViewController() as? ChatsViewController else {return}
        let contactsViewController = StoryBoard.contacts.instantiateInitialViewController()
        let moneyViewController = StoryBoard.money.instantiateInitialViewController()
        let moreViewController = StoryBoard.more.instantiateInitialViewController()
        chatsViewController.isAfterPasscode = self.isAfterPasscode
        
        let controllers = [chatsViewController, contactsViewController, moneyViewController, moreViewController]
        
        self.viewControllers = controllers.map {
            UINavigationController(rootViewController: $0 as! PaymonViewController)
        }
    }
}
