//
// Created by Vladislav on 01/09/2017.
// Copyright (c) 2017 Paymon. All rights reserved.
//

import UIKit

class ChatsTableGroupViewCell : UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var lastMessageText: UILabel!
    @IBOutlet weak var lastMessageTime: UILabel!
    
    @IBOutlet weak var photo: CircularImageView!
    
    @IBOutlet weak var lastMessagePhoto: CircularImageView!
    var chatId : Int32!
    var creatorId : Int32!
    
    func configure(chat: ChatsData) {
        self.title.text = chat.title
        self.lastMessageText.text = chat.lastMessageText
        self.lastMessageTime.text = Utils.formatDateTime(timestamp: chat.time)
        self.photo.loadPhoto(url: chat.photoUrl)
        self.lastMessagePhoto.loadPhoto(url: chat.lastMessagePhotoUrl)
        self.chatId = chat.id
        self.creatorId = chat.creatorId
        
        switch chat.itemType {
            case 0: self.lastMessageText.textColor = UIColor.white.withAlphaComponent(0.6)
            case 5: self.lastMessageText.textColor = UIColor.AppColor.Blue.primaryBlue.withAlphaComponent(0.6)
            default:
                break
        }
    }
}
