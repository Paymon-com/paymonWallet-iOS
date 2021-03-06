//
// Created by Vladislav on 28/08/2017.
// Copyright (c) 2017 Paymon. All rights reserved.
//
import Foundation
import UIKit

import Contacts
import ContactsUI
import CoreStore
import MBProgressHUD

class ChatsViewController: PaymonViewController, UISearchBarDelegate, ListSectionObserver {
    typealias ListEntityType = ChatsData
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var chatsTable: UITableView!
    @IBOutlet weak var segment: UISegmentedControl!
    private var removeObserver: NSObjectProtocol!
    private var coreStoreWasCreated: NSObjectProtocol!

    private var messagesSaved: NSObjectProtocol!

    var allChats : ListMonitor<ChatsData>!
    var refresher: UIRefreshControl!
    var isUpdated = false
    
    var isAfterPasscode = false

    @IBAction func segmentChanges(_ sender: Any) {
        setChatsList()
    }
    
    @objc func refresh() {
        self.navigationItem.title = "Update...".localized
        self.chatsTable.allowsSelection = false

        isUpdated = false
        segment.selectedSegmentIndex = 1
        setChatsList()
        if User.shared.isAuthenticated {
            MessageManager.shared.loadChats()
        }
    }
    
    func setChatsTable() {
        self.chatsTable.dataSource = self
        self.chatsTable.delegate = self
        self.setChats()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.chatsTable.allowsSelection = false

        removeObserver = NotificationCenter.default.addObserver(forName: .removeObserver, object: nil, queue: nil) { notification in
            self.allChats = nil
        }
        
        coreStoreWasCreated = NotificationCenter.default.addObserver(forName: .coreStoreWasCreated, object: nil, queue: nil) { notification in
            print("Storage was added")

            self.setChatsTable()
        }
        
        setLayoutOptions()
        
        if isAfterPasscode {
            setChatsTable()
        }
        
        searchBar.delegate = self
        
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(ChatsViewController.refresh), for: UIControl.Event.valueChanged)
        chatsTable.addSubview(refresher)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if allChats != nil && allChats.numberOfObjects() != 0 {
            segment.selectedSegmentIndex = 1
            allChats.refetch([.init(), OrderBy<ChatsData>(.descending(\.time))])
        }
        
