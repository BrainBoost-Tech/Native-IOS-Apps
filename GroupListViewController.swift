//
//  GroupListViewController.swift
//  jaminwithus
//
//  Created by office on 22/02/2022.
//  Copyright © 2022 Hafiz Anser. All rights reserved.
//

import UIKit
import SwiftyJSON

class GroupListViewController: UIViewController {
    
    @IBOutlet weak var btnAdd: UIButton!{
        didSet{
            btnAdd.layer.cornerRadius = btnAdd.frame.height / 2
        }
    }
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var mainView: UIView!{
        didSet{
            let gesture = UITapGestureRecognizer.init(target: self, action: #selector(hideView(_:)))
            mainView.addGestureRecognizer(gesture)
        }
    }
    @IBOutlet weak var groupView: UIView!{
        didSet{
            groupView.layer.cornerRadius = 10.0
        }
    }
    
    @IBOutlet weak var btnDone: UIView!{
        didSet{
            btnDone.layer.cornerRadius = 10.0
        }
    }
    
    @IBOutlet weak var groupListTV: UITableView!{
        didSet{
            groupListTV.delegate = self
            groupListTV.dataSource = self
        }
    }
    
    var groupList = [GroupModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mainView.isHidden = true
        self.groupView.isHidden = true

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getChatList()
    }
    
    @objc func hideView(_ gesture: UITapGestureRecognizer){
        self.mainView.isHidden = true
        self.groupView.isHidden = true
    }
    
    @IBAction func btnBackTapped(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnNewTapped(){
        self.mainView.isHidden = false
        self.groupView.isHidden = false
    }
    
    func getChatList(){
        AppUtility.showProgress()
        
        guard let user = AppUtility.shared.session, let userID = user.ID, let token = user.token else {
            return
        }
        let paramDict = ["token":token,
                         "user_id":userID]
        
        RequestClient().PostFormData(SERVER_BASE_URL + CHAT_GROUP_LIST, parameters: paramDict) {
            [unowned self] (response) in
            print(response)
            
            AppUtility.hideProgress()
            
            do {
                groupList.removeAll()
                if let rawPersons = response as? GenDictionary {
                    let jsonData = try JSON(data: rawPersons.to_data)
                    print(jsonData)
                    let data = jsonData["data"]
                    print(data)
                    for da in data{
                        let model = GroupModel.init(fromJson: da.1)
                        self.groupList.append(model)
                    }
                }
                
                
            } catch{
                print(error.localizedDescription)
            }
            groupListTV.reloadData()
            
            
            return
        } failure: {
            [unowned self] (error) in
            AppUtility.hideProgress()
            self.showErrorAlert(error: error)
        }
    }
    
    @IBAction func btnCloseTapped(_ sender: UIButton){
        self.mainView.isHidden = true
        self.groupView.isHidden = true
    }
    
    
    @IBAction func btnDoneTapped(_ sender: UIButton){
        guard let name = tfName.text, tfName.text != "" else {
            self.showSuccessAlert(msg: "Please Enter Group Name.")
            return
        }
        guard let user = AppUtility.shared.session, let userID = user.ID, let token = user.token else {
            return
        }
        let paramDict = ["token":token,
                         "user_id":userID,
                         "group_name": name]
        
        RequestClient().PostFormData(SERVER_BASE_URL + CREATE_CHAT_GROUP, parameters: paramDict) {
            [unowned self] (response) in
            print(response)
            
            AppUtility.hideProgress()
            
            do {
                if let rawPersons = response as? GenDictionary {
                    let jsonData = try JSON(data: rawPersons.to_data)
                    print(jsonData)
                    let data = jsonData["data"]
                    print(data)
                    self.mainView.isHidden = true
                    self.groupView.isHidden = true
                    self.getChatList()
                }
                
                
            } catch{
                print(error.localizedDescription)
            }
            return
        } failure: {
            [unowned self] (error) in
            AppUtility.hideProgress()
            self.showErrorAlert(error: error)
        }
        
    }
    
}

extension GroupListViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        groupListTV.register(UINib(nibName: "ChatUserListTableViewCell", bundle: nil), forCellReuseIdentifier: "ChatUserListTableViewCell")
        let cell = groupListTV.dequeueReusableCell(withIdentifier: "ChatUserListTableViewCell", for: indexPath) as! ChatUserListTableViewCell
        cell.configCell(model: groupList[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController = ChatViewController()
        viewController.hidesBottomBarWhenPushed = true
        viewController.strName = groupList[indexPath.row].groupName
        viewController.toUserId = groupList[indexPath.row].id
        viewController.strNoti = groupList[indexPath.row].notifications
        viewController.isFromGroup = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

