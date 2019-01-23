//
// Created by Vladislav on 01/09/2017.
// Copyright (c) 2017 Paymon. All rights reserved.
//

import UIKit
import Foundation

class ChatMessageViewCell : UITableViewCell {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var bubble: CopyAndDeleteUIView!
    
    var id : Int64!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bubble.layer.cornerRadius = 18
        bubble.backgroundColor = UIColor.AppColor.Blue.chatBlueBubble
        let backSelectView = UIView()
        backSelectView.backgroundColor = UIColor.clear
        self.selectedBackgroundView = backSelectView
        self.selectionStyle = .none
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
            if selected {
                bubble.backgroundColor = UIColor.AppColor.Blue.chatBlueBubble
            }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
        self.selectionStyle = editing ? .gray : .none
    }
    
    func configure(message : ChatMessageData) {
        self.id = message.id
        self.messageLabel.text = message.text
        self.bubble.text = message.text
        self.timeLabel.text = Utils.formatMessageDateTime(timestamp: message.date)
    }
}