        messagesSaved = NotificationCenter.default.addObserver(forName: .isLoadedMore, object: nil, queue: nil) { notification in
            print("set enabled table")
            
            self.chatsTable.allowsSelection = true

            if self.chatsTable.allowsSelection {
                self.endUpdateChats()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(messagesSaved)
    }
    
    func setChats() {
        print("set chats")
        allChats = ChatsDataManager.shared.getAllChats()
        allChats.addObserver(self)
        DispatchQueue.main.async {
            self.chatsTable.reloadData()
        }
        
        if User.shared.isAuthenticated {
            isUpdated = false
            MessageManager.shared.loadChats()
        }
    }
    
    func listMonitorDidRefetch(_ monitor: ListMonitor<ChatsData>) {
        self.chatsTable.reloadData()
    }
    
    func listMonitorWillChange(_ monitor: ListMonitor<ChatsData>) {
        self.chatsTable.beginUpdates()
    }
    
    func listMonitorDidChange(_ monitor: ListMonitor<ChatsData>) {
        self.chatsTable.endUpdates()
    }
    
    func listMonitor(_ monitor: ListMonitor<ChatsData>, didInsertObject object: ChatsData, toIndexPath indexPath: IndexPath) {
        self.chatsTable.insertRows(at: [indexPath], with: .left)
    }
    
    func listMonitor(_ monitor: ListMonitor<ChatsData>, didDeleteObject object: ChatsData, fromIndexPath indexPath: IndexPath) {
        self.chatsTable.deleteRows(at: [indexPath], with: .left)
    }
    
    func listMonitor(_ monitor: ListMonitor<ChatsData>, didUpdateObject object: ChatsData, atIndexPath indexPath: IndexPath) {
        let chat = allChats[indexPath]
        
        if let cell = self.chatsTable.cellForRow(at: indexPath) as? ChatsTableViewCell {
            cell.configure(chat: chat)
        } else if let cell = self.chatsTable.cellForRow(at: indexPath) as? ChatsTableGroupViewCell {
            cell.configure(chat: chat)
        }
    }
    
    func endUpdateChats() {
        self.isUpdated = true

        DispatchQueue.main.async {
            self.navigationItem.title = "Chats".localized
            if self.refresher.isRefreshing {
                self.refresher.endRefreshing()
            }
        }
    }
    
    func setChatsList() {
        if allChats != nil {
            switch segment.selectedSegmentIndex {
            case 0:
                allChats.refetch([OrderBy<ChatsData>(.descending(\.time)), Where<ChatsData>("isGroup == %d", 0)])
            case 1:
                allChats.refetch([.init(), OrderBy<ChatsData>(.descending(\.time))])
            case 2:
                allChats.refetch([OrderBy<ChatsData>(.descending(\.time)), Where<ChatsData>("isGroup == %d", 1)])
            default:
                break
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            setChatsList()
            return
        }
        
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchText.lowercased())
        allChats.refetch([OrderBy<ChatsData>(.descending(\.time)), Where<ChatsData>(predicate)])
        
    }
    
    func searchBarCancelButtonShow(show : Bool) {
        UIView.animate(withDuration: 0.2, animations: {
            self.searchBar.showsCancelButton = show
            self.view.layoutIfNeeded()
        })
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        searchBar.text = ""
        setChatsList()
        self.searchBarCancelButtonShow(show: false)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBarCancelButtonShow(show: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.searchBarCancelButtonShow(show: false)
    }
    
    func setLayoutOptions() {
        self.view.setGradientLayer(frame: self.view.bounds, topColor: UIColor.AppColor.Black.primaryBlackLight.cgColor, bottomColor: UIColor.AppColor.Black.primaryBlack.cgColor)
        
        self.navigationItem.title = "Update...".localized
        self.segment.layer.cornerRadius = self.segment.frame.height/2
        self.segment.layer.masksToBounds = true
        self.segment.layer.borderWidth = 1.0
        self.segment.layer.borderColor = UIColor.gray.withAlphaComponent(0.7).cgColor

        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.8)]
        searchBar.placeholder = "Search for users or groups".localized
        searchBar.showsCancelButton = false
        
        segment.setTitle("Dialogs".localized, forSegmentAt: 0)
        segment.setTitle("All".localized, forSegmentAt: 1)
        segment.setTitle("Groups".localized, forSegmentAt: 2)
        
        segment.selectedSegmentIndex = 1
    }
    
    @IBAction func onClickAddContact(_ sender: Any) {
        self.navigationItem.title = "Chats".localized

        guard let vc = StoryBoard.chat.instantiateViewController(withIdentifier: "AddContactViewController") as? AddContactViewController else {return}
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        let mute = muteAction(at: indexPath)
//        let clear = clearAction(at: indexPath)
        let delete = deleteAction(at: indexPath)

//        if let cell = chatsTable.cellForRow(at: indexPath) as? ChatsTableGroupViewCell {
//            if cell.creatorId != User.shared.currentUser.id {
//                return UISwipeActionsConfiguration(actions: [delete])
//            }
//            return UISwipeActionsConfiguration(actions: [])
//        } else {
            return UISwipeActionsConfiguration(actions: [delete])
//        }
    }
    
    @available(iOS 11.0, *)
    func muteAction(at indexPath: IndexPath) -> UIContextualAction {
        
        let action = UIContextualAction(style: .normal, title: "Mute") { (action, view, completion) in
            //TODO: set mute chat
            completion(true)
        }
        
        action.image = #imageLiteral(resourceName: "Mute")
        action.backgroundColor = UIColor.AppColor.ChatsAction.blue
        
        return action
        
    }
    
    @available(iOS 11.0, *)
    func clearAction(at indexPath: IndexPath) -> UIContextualAction {
        
        let action = UIContextualAction(style: .normal, title: "Clear") { (action, view, completion) in
            //TODO: clear chat history
            completion(true)
        }
        
        action.image = #imageLiteral(resourceName: "History")
        action.backgroundColor = UIColor.AppColor.ChatsAction.orange
        
        return action
        
    }
    
