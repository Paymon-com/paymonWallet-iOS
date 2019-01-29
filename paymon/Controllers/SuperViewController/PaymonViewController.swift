//
//  PaymonViewController.swift
//  paymon
//
//  Created by Jogendar Singh on 13/08/18.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import UIKit

class PaymonViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.setTransparent()
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor.white.withAlphaComponent(0.7)]
        self.navigationController?.navigationBar.tintColor = UIColor.AppColor.Blue.primaryBlue

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
