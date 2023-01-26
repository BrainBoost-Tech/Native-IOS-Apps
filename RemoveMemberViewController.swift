//
//  RemoveMemberViewController.swift
//  jaminwithus
//
//  Created by office on 29/05/2022.
//  Copyright © 2022 Hafiz Anser. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class RemoveMemberViewController: UIViewController {

    @IBOutlet weak var memberTV: UITableView!{
        didSet{
            memberTV.delegate = self
            memberTV.dataSource = self
        }
    }
    
    var groupId: String!
    var groupMember = [ModelGroupMember]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getMembers()
    }
    
    func getMembers(){
        
        guard let user = AppUtility.shared.session, let userID = user.ID, let token = user.token else {
            return
        }
        
        var strRequest = String()
        let paramDict : Parameters = ["token":token,
                                      "group_id":groupId as Any]
        strRequest = SERVER_BASE_URL + GET_GROUP_INFO
        
        RequestClient().PostFormData(strRequest, parameters: paramDict) {
            [unowned self] (response) in
            print(response)
            
            AppUtility.hideProgress()
            
            do {
                groupMember.removeAll()
                if let rawPersons = response as? GenDictionary {
                    let jsonData = try JSON(data: rawPersons.to_data)
                    print(jsonData)
                    let data = jsonData["data"]
                    let groupMemberData = data["group_members"]
                    print(data)
                    for data in groupMemberData{
                        let model = ModelGroupMember.init(fromJson: data.1)
                        if model.id != userID{
                            self.groupMember.append(model)
                        }
                    }
                }
                self.memberTV.reloadData()
                
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
    
    
    @IBAction func btnBackTapped(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }

}

extension RemoveMemberViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupMember.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        memberTV.register(UINib(nibName: "GroupMemberTVCell", bundle: nil), forCellReuseIdentifier: "GroupMemberTVCell")
        let cell = memberTV.dequeueReusableCell(withIdentifier: "GroupMemberTVCell", for: indexPath) as! GroupMemberTVCell
        cell.btnRemove.tag = indexPath.row
        cell.btnRemove.addTarget(self, action: #selector(btnRemoveTapped(_:)), for: .touchUpInside)
        cell.configCell(model: groupMember[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
 
    
    @objc func btnRemoveTapped(_ sender: UIButton){
        AppUtility.showProgress()
        guard let user = AppUtility.shared.session, let userID = user.ID, let token = user.token else {
            return
        }
        let memberId = groupMember[sender.tag].id
        var strRequest = String()
        let paramDict : Parameters = ["token":token,
                                      "user_id":userID,
                                      "member_id":memberId as Any]
        strRequest = SERVER_BASE_URL + DELETE_GROUP_MEMBER
        
        RequestClient().PostFormData(strRequest, parameters: paramDict) {
            [unowned self] (response) in
            print(response)
            
            AppUtility.hideProgress()
            
            do {
                groupMember.removeAll()
                if let rawPersons = response as? GenDictionary {
                    let jsonData = try JSON(data: rawPersons.to_data)
                    print(jsonData)
                    let status = jsonData["status"].boolValue
                    if status{
//                        self.getMembers()
                        for controller in self.navigationController!.viewControllers as Array {
                                if controller.isKind(of: GroupListViewController.self) {
                                      self.navigationController!.popToViewController(controller, animated: true)
                                       break
                                   }
                                }
                    }else{
                        let msg = jsonData["error"].stringValue
                        self.showErrorMessageAlert(msg: msg)
                    }
                }
                
            } catch{
                print(error.localizedDescription)
            }
            memberTV.reloadData()
            
            
            return
        } failure: {
             (error) in
            AppUtility.hideProgress()
//            self.showErrorAlert(error: error)
        }
    }
    
}
