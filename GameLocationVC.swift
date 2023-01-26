//
//  GameLocationVC.swift
//  QuestManager
//
//  Created by office on 02/05/2022.
//

import UIKit
import SwiftyJSON
import Toast_Swift
import MBProgressHUD

class GameLocationVC: UIViewController {

    @IBOutlet weak var btnClose: UIButton!{
        didSet{
            btnClose.layer.cornerRadius = btnClose.frame.height / 2
        }
    }
    
    @IBOutlet weak var bgImg: UIImageView!{
        didSet{
            bgImg.layer.cornerRadius = 15.0
        }
    }
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblMsg: UILabel!
    @IBOutlet weak var locationCV: UICollectionView!{
        didSet{
            locationCV.delegate = self
            locationCV.dataSource = self
        }
    }
    @IBOutlet weak var parentView: UIView!
    @IBOutlet weak var msgView: UIView!{
        didSet{
            msgView.layer.cornerRadius = 15.0
        }
    }
    
    var locImgArr = [#imageLiteral(resourceName: "t1"),#imageLiteral(resourceName: "t2"),#imageLiteral(resourceName: "t3"),#imageLiteral(resourceName: "t4"),#imageLiteral(resourceName: "t5"),#imageLiteral(resourceName: "t6")]
    var strName : String!
    var strUserName : String!
    var selectedIndex: Int!
    var gameLocList = [GameLocationModel]()
    var gameList = [HintInfoModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.hideKeyboardWhenTappedAround()
        self.parentView.isHidden = true
        self.msgView.isHidden = true
        self.lblName.text = strName
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.gameLocList.removeAll()
        self.locationCV.reloadData()
        self.selectedIndex = -1
        getHintInfo()
    }
    
    func getGameLocation(){
        MBProgressHUD.showAdded(to: self.view, animated: true)
        NetworkManager.sharedInstance.getGameLocation() { (response) in
            MBProgressHUD.hide(for: self.view, animated: true)
            guard response.result.isSuccess else {
                print(response.result.error ?? "Error")
                return
            }
            if response.result.error == nil {
                do {
                    let jsonData = try JSON(data: response.data!)
                    print(jsonData)
                    self.gameLocList.removeAll()
                    let statusCode = jsonData["statusCode"].intValue
                    if statusCode == 200 {
                        let gameLocData = jsonData["data"]
                        for gameLoc in gameLocData{
                            let model = GameLocationModel.init(fromJson: gameLoc.1)
                            for game in self.gameList{
                                let towns = game.towns!
                                for town in towns{
                                    if town.id == model.id && game.published == true && game.gameTypeId.name == self.strName{
                                        self.gameLocList.append(model)
                                    }
                                }
                                
                            }
                        }
                        
                        if self.gameLocList.count == 0{
                            self.lblMsg.text = "There is no game is published against " + self.strName
                            self.parentView.isHidden = false
                            self.msgView.isHidden = false
                        }else{
                            self.parentView.isHidden = true
                            self.msgView.isHidden = true
                        }
                        
                        self.locationCV.reloadData()
                    }else{
                        let msg = jsonData["message"].stringValue
                        print(msg)
                        self.view.makeToast(msg)
                    }
                } catch{
                    print(error.localizedDescription)
                    self.view.makeToast(error.localizedDescription)
                }
            }else {
                print(Error.self)
                self.view.makeToast("\(response.result.error?.localizedDescription ?? "Error")")
            }
        }
    }
    
    func getHintInfo(){
        MBProgressHUD.showAdded(to: self.view, animated: true)
        NetworkManager.sharedInstance.getHintInfo() { (response) in
            MBProgressHUD.hide(for: self.view, animated: true)
            guard response.result.isSuccess else {
                print(response.result.error ?? "Error")
                return
            }
            if response.result.error == nil {
                do {
                    self.gameList.removeAll()
                    let jsonData = try JSON(data: response.data!)
                    print(jsonData)
                    let statusCode = jsonData["statusCode"].intValue
                    if statusCode == 200 {
                        let hintInfoData = jsonData["data"]
                        for hintInfo in hintInfoData{
                            let model = HintInfoModel.init(fromJson: hintInfo.1)
                            self.gameList.append(model)
                        }
                        
                        self.getGameLocation()
                        
                    }else{
                        let msg = jsonData["message"].stringValue
                        print(msg)
                        self.view.makeToast(msg)
                    }
                } catch{
                    print(error.localizedDescription)
                    self.view.makeToast(error.localizedDescription)
                }
            }else {
                print(Error.self)
                self.view.makeToast("\(response.result.error?.localizedDescription ?? "Error")")
            }
        }
    }

    @IBAction func btnBackTapped(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension GameLocationVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gameLocList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        locationCV.register(UINib(nibName: Constants.CollectionViewCells.GameLocationCVCell, bundle: nil), forCellWithReuseIdentifier: Constants.CollectionViewCells.GameLocationCVCell)
        let cell = locationCV.dequeueReusableCell(withReuseIdentifier: Constants.CollectionViewCells.GameLocationCVCell, for: indexPath) as! GameLocationCVCell
        if self.selectedIndex == indexPath.row{
            gameLocList[indexPath.row].isSelect = true
        }else{
            gameLocList[indexPath.row].isSelect = false
        }
        cell.configCell(model: gameLocList[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = locationCV.frame.width / 2 - 8
        var height: CGFloat = 0
        if UIDevice.current.type == .iPhone_6_6S_7_8 || UIDevice.current.type == .iPhone_6_6S_7_8_PLUS {
            height = locationCV.frame.height / 2 - 4
        }else{
            height = locationCV.frame.height / 2.3 - 4
        }
        return CGSize(width: width, height: height)
    }
 
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedIndex = indexPath.row
        self.locationCV.reloadData()
        let vc = self.storyboard?.instantiateViewController(withIdentifier: Constants.ViewControllers.HintInfoVC) as! HintInfoVC
        vc.strId = self.gameLocList[indexPath.row].id
        vc.strName = self.gameLocList[indexPath.row].name
        vc.gameType = strName
        vc.strUserName = strUserName
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
