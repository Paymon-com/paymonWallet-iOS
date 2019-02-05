//
//  MessageDataManager.swift
//  paymon
//
//  Created by Maxim Skorynin on 17/10/2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation
import CoreStore

class MessageDataManager {
    
    static let shared = MessageDataManager()
    
    let dispatchGroup = DispatchGroup()
    
    func saveChatMessageData(messageData : ChatMessageData, messageObject : RPC.Message) {
        messageData.id = messageObject.id
        messageData.unread = messageObject.unread
        messageData.toId = messageObject.to_id
//        print(messageObject.from_id)
        messageData.fromId = messageObject.from_id
        messageData.date = messageObject.date
        messageData.dateString = Utils.formatDateTimeChatHeader(timestamp: messageObject.date)
        messageData.text = messageObject.text
        messageData.itemType = Int16(messageObject.itemType.rawValue)
        messageData.action = messageObject.action != nil ? messageObject.action.type : 0
        print("saved message")
    }
    
    func saveMessage(messageObject : RPC.Message) {
        dispatchGroup.enter()
        CacheManager.shared.dataStack.perform(asynchronous: {(transaction) -> Void in
            if let messageData = transaction.fetchOne(From<ChatMessageData>().where(\.id == messageObject.id)) {
                self.saveChatMessageData(messageData: messageData, messageObject: messageObject)
            } else {
                let messageData = transaction.create(Into<ChatMessageData>())
                self.saveChatMessageData(messageData: messageData, messageObject: messageObject)
            }
        }, completion: { _ -> Void in
            self.dispatchGroup.leave()
        })
    }
    
    func updateMessage(messageObject : RPC.Message) {
        saveMessage(messageObject: messageObject)
        if messageObject.to_peer is RPC.PM_peerUser {
            guard let uid = messageObject.from_id == User.shared.currentUser.id ? messageObject.to_peer.user_id : messageObject.from_id else {
                    return
                }
            if let user = UserDataManager.shared.getUserByIdSync(id: uid) {
                self.setChatsDataByUserData(userObject: user, messageObject: messageObject)
            } else {
                let getUserInfo = RPC.PM_getUserInfo(user_id: uid)
                NetworkManager.shared.sendPacket(getUserInfo) { response, e in
                    if response == nil || e != nil {return}
                    if let userObject = response as? RPC.UserObject {
                        UserDataManager.shared.createUser(userObject: userObject)
                        self.setChatsDataByUserObject(userObject: userObject, messageObject: messageObject)
                    }
                }
            }
        } else {
            let gid = messageObject.to_peer.group_id
            if let group = GroupDataManager.shared.getGroupByIdSync(id: gid!) {
                if let lastMessageUser = UserDataManager.shared.getUserByIdSync(id: messageObject.from_id) {
                    ChatsDataManager.shared.updateGroupChats(groupObject : group, messageObject : messageObject, lastMessagePhotoUrl: lastMessageUser.photoUrl!)
                }
            } else {
                
            }
        }
    }
    
    func addMoreOldMessages(_ messages : [RPC.Message]) {
        for message in messages {
            saveMessage(messageObject: message)
        }
        self.dispatchGroup.notify(queue: .main, execute: {
            NotificationCenter.default.post(name: .isLoadedMore, object: nil)
        })
    }
    
    func setChatsDataByUserObject(userObject : RPC.UserObject, messageObject: RPC.Message) {
        let chatsData = ChatsDataManager.shared.getChatByIdSync(id: userObject.id)
        
        if chatsData != nil {
            ChatsDataManager.shared.updateChatsInfo(chatId : chatsData!.id, itemType : Int16(messageObject.itemType.rawValue), lastMessageText : messageObject.text, photoUrl : userObject.photoUrl.url, time : messageObject.date)
        } else {
            ChatsDataManager.shared.updateUserChats(userObject: userObject, messageObject : messageObject)
        }
    }
    
    func setChatsDataByUserData(userObject : UserData, messageObject: RPC.Message) {
        let chatsData = ChatsDataManager.shared.getChatByIdSync(id: userObject.id)
        
        if chatsData != nil {
            ChatsDataManager.shared.updateChatsInfo(chatId : chatsData!.id, itemType : Int16(messageObject.itemType.rawValue), lastMessageText : messageObject.text, photoUrl : userObject.photoUrl!, time : messageObject.date)
        } else {
            ChatsDataManager.shared.updateUserChats(userObject: userObject, messageObject : messageObject)
        }
    }
    
    func updateMessages(_ messages : [RPC.Message]) {
//        DispatchQueue.main.async {
//            NotificationCenter.default.post(name: .isLoadedMore, object: nil)
//        }
        for message in messages {
            updateMessage(messageObject: message)
        }
        self.dispatchGroup.notify(queue: .main, execute: {
            NotificationCenter.default.post(name: .isLoadedMore, object: nil)
        })
    }
    
    func getMessagesByChatId(chatId : Int32) -> ListMonitor<ChatMessageData>? {

        if let result = CacheManager.shared.dataStack.monitorSectionedList(
            From<ChatMessageData>()
                
                .sectionBy(\.dateString)
                .where(\.toId == chatId)
                .tweak { $0.fetchBatchSize = 30 }
                .orderBy(.descending(\.date))) as ListMonitor<ChatMessageData>? {

            return result
        } else {
            print("Could not get all messages by chat id")
            return nil
        }
    }
    
    func getAllMessages() -> [ChatMessageData] {
        
        guard let result = CacheManager.shared.dataStack.fetchAll(From<ChatMessageData>()) else {
            print("Could not get all messages")
            return [ChatMessageData]()
        }
        
        return result
    }
    
    func getMessageByIdSync(id : Int64) -> ChatMessageData? {
        
        var result : ChatMessageData! = nil
        
        DispatchQueue.main.sync {
            if let msg = CacheManager.shared.dataStack.fetchOne(
                From<ChatMessageData>()
                    .where(\.id == id)
                ) as ChatMessageData? {
                result = msg
            }
        }
        return result
    }
    
    func deleteMessage(msgID : Int64) {
        if let chatMessageData = getMessageByIdSync(id: msgID) {
            CacheManager.shared.dataStack.perform(
                asynchronous: { (transaction) -> Void in
                    transaction.delete(chatMessageData) },
                completion: { _ in })
        }
    }
    
    func deleteMessages(messageIDs : [Int64]) {
        for id in messageIDs {
            deleteMessage(msgID: id)
        }
    }
    
    func deleteAllMessagesByToId(chatId : Int32) {
        CacheManager.shared.dataStack.perform(asynchronous: { (transaction) -> Void in
            transaction.deleteAll(
                From<ChatMessageData>()
            .where(\.toId == chatId))
        }, completion: {_ in})
    }
    
}
