//
//  BlockViewController.swift
//  jaminwithus
//
//  Created by office on 17/02/2022.
//  Copyright © 2022 Hafiz Anser. All rights reserved.
//

import UIKit
import SwiftyJSON

class BlockViewController: UIViewController {
    
    var toUserId: String = ""
    var delegate: isUnBlock?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func btnBackTapped(_ sender: UIButton){
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: ChatListViewController.self) {
                self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
    }
    
    @IBAction func btnTapToUnblockTapped(_ sender: UIButton){
        unBlockUser()
    }
    
    func unBlockUser(){
        AppUtility.showProgress()
        
        guard let user = AppUtility.shared.session, let userID = user.ID, let token = user.token else {
            return
        }
        let paramDict = ["token":token,
                         "to_user_id":toUserId,
                         "user_id":userID,
                         "block":"0"]
        
        RequestClient().PostFormData(SERVER_BASE_URL + BLOCK_CHAT, parameters: paramDict) {
            [unowned self] (response) in
            print(response)
            
            AppUtility.hideProgress()
            
            do {
                if let rawPersons = response as? GenDictionary {
                    let jsonData = try JSON(data: rawPersons.to_data)
                    print(jsonData)
                    self.delegate?.unblock(isBlock: false)
                    self.navigationController?.popViewController(animated: true)
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
