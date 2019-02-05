//
// Created by Vladislav on 01/09/2017.
// Copyright (c) 2017 Paymon. All rights reserved.
//

import UIKit
import UserNotifications
import CoreStore
import MBProgressHUD

class ChatViewController: PaymonViewController, ListSectionObserver {
    
    typealias ListEntityType = ChatMessageData
    
    @IBOutlet weak var messageTextView: UITextView!

    @IBOutlet weak var backButton: UIBarButtonItem!
    
    @IBOutlet weak var sendButtonImage: UIImageView!
    @IBOutlet weak var messagesView: UIView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var constraintViewBottom: NSLayoutConstraint!

    @IBOutlet weak var chatTitle: UILabel!
    @IBOutlet weak var chatSubtitle: UILabel!
    @IBOutlet weak var customTitleView: UIView!
    @IBOutlet weak var doneItem: UIBarButtonItem!
    @IBOutlet weak var actionMenuBottomSpace: NSLayoutConstraint!
    @IBOutlet weak var deleteMessages: UIButton!
    private var removeObserver: NSObjectProtocol!

    private var isLoadedMore: NSObjectProtocol!
    
    var mainTint : UIColor!
    
    let standartBottomSpace = CGFloat(-104)
    let indentTop = CGFloat(100.0)
    
    var messages : ListMonitor<ChatMessageData>!
    var chatID: Int32!
    var isGroup: Bool!
    var startView = true
    var messagesForDelete : [Int64 : Int64] = [:]
    
    var messageCountForUpdate : Int! = 0
    var firstLoaded = false
    var isEdit = false
    var isLoadingMore = false
    
    @IBAction func onSendClicked() {
        guard let text = messageTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty, text != "To write a message".localized else {return}
        messageTextView.text = ""
        textViewDidChange(messageTextView)
        MessageManager.shared.sendMessage(text: text, isGroup: isGroup, chatId: chatID)
    }
    
