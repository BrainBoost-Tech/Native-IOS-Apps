//
//  GameTypeVC.swift
//  QuestManager
//
//  Created by office on 01/05/2022.
//

import UIKit
import SwiftyJSON
import Toast_Swift
import MBProgressHUD

class GameTypeVC: UIViewController {

    @IBOutlet weak var bgImg: UIImageView!{
        didSet{
            bgImg.layer.cornerRadius = 15.0
        }
    }
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblMsg: UILabel!
    @IBOutlet weak var gameTypeTV: UITableView!{
        didSet{
            gameTypeTV.delegate = self
            gameTypeTV.dataSource = self
        }
    }
    
    var strName : String!
    var selectedIndex = Int()
    var gameTypeList = [GameTypeModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        setUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.gameTypeList.removeAll()
        self.gameTypeTV.reloadData()
        self.selectedIndex = -1
        getGameType()
    }
    
    func setUI(){
        let myAttribute = [ NSAttributedString.Key.font: UIFont(name: "Futura-Bold", size: 20.0)! ]
        let myString = NSMutableAttributedString(string: strName, attributes: myAttribute)
        let myMedAttribute = [ NSAttributedString.Key.font: UIFont(name: "FuturaBT-Light", size: 20.0)! ]
        let welcome = NSMutableAttributedString(string: "Welcome, ", attributes: myMedAttribute)
        
        let mutableAttributedString = NSMutableAttributedString()
        mutableAttributedString.append(welcome)
        mutableAttributedString.append(myString)
        self.lblName.attributedText = mutableAttributedString
        
        let msgAttribute = [ NSAttributedString.Key.font: UIFont(name: "Futura-Bold", size: 20.0)! ]
        let msgString = NSMutableAttributedString(string: "game type:", attributes: msgAttribute)
        let msgMedAttribute = [ NSAttributedString.Key.font: UIFont(name: "FuturaBT-Light", size: 20.0)! ]
        let str = NSMutableAttributedString(string: "Please Select a ", attributes: msgMedAttribute)
        
        let msgMutableAttributedString = NSMutableAttributedString()
        msgMutableAttributedString.append(str)
        msgMutableAttributedString.append(msgString)
        self.lblMsg.attributedText = msgMutableAttributedString
    }
    
    func getGameType(){
        MBProgressHUD.showAdded(to: self.view, animated: true)
        NetworkManager.sharedInstance.getGameType() { (response) in
            MBProgressHUD.hide(for: self.view, animated: true)
            guard response.result.isSuccess else {
                print(response.result.error ?? "Error")
                return
            }
            if response.result.error == nil {
                do {
                    let jsonData = try JSON(data: response.data!)
                    print(jsonData)
                    self.gameTypeList.removeAll()
                    let statusCode = jsonData["statusCode"].intValue
                    if statusCode == 200 {
                        let gameTypeData = jsonData["data"]
                        for gameType in gameTypeData{
                            let model = GameTypeModel.init(fromJson: gameType.1)
                            self.gameTypeList.append(model)
                        }
                        self.gameTypeTV.reloadData()
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

extension GameTypeVC: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gameTypeList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        gameTypeTV.register(UINib(nibName: Constants.TableViewCells.GameTypeTVCell, bundle: nil), forCellReuseIdentifier: Constants.TableViewCells.GameTypeTVCell)
        let cell = gameTypeTV.dequeueReusableCell(withIdentifier: Constants.TableViewCells.GameTypeTVCell, for: indexPath) as! GameTypeTVCell
        if self.selectedIndex == indexPath.row{
            gameTypeList[indexPath.row].isSelect = true
        }else{
            gameTypeList[indexPath.row].isSelect = false
        }
        cell.configCell(model: gameTypeList[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedIndex = indexPath.row
        self.gameTypeTV.reloadData()
        let vc = self.storyboard?.instantiateViewController(withIdentifier: Constants.ViewControllers.GameLocationVC) as! GameLocationVC
        vc.strName = gameTypeList[indexPath.row].name
        vc.strUserName = strName
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
}