    @available(iOS 11.0, *)
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        var title = ""
        guard let cell = chatsTable.cellForRow(at: indexPath) else {return UIContextualAction()}
        if cell is ChatsTableViewCell {
            title = "Delete".localized
        } else if let groupCell = cell as? ChatsTableGroupViewCell {
            title = groupCell.creatorId == User.shared.currentUser.id ? "Delete".localized : "Leave".localized
        }
        let action = UIContextualAction(style: .normal, title: title) { (action, view, completion) in
            
            if let actionCell = cell as? ChatsTableViewCell {
                self.leaveAlert(chatId: actionCell.chatId, isGroup: false)
            } else if let actionGroupCell = cell as? ChatsTableGroupViewCell {
                if actionGroupCell.creatorId == User.shared.currentUser.id {
                    self.leaveAlert(chatId: actionGroupCell.chatId, isGroup: false)
                } else {
                    self.leaveAlert(chatId: actionGroupCell.chatId, isGroup: true)
                }
            }
            
            completion(true)
        }
        
        action.backgroundColor = UIColor.AppColor.ChatsAction.red
        return action
        
    }
    
    func leaveAlert(chatId : Int32, isGroup : Bool) {
        let peer = isGroup ? RPC.PM_peerGroup(group_id: chatId) : RPC.PM_peerUser(user_id: chatId)

        let funcsMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancel = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)
        let leave = UIAlertAction(title: "Leave".localized, style: .destructive, handler: { (alert: UIAlertAction!) -> Void in
            let leaveChat = RPC.PM_leaveChat(peer: peer);
            self.sendRequestLeaveOrClear(packet: leaveChat, chatId: chatId)

        })
        let clearHistory = UIAlertAction(title: "Clear the history".localized, style: .destructive, handler: { (alert: UIAlertAction!) -> Void in
            let clearChat = RPC.PM_clearChat(peer: peer);
            self.sendRequestLeaveOrClear(packet: clearChat, chatId: chatId)
        })
        
        
        funcsMenu.addAction(cancel)
        funcsMenu.addAction(clearHistory)
        if isGroup {
            funcsMenu.addAction(leave)
        }
        
        if let popoverController = funcsMenu.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        self.present(funcsMenu, animated: true, completion: nil)
    }
    
    func sendRequestLeaveOrClear(packet : Packet, chatId : Int32) {
        DispatchQueue.main.async {
            let _ = MBProgressHUD.showAdded(to: self.view, animated: true)
        }
        
        NetworkManager.shared.sendPacket(packet) { response, e in
            if (response != nil && response is RPC.PM_boolTrue) {
                
                if let chatsData = ChatsDataManager.shared.getChatByIdSync(id: chatId) {
                    ChatsDataManager.shared.removeChat(chatsData: chatsData) { _ in
                        DispatchQueue.main.async {
                            MBProgressHUD.hide(for: self.view, animated: true)
                        }
                    }
                }
            } else {
                let _ = SimpleOkAlertController(title: "Clear the history".localized, message: "Failed to clear the history, please try again later".localized, vc: self)
            }
        }
    }
}

extension ChatsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allChats.numberOfObjects()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if let chat = allChats[indexPath] as ChatsData? {
            if !chat.isGroup {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ChatsTableViewCell") as! ChatsTableViewCell
                cell.configure(chat: chat)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ChatsTableGroupViewCell") as! ChatsTableGroupViewCell
                cell.configure(chat: chat)
                return cell
            }
        }
    }
}
extension ChatsViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chat = allChats[indexPath]
        tableView.deselectRow(at: indexPath, animated: true)
        let chatViewController = storyboard?.instantiateViewController(withIdentifier: VCIdentifier.chatViewController) as! ChatViewController
        chatViewController.setValue(chat.title, forKey: "title")
        chatViewController.isGroup = chat.isGroup
        chatViewController.chatID = chat.id
        print(chat.id)

        self.navigationItem.title = "Chats".localized

        DispatchQueue.main.async {
            self.navigationController?.pushViewController(chatViewController, animated: true)
        }
    }
}