    @IBAction func deleteMessagesClick(_ sender: Any) {
        if isEdit && !messagesForDelete.isEmpty {
            let alertController = UIAlertController(title: "Remove messages".localized, message: "Are you sure you want to delete these messages?".localized, preferredStyle: .alert)
            
            let confirmAction = UIAlertAction(title: "Remove".localized, style: .default) { _ in
                var messagesIDs : [Int64] = []
                for id in self.messagesForDelete.values {
                    messagesIDs.append(id)
                }
                
                if !self.isGroup {
                    let deleteDialogMessages = RPC.PM_deleteDialogMessages()
                    deleteDialogMessages.messageIDs = messagesIDs
                    NetworkManager.shared.sendPacket(deleteDialogMessages) { response, error in
                        if error != nil || response == nil {
                            print("error delete dialog messages")
                            return
                        }
                        if response is RPC.PM_boolTrue {
                            MessageDataManager.shared.deleteMessages(messageIDs: messagesIDs)
                        }
                    }

                } else {
                    let deleteGroupMessages = RPC.PM_deleteGroupMessages()
                    deleteGroupMessages.messageIDs = messagesIDs
                    print(deleteGroupMessages.messageIDs)
                    NetworkManager.shared.sendPacket(deleteGroupMessages) { response, error in
                        if error != nil || response == nil {
                            print("error delete group messages")
                            return
                        }
                        if response is RPC.PM_boolTrue {
                            MessageDataManager.shared.deleteMessages(messageIDs: messagesIDs)
                        }
                    }
                }
                
                self.setEditMode()
                
            }
            let cancelAction = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)
            alertController.addAction(confirmAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func doneClick(_ sender: Any) {
        setEditMode()
    }
    
    func setLayoutOptions() {
        chatTableView.transform = CGAffineTransform(rotationAngle: -(CGFloat)(Double.pi))
        messageTextView.layer.cornerRadius = messageTextView.frame.height/2
        messageTextView.text = "To write a message".localized
        messageTextView.textColor = UIColor.white.withAlphaComponent(0.4)
        messageTextView.translatesAutoresizingMaskIntoConstraints = false
        messageTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

        mainTint = doneItem.tintColor
        doneItem.title = "Done".localized
        doneItem.tintColor = isEdit ? mainTint : UIColor.clear
        doneItem.isEnabled = isEdit

        textViewDidChange(messageTextView)
        
        self.chatTitle.text = value(forKey: "title") as? String
        
        self.view.setGradientLayer(frame: self.view.bounds, topColor: UIColor.AppColor.Black.primaryBlackLight.cgColor, bottomColor: UIColor.AppColor.Black.primaryBlack.cgColor)
        
        sendButton.layer.cornerRadius = sendButton.frame.height/2
        deleteMessages.layer.cornerRadius = deleteMessages.frame.height/2
        deleteMessages.setTitle("Remove".uppercased().localized, for: .normal)
        customTitleView.sizeToFit()
        if self.backButton != nil {
            self.backButton.title = "Back".localized
        }
        
        if isGroup {
            if let group = GroupDataManager.shared.getGroupById(id: chatID) {
                var text = "Participants: ".localized
                text.append("\(group.users.count)")
                
                chatSubtitle.text = text
            }
            
        } else {
            chatSubtitle.text = ""
        }
    }
    
    @IBAction func titleClick(_ sender: Any) {
        
        if isGroup {
            guard let groupSettingVC = storyboard?.instantiateViewController(withIdentifier: VCIdentifier.groupSettingViewController) as? GroupSettingViewController else {return}
            groupSettingVC.groupId = chatID
            
            navigationController?.pushViewController(groupSettingVC, animated: true)
        } else {
            guard let friendProfileVC = storyboard?.instantiateViewController(withIdentifier: VCIdentifier.friendProfileViewController) as? FriendProfileViewController else {return}
            friendProfileVC.id = chatID
            friendProfileVC.fromChat = true
            
            navigationController?.pushViewController(friendProfileVC, animated: true)
        }
    }
    
    func listMonitorDidRefetch(_ monitor: ListMonitor<ChatMessageData>) {
        self.chatTableView.reloadData()
    }
    
    func listMonitorWillChange(_ monitor: ListMonitor<ChatMessageData>) {
        self.chatTableView.beginUpdates()
    }
    
    func listMonitorDidChange(_ monitor: ListMonitor<ChatMessageData>) {

        self.chatTableView.endUpdates()
        if !firstLoaded {
            self.reloadChat()
        }
    }
    
    func listMonitor(_ monitor: ListMonitor<ChatMessageData>, didInsertObject object: ChatMessageData, toIndexPath indexPath: IndexPath) {

        if object.toId == chatID {
            self.chatTableView.insertRows(at: [indexPath], with: .bottom)
        }
    }
    
    func listMonitor(_ monitor: ListMonitor<ChatMessageData>, didDeleteObject object: ChatMessageData, fromIndexPath indexPath: IndexPath) {
        self.chatTableView.deleteRows(at: [indexPath], with: .left)
    }
    
    func listMonitor(_ monitor: ListMonitor<ChatMessageData>, didInsertSection sectionInfo: NSFetchedResultsSectionInfo, toSectionIndex sectionIndex: Int) {
            self.chatTableView.insertSections(IndexSet(integer: sectionIndex), with: .bottom)
    }
    
    func listMonitor(_ monitor: ListMonitor<ChatMessageData>, didDeleteSection sectionInfo: NSFetchedResultsSectionInfo, fromSectionIndex sectionIndex: Int) {
        self.chatTableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
    }
    
    func listMonitor(_ monitor: ListMonitor<ChatMessageData>, didUpdateObject object: ChatMessageData, atIndexPath indexPath: IndexPath) {
        
        let message = messages[indexPath]
        
        if let cell = chatTableView.cellForRow(at: indexPath) as? ChatMessageViewCell {
            cell.configure(message: message)
        } else if let cell = chatTableView.cellForRow(at: indexPath) as? GroupChatMessageRcvViewCell {
            cell.configure(message: message)
            if cell.photo.gestureRecognizers?.count != 0 {
                let tapPhoto = UITapGestureRecognizer(target: self, action: #selector(self.clickPhoto(_:)))
                cell.photo.isUserInteractionEnabled = true
                cell.photo.addGestureRecognizer(tapPhoto)
            }
        } else if let cell = chatTableView.cellForRow(at: indexPath) as?  ChatMessageRcvViewCell {
            cell.configure(message: message)
        }
    }
    
    func showTable() {
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)
            self.chatTableView.reloadData()
            self.chatTableView.isHidden = false
        }
    }
    
    func setMessages() {
        messages = MessageDataManager.shared.getMessagesByChatId(chatId: chatID)
        messages.addObserver(self)

        if messages.numberOfObjects() == 1 {
            let _ = MBProgressHUD.showAdded(to: self.view, animated: true)
        } else {
            firstLoaded = true
            showTable()
        }
        
        loadMessages(offset: 0, count : 30)
    }
    
    func reloadChat() {
        if messages.numberOfObjects() == messageCountForUpdate {
            showTable()
            firstLoaded = true
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.chatTableView.isHidden = true
        
        removeObserver = NotificationCenter.default.addObserver(forName: .removeObserver, object: nil, queue: nil) { notification in
            self.messages = nil
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
        isLoadedMore = NotificationCenter.default.addObserver(forName: .isLoadedMore, object: nil, queue: nil) { notification in
            self.isLoadingMore = false
        }

        setLayoutOptions()
        
        chatTableView.delegate = self
        chatTableView.dataSource = self
        
        messageTextView.delegate = self
        
        setMessages()
    }


    @objc func handleKeyboardNotification(notification: NSNotification) {

        if let userInfo = notification.userInfo {
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect

            let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification

            constraintViewBottom.constant = isKeyboardShowing ? -keyboardFrame!.height : 0

            UIView.animate(withDuration: 0,
                           delay: 0,
                           options: UIView.AnimationOptions.curveEaseOut,
                           animations: {
                            self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(isLoadedMore)
        
    }
    
    @objc func clickPhoto(_ sender : UITapGestureRecognizer) {
        guard let photo = sender.view as? CircularImageView else {return}
        
        guard let friendProfileVC = storyboard?.instantiateViewController(withIdentifier: VCIdentifier.friendProfileViewController) as? FriendProfileViewController else {return}
        friendProfileVC.id = photo.fromId
        friendProfileVC.fromChat = false
        
        navigationController?.pushViewController(friendProfileVC, animated: true)
        
    }
 
    public func loadMessages(offset : Int32, count : Int32) {
        if User.shared.currentUser == nil || chatID == 0 {
            return
        }
        
        if Connectivity.isConnectedToInternet {
            let packet = RPC.PM_getChatMessages()
            
            packet.chatID = isGroup ? RPC.PM_peerGroup(group_id: chatID) : RPC.PM_peerUser(user_id: chatID)
            packet.count = count
            packet.offset = offset
            
            NetworkManager.shared.sendPacket(packet) {response, e in
                if response == nil { return }
                if let packet = response as? RPC.PM_chatMessages {
                    if (packet.messages.count != 0) {
                        self.messageCountForUpdate = packet.messages.count
                        self.reloadChat()
                        MessageDataManager.shared.addMoreOldMessages(packet.messages)
                    } else {
                        self.messageCountForUpdate = 1
                        self.reloadChat()
                    }
                }
            }
        } else {
            self.messageCountForUpdate = 1
            self.reloadChat()
        }
    }
}

extension ChatViewController : MoreActionDelegate {
    func showEditButton() {
        setEditMode()
    }
    
    func setEditMode() {
        isEdit = !isEdit
        self.chatTableView.setEditing(isEdit, animated: true)
        self.chatTableView.allowsMultipleSelectionDuringEditing = true
        self.doneItem.isEnabled = isEdit
        doneItem.tintColor = isEdit ? mainTint : UIColor.clear
        messagesForDelete.removeAll()
        showActionMenu()
    }
    
    func showActionMenu() {
        messagesView.isHidden = isEdit
        actionMenuBottomSpace.constant = isEdit ? 0 : standartBottomSpace
    }
}


extension ChatViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return messages.numberOfSections()
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.numberOfObjectsInSection(section)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let message = messages[indexPath] as ChatMessageData? {
            if message.fromId == User.shared.currentUser!.id {
                if message.itemType == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "ChatMessageViewCell", for: indexPath) as! ChatMessageViewCell
                    cell.configure(message: message)
                    cell.bubble.delegate = self
                    cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
                    return cell
                } else if message.itemType == 5 {
                    if let group = GroupDataManager.shared.getGroupById(id: message.toId) {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatsTableCretedGroupCell") as! ChatsTableCretedGroupCell
                        cell.configure(group : group)
                        cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
                        return cell
                    }
                }
            } else {
                if isGroup {
                    if message.itemType == 0 {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupChatMessageRcvViewCell") as! GroupChatMessageRcvViewCell
                        cell.configure(message: message)
                        let tapPhoto = UITapGestureRecognizer(target: self, action: #selector(self.clickPhoto(_:)))
                        cell.photo.isUserInteractionEnabled = true
                        cell.photo.addGestureRecognizer(tapPhoto)
                        cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
                        return cell
                    } else if message.itemType == 5 {
                        if let group = GroupDataManager.shared.getGroupById(id: message.toId) {
                            if let creator = UserDataManager.shared.getUserById(id: group.creatorId) {
                                let cell = tableView.dequeueReusableCell(withIdentifier: "ChatsTableCretedGroupCell") as! ChatsTableCretedGroupCell
                                cell.label.text = "\(Utils.formatUserDataName(creator)) "+"created the group chat ".localized+"\"\(group.title!)\""
                                cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
                                return cell
                            }
                        }
                    }
                } else {
                    if message.itemType == 0 {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatMessageRcvViewCell") as! ChatMessageRcvViewCell
                        cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
                        cell.configure(message: message)
                        return cell
                    }
                }
            }
        }
        
        return UITableViewCell()
    }
    
}

extension ChatViewController: UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
        
        if !isLoadingMore && (maximumOffset - contentOffset <= indentTop) && firstLoaded {
            isLoadingMore = true
            loadMessages(offset: Int32(messages.numberOfObjects()), count : 30)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if isEdit {
            guard let cell = tableView.cellForRow(at: indexPath) as? ChatMessageViewCell else {return}
            messagesForDelete.removeValue(forKey: cell.id)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isEdit {
            guard let cell = tableView.cellForRow(at: indexPath) as? ChatMessageViewCell else {return}
            messagesForDelete[cell.id] = cell.id
        }
        messageTextView.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = messages.sectionInfoAtIndex(safeSectionIndex: section)!.name
        label.textColor = UIColor.white.withAlphaComponent(0.4)
        label.center = tableView.center
        label.font = !SetterStoryboards.shared.isiPad ? UIFont.boldSystemFont(ofSize: 10) : UIFont.boldSystemFont(ofSize: 16)
        label.textAlignment = .center
        label.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
        return label
    }
}

extension ChatViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        
        let size = CGSize(width: textView.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        textView.constraints.forEach{ (constraint) in
            if constraint.firstAttribute == .height {
                constraint.constant = estimatedSize.height + 4
                var offset = textView.contentOffset
                offset.y = 0
                textView.setContentOffset(offset, animated: true)
            }
        }
        
        if !textView.text.isEmpty && textView.text != "To write a message".localized {
            UIView.animate(withDuration: 0.2, animations: {
                self.sendButton.backgroundColor = UIColor.white.withAlphaComponent(0.8)
                self.sendButtonImage.image = #imageLiteral(resourceName: "SendColor")
                self.sendButtonImage.transform = CGAffineTransform(rotationAngle: CGFloat.pi/4)
                self.view.layoutIfNeeded()
            })
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                self.sendButton.backgroundColor = UIColor.white.withAlphaComponent(0.4)
                self.sendButtonImage.image = #imageLiteral(resourceName: "SendGray")
                self.sendButtonImage.transform = CGAffineTransform(rotationAngle: 0)

                self.view.layoutIfNeeded()

            })
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {

        if textView.textColor == UIColor.white.withAlphaComponent(0.4) {
            DispatchQueue.main.async {
                textView.text = ""
                textView.textColor = UIColor.white.withAlphaComponent(0.8)
            }
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            DispatchQueue.main.async {
                textView.text = "To write a message".localized
                textView.textColor = UIColor.white.withAlphaComponent(0.4)
            }
        }
    }
}
