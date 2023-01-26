//
//  GroupRequestViewController.swift
//  jaminwithus
//
//  Created by office on 27/03/2022.
//  Copyright © 2022 Hafiz Anser. All rights reserved.
//

import UIKit
import SwiftyJSON

class GroupRequestViewController: UIViewController {

    @IBOutlet weak var groupReqTV: UITableView!{
        didSet{
            groupReqTV.delegate = self
            groupReqTV.dataSource = self
        }
    }
    var reqList = [GroupRequestModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getGroupRequest()
    }
    
    func getGroupRequest(){
        AppUtility.showProgress()
        
        guard let user = AppUtility.shared.session, let userID = user.ID, let token = user.token else {
            return
        }
        let paramDict = ["token":token,
                         "user_id":userID]
        
        RequestClient().PostFormData(SERVER_BASE_URL + GET_GROUP_REQUEST, parameters: paramDict) {
            [unowned self] (response) in
            print(response)
            
            AppUtility.hideProgress()
            
            do {
                reqList.removeAll()
                if let rawPersons = response as? GenDictionary {
                    let jsonData = try JSON(data: rawPersons.to_data)
                    print(jsonData)
                    let data = jsonData["data"]
                    print(data)
                    for da in data{
                        let model = GroupRequestModel.init(fromJson: da.1)
                        if model.request != "Accept" && model.request != "Reject"{
                            self.reqList.append(model)
                        }
                    }
                }
               
                
            } catch{
                print(error.localizedDescription)
            }
            groupReqTV.reloadData()
            
            
            return
        } failure: {
            [unowned self] (error) in
            AppUtility.hideProgress()
            self.showErrorAlert(error: error)
        }
    }
    
    @IBAction func btnBackTapped(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }

}

extension GroupRequestViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reqList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        groupReqTV.register(UINib(nibName: "GroupRequestTableViewCell", bundle: nil), forCellReuseIdentifier: "GroupRequestTableViewCell")
        let cell = groupReqTV.dequeueReusableCell(withIdentifier: "GroupRequestTableViewCell", for: indexPath) as! GroupRequestTableViewCell
        cell.btnAccept.tag = indexPath.row
        cell.btnAccept.addTarget(self, action: #selector(acceptReq(_:)), for: .touchUpInside)
        cell.btnReject.tag = indexPath.row
        cell.btnReject.addTarget(self, action: #selector(rejectReq(_:)), for: .touchUpInside)
        cell.configCell(model: reqList[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
    
    @objc func acceptReq(_ sender: UIButton){
        AppUtility.showProgress()
        
        guard let user = AppUtility.shared.session, let userID = user.ID, let token = user.token else {
            return
        }
        let paramDict = ["token":token,
                         "user_id":userID,
                         "request_id":self.reqList[sender.tag].requestId!,
                         "status":"Accept"]
        
        RequestClient().PostFormData(SERVER_BASE_URL + ACCEPT_OR_REJECT_GROUP_REQ, parameters: paramDict) {
            [unowned self] (response) in
            print(response)
            
            AppUtility.hideProgress()
            
            do {
                if let rawPersons = response as? GenDictionary {
                    let jsonData = try JSON(data: rawPersons.to_data)
                    print(jsonData)
                    let viewController = ChatViewController()
                    viewController.hidesBottomBarWhenPushed = true
                    viewController.strName = self.reqList[sender.tag].groupName
                        viewController.toUserId = self.reqList[sender.tag].requestId
                    viewController.isFromGroup = true
                    self.navigationController?.pushViewController(viewController, animated: true)
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
    
    @objc func rejectReq(_ sender: UIButton){
        AppUtility.showProgress()
        
        guard let user = AppUtility.shared.session, let userID = user.ID, let token = user.token else {
            return
        }
        let paramDict = ["token":token,
                         "user_id":userID,
                         "request_id":self.reqList[sender.tag].requestId!,
                         "status":"Reject"]
        
        RequestClient().PostFormData(SERVER_BASE_URL + ACCEPT_OR_REJECT_GROUP_REQ, parameters: paramDict) {
            [unowned self] (response) in
            print(response)
            
            AppUtility.hideProgress()
            
            do {
                if let rawPersons = response as? GenDictionary {
                    let jsonData = try JSON(data: rawPersons.to_data)
                    print(jsonData)
                    self.showSuccessAlert(msg: "Group Request Reject.")
                    self.getGroupRequest()
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
