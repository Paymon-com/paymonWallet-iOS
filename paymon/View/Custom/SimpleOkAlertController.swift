//
//  SimpleOkAlertController.swift
//  paymon
//
//  Created by Maxim Skorynin on 27.07.2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import UIKit

class SimpleOkAlertController: UIAlertController {

    init(title: String, message: String, vc : UIViewController) {
        super.init(nibName: nil, bundle: nil)
        self.title = title
        self.message = message
        
        self.addAction(UIAlertAction(title: "OK".localized, style: .default, handler: { (action) in
            
        }))
        
        if let popoverController = self.popoverPresentationController {
            popoverController.sourceView = vc.view
            popoverController.sourceRect = CGRect(x: vc.view.bounds.midX, y: vc.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        DispatchQueue.main.async {
            if !self.isBeingPresented {
                vc.present(self, animated: true)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
}
