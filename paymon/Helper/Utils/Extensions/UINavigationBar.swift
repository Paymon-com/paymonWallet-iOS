//
//  UINavigationBar.swift
//  paymon
//
//  Created by Maxim Skorynin on 26.07.2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation

extension UINavigationBar {
    func setTransparent(){
        self.setBackgroundImage(UIImage(), for: .default)
        self.shadowImage = UIImage()
    }
}

extension UITabBar {
    func setTransparent(){
        self.backgroundImage = UIImage()
        self.shadowImage = UIImage()
    }
}

class PaymonNavBar : UINavigationBar {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setTransparent()
        self.titleTextAttributes = [NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor.white.withAlphaComponent(0.7)]
        self.tintColor = UIColor.AppColor.Blue.primaryBlue
    }
}
