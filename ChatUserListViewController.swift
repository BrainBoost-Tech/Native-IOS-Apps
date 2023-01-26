//
//  ChatUserListViewController.swift
//  jaminwithus
//
//  Created by office on 01/02/2022.
//  Copyright © 2022 Hafiz Anser. All rights reserved.
//

import UIKit
import SwiftyJSON

class ChatUserListViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!{
        didSet{
            searchBar.delegate = self
        }
    }
    
    @IBOutlet weak var userTabelView: UITableView!{
        didSet{
            userTabelView.delegate = self
            userTabelView.dataSource = self
        }
    }
    
    var chatUserList = [ChatUserListModel]()
    var filterUserList = [ChatUserListModel]()
    var isFromGroupChat = false
    var groupID: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getUserList()
    }
    
    @IBAction func btnBackTapped(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    func getUserList(){
        AppUtility.showProgress()
        
        guard let user = AppUtility.shared.session, let userID = user.ID, let token = user.token else {
            return
        }
        let paramDict = ["token":token]
        
        RequestClient().PostFormData(SERVER_BASE_URL + USER_LIST, parameters: paramDict) {
            [unowned self] (response) in
            print(response)
            
            AppUtility.hideProgress()
            
            do {
                if let rawPersons = response as? GenDictionary {
                    let jsonData = try JSON(data: rawPersons.to_data)
                    print(jsonData)
                    let data = jsonData["data"]
                    print(data)
                    for da in data{
                        let model = ChatUserListModel.init(fromJson: da.1)
                        self.chatUserList.append(model)
                    }
                    self.filterUserList = self.chatUserList
                }
               
                
            } catch{
                print(error.localizedDescription)
            }
            
//            if let rawPersons = response as? GenDictionary {
//                print(rawPersons)
//
//                let jsonData = try JSON(data: response["data"] )
//
//                for da in data{
//                    let model = ChatUserListModel.init(fromJson: da)
//                }
////                if let feedback = try? JSONDecoder().decode([ChatUserListModel].self, from: data as! Data) {
////                    chatUserList = feedback
////                }
//            }
            userTabelView.reloadData()
            
            
            return
        } failure: {
            [unowned self] (error) in
            AppUtility.hideProgress()
            self.showErrorAlert(error: error)
        }
    }

}

extension ChatUserListViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterUserList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        userTabelView.register(UINib(nibName: "ChatUserListTableViewCell", bundle: nil), forCellReuseIdentifier: "ChatUserListTableViewCell")
        let cell = userTabelView.dequeueReusableCell(withIdentifier: "ChatUserListTableViewCell", for: indexPath) as! ChatUserListTableViewCell
        cell.configCell(model: filterUserList[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isFromGroupChat{
            self.addMember(indx: indexPath.row)
        }else{
            let viewController = ChatViewController()
            viewController.hidesBottomBarWhenPushed = true
            viewController.strName = filterUserList[indexPath.row].fname
            viewController.toUserId = filterUserList[indexPath.row].id
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func addMember(indx: Int){
        AppUtility.showProgress()
        
        guard let user = AppUtility.shared.session, let userID = user.ID, let token = user.token else {
            return
        }
        let paramDict = ["token":token,
                         "user_id":userID,
                         "group_id":groupID,
                         "member_id": filterUserList[indx].id!]
        
        RequestClient().PostFormData(SERVER_BASE_URL + ADD_GROUP_MEMBER, parameters: paramDict) {
            [unowned self] (response) in
            print(response)
            
            AppUtility.hideProgress()
            
            do {
                if let rawPersons = response as? GenDictionary {
                    let jsonData = try JSON(data: rawPersons.to_data)
                    print(jsonData)
                    
                    self.navigationController?.popViewController(animated: true)
//                    let msg = jsonData["msg"].stringValue
//                    self.showSuccessAlert(msg: msg)
                }
                
                
            } catch{
                print(error.localizedDescription)
            }
            
            
            return
        } failure: {
            (error) in
            AppUtility.hideProgress()
            //            self.showErrorAlert(error: error)
        }
    }
}

extension ChatUserListViewController: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText:String){
//        filterUserList = chatUserList.filter({ $0.hasPrefix(searchText)})
        filterUserList = searchText.isEmpty ? chatUserList : chatUserList.filter{ $0.fname.contains(searchText)}
        userTabelView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
}
