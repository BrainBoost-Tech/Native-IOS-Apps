//
//  BlockUserListViewController.swift
//  jaminwithus
//
//  Created by office on 28/03/2022.
//  Copyright © 2022 Hafiz Anser. All rights reserved.
//

import UIKit

class BlockUserListViewController: UIViewController {

    @IBOutlet weak var blockUserListTV: UITableView!{
        didSet{
            blockUserListTV.delegate = self
            blockUserListTV.dataSource = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
//    func getBlockUserList(){
//        AppUtility.showProgress()
//        
//        guard let user = AppUtility.shared.session, let userID = user.ID, let token = user.token else {
//            return
//        }
//        let paramDict = ["token":token,
//                         "user_id":userID]
//        
//        RequestClient().PostFormData(SERVER_BASE_URL + CHAT_GROUP_LIST, parameters: paramDict) {
//            [unowned self] (response) in
//            print(response)
//            
//            AppUtility.hideProgress()
//            
//            do {
//                groupList.removeAll()
//                if let rawPersons = response as? GenDictionary {
//                    let jsonData = try JSON(data: rawPersons.to_data)
//                    print(jsonData)
//                    let data = jsonData["data"]
//                    print(data)
//                    for da in data{
//                        let model = GroupModel.init(fromJson: da.1)
//                        self.groupList.append(model)
//                    }
//                }
//                
//                
//            } catch{
//                print(error.localizedDescription)
//            }
//            groupListTV.reloadData()
//            
//            
//            return
//        } failure: {
//            [unowned self] (error) in
//            AppUtility.hideProgress()
//            self.showErrorAlert(error: error)
//        }
//    }

}

extension BlockUserListViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    
}
