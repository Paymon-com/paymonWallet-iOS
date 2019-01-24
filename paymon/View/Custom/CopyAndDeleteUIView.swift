//
//  CopyAndDeleteLabel.swift
//  paymon
//
//  Created by Maxim Skorynin on 22/01/2019.
//  Copyright © 2019 Maxim Skorynin. All rights reserved.
//

import Foundation
import UIKit

class CopyAndDeleteUIView: UIView {
    
    var delegate : MoreActionDelegate!
    var text : String!
    
    override public var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        isUserInteractionEnabled = true
        addGestureRecognizer(
            UILongPressGestureRecognizer(
                target: self,
                action: #selector(handleLongPressed(_:))
            )
        )
    }
    
    @objc internal func handleLongPressed(_ gesture: UILongPressGestureRecognizer) {
        guard let gestureView = gesture.view, let superView = gestureView.superview else {
            return
        }
        
        let menuController = UIMenuController.shared
        
        guard !menuController.isMenuVisible, gestureView.canBecomeFirstResponder else {
            return
        }
        
        gestureView.becomeFirstResponder()
        
        menuController.menuItems = [
            UIMenuItem(
            title: "Copy",
            action: #selector(handleCopyAction(_:))
            ),
            UIMenuItem(
                title: "More",
                action: #selector(handleMoreAction(_:))
            )
        ]
        
        menuController.setTargetRect(gestureView.frame, in: superView)
        menuController.setMenuVisible(true, animated: true)
    }
    
    @objc internal func handleMoreAction(_ controller: UIMenuController) {
        self.delegate.showEditButton()
    }
    
    @objc internal func handleCopyAction(_ controller: UIMenuController) {
        UIPasteboard.general.string = text
        UIMenuController.shared.setMenuVisible(false, animated: true)
    }
}

protocol MoreActionDelegate {
    func showEditButton()
}
