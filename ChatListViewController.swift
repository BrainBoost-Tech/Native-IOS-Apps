//
//  ChatListViewController.swift
//  jaminwithus
//
//  Created by office on 16/02/2022.
//  Copyright © 2022 Hafiz Anser. All rights reserved.
//

import UIKit
import SwiftyJSON

class ChatListViewController: UIViewController {

    @IBOutlet weak var btnAdd: UIButton!{
        didSet{
            btnAdd.layer.cornerRadius = btnAdd.frame.height / 2
        }
    }
    @IBOutlet weak var chatListTV: UITableView!{
        didSet{
            chatListTV.delegate = self
            chatListTV.dataSource = self
        }
    }
    
    var chatList = [ChatListModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getChatList()
    }
    
    @IBAction func btnBackTapped(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnNewTapped(){
        let viewController = ChatUserListViewController()
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func getChatList(){
        AppUtility.showProgress()
        
        guard let user = AppUtility.shared.session, let userID = user.ID, let token = user.token else {
            return
        }
        let paramDict = ["token":token,
                         "user_id":userID]
        
        RequestClient().PostFormData(SERVER_BASE_URL + CHAT_LIST, parameters: paramDict) {
            [unowned self] (response) in
            print(response)
            
            AppUtility.hideProgress()
            
            do {
                chatList.removeAll()
                if let rawPersons = response as? GenDictionary {
                    let jsonData = try JSON(data: rawPersons.to_data)
                    print(jsonData)
                    let data = jsonData["data"]
                    print(data)
                    for da in data{
                        let model = ChatListModel.init(fromJson: da.1)
                        self.chatList.append(model)
                    }
                }
               
                
            } catch{
                print(error.localizedDescription)
            }
            chatListTV.reloadData()
            
            
            return
        } failure: {
            [unowned self] (error) in
            AppUtility.hideProgress()
            self.showErrorAlert(error: error)
        }
    }

}

extension ChatListViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        chatListTV.register(UINib(nibName: "ChatUserListTableViewCell", bundle: nil), forCellReuseIdentifier: "ChatUserListTableViewCell")
        let cell = chatListTV.dequeueReusableCell(withIdentifier: "ChatUserListTableViewCell", for: indexPath) as! ChatUserListTableViewCell
        cell.configCell(model: chatList[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController = ChatViewController()
        viewController.hidesBottomBarWhenPushed = true
        viewController.strName = chatList[indexPath.row].fname
        viewController.toUserId = chatList[indexPath.row].message.toUserId
        viewController.isBlock = chatList[indexPath.row].isBlocked == "0" ? false : true
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
