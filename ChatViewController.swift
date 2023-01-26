//
//  ChatViewController.swift
//  jaminwithus
//
//  Created by office on 09/02/2022.
//  Copyright © 2022 Hafiz Anser. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import ISEmojiView

class ChatViewController: UIViewController {
    
    @IBOutlet weak var btnNoti: UISwitch!
    @IBOutlet var lblName: UILabel!
    @IBOutlet var moreGroupView: UIView!
    @IBOutlet var insertMsgView: UIView!{
        didSet{
            insertMsgView.layer.cornerRadius = insertMsgView.frame.height / 2
            insertMsgView.layer.borderWidth = 1.0
            insertMsgView.layer.borderColor = #colorLiteral(red: 0.4655304551, green: 0.5016011596, blue: 0.5308085084, alpha: 1)
        }
    }
    @IBOutlet weak var tblChat: UITableView!{
        didSet{
            tblChat.dataSource = self
            tblChat.delegate   = self
            tblChat.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        }
    }
    @IBOutlet weak var tVChat: RRChatTextView!{
        didSet{
            let tapOutTextField: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showDefaultKeyBoard(_:)))
            tVChat.addGestureRecognizer(tapOutTextField)
            tVChat.textDidChangeHeight = {(height) in
                if height > 39 && height < 150{
                    self.constraintTvH.constant = height
                    UIView.animate(withDuration: 0.2, animations: {
                        self.view.layoutIfNeeded()
                    })
                }
            }
        }
    }
    
    @IBOutlet weak var moreOptionView:UIView!
    @IBOutlet weak var tfName:UITextField!
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
    
    @IBOutlet weak var constratintITB: NSLayoutConstraint!
    @IBOutlet weak var constraintTvH: NSLayoutConstraint!
    
    var isFromGroup = false
    var strName: String!
    var toUserId: String = ""
    var messages = [MessageModel]()
    var picker = UIImagePickerController()
    var messageSeenTimer: Timer?
    var strNoti = "on"
    var isBlock = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mainView.isHidden = true
        self.groupView.isHidden = true
        self.moreOptionView.isHidden = true
        self.moreGroupView.isHidden = true
        
//        if isBlock {
//            let viewController = BlockViewController()
//            viewController.hidesBottomBarWhenPushed = true
//            viewController.toUserId = toUserId
//            self.navigationController?.pushViewController(viewController, animated: true)
//        }else{
            setUI()
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.mainView.isHidden = true
        self.groupView.isHidden = true
        if isFromGroup{
            
        }else{
            if isBlock{
                let viewController = BlockViewController()
                viewController.hidesBottomBarWhenPushed = true
                viewController.toUserId = toUserId
                viewController.delegate = self
                self.navigationController?.pushViewController(viewController, animated: true)
            }else{
                messageSeenTimer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(messageSeen), userInfo: nil, repeats: true)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.messageSeenTimer?.invalidate()
    }
    
    @objc func hideView(_ gesture: UITapGestureRecognizer){
        self.mainView.isHidden = true
        self.groupView.isHidden = true
        self.moreOptionView.isHidden = true
        self.moreGroupView.isHidden = true
    }
    
    
    func setUI(){
        self.mainView.isHidden = true
        self.groupView.isHidden = true
        self.lblName.text = strName
        self.moreOptionView.isHidden = true
        self.moreGroupView.isHidden = true
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        
        let tapeGesture = UITapGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(gesture:)))
        self.tblChat.isUserInteractionEnabled = true
        self.tblChat.addGestureRecognizer(tapeGesture)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard(gesture:)))
        self.view.addGestureRecognizer(tapGesture)
        AppUtility.showProgress()
        self.getMessages()
        if isFromGroup{
            if strNoti == "on"{
                self.btnNoti.isOn = true
            }else{
                self.btnNoti.isOn = false
            }
        }
    }
    
    @objc func messageSeen(){
        
        guard let user = AppUtility.shared.session, let userID = user.ID, let token = user.token else {
            return
        }
        if messages.count > 0{
            if user.ID == messages[messages.count - 1].fromUserId{
                let paramDict = ["token":token,
                                 "to_user_id":userID,
                                 "message_id": messages[messages.count - 1].id!]
                
                RequestClient().PostFormData(SERVER_BASE_URL + READ_MESSAGE, parameters: paramDict) {
                    [unowned self] (response) in
                    print(response)
                    
                    self.getMessages()
                    return
                } failure: {
                     (error) in
    //                self.showErrorAlert(error: error)
                }

            }else{
                self.getMessages()
            }
        }else{
            self.getMessages()
        }
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        tVChat.resignFirstResponder()
    }
    
    @objc func hideKeyboard(gesture: UIGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @objc func showDefaultKeyBoard(_ gesture: UIGestureRecognizer){
        self.tVChat.resignFirstResponder()
        tVChat.inputView = nil
        self.tVChat.becomeFirstResponder()
        
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            constratintITB.constant = keyboardHeight
//            constraintBW.constant   = 0
//            btnSend.setImage(UIImage(named: "sendChat"), for: .normal)
            scrollToBottom()
            UIView.animate(withDuration: 0.1) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        constratintITB.constant = 0
//        constraintBW.constant   = (RRConstant.PlaceHolder.tvChatPlaceHolder == tVChat.text) ? 40 : 0
        //btnSend.setImage(((RRConstant.PlaceHolder.tvChatPlaceHolder == tVChat.text) ? UIImage(named: "siriMic") : UIImage(named: "sendChat") ), for: .normal)
        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
        }
    }
    
    func scrollToBottom(){
        tblChat.layoutIfNeeded()
        if messages.count > 0{
            tblChat.scrollToRow(at: IndexPath(row: messages.count - 1, section: 0), at: .bottom, animated: false)
        }
    }
    
    @IBAction func btnBackTapped(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnEmojiTapped(){
        self.tVChat.resignFirstResponder()
        let keyboardSettings = KeyboardSettings(bottomType: .categories)
        let emojiView = EmojiView(keyboardSettings: keyboardSettings)
        emojiView.translatesAutoresizingMaskIntoConstraints = false
        emojiView.delegate = self
//        emojiView.
        tVChat.inputView = emojiView

        self.tVChat.becomeFirstResponder()
    }
    
    @IBAction func btnSendImageTapped(){
        let alert:UIAlertController=UIAlertController(title: "Choose Image", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertAction.Style.default)
         {
            UIAlertAction in
            self.openCamera()
         }
        let imageAction = UIAlertAction(title: "Photo", style: UIAlertAction.Style.default)
         {
            UIAlertAction in
            self.openGallery()
         }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel)
         {
            UIAlertAction in
         }

        // Add the actions
        picker.delegate = self
         alert.addAction(cameraAction)
         alert.addAction(imageAction)
         alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func openCamera(){
        if(UIImagePickerController .isSourceTypeAvailable(.camera)){
            picker.sourceType = .camera
            self.navigationController?.present(picker, animated: true, completion: nil)
        } else {
            let alertController: UIAlertController = {
                let controller = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default)
                controller.addAction(action)
                return controller
            }()
            self.navigationController?.present(alertController, animated: true)
        }
    }
    func openGallery(){
        picker.sourceType = .photoLibrary
        self.navigationController!.present(picker, animated: true, completion: nil)
    }

    
    @IBAction func btnSendMessageTapped(){
        self.sendMessages()
    }

    func getMessages(){
        
        guard let user = AppUtility.shared.session, let userID = user.ID, let token = user.token else {
            return
        }
        var paramDict : Parameters = [:]
        
        var strRequest = String()
        if isFromGroup{
            paramDict = ["token":token,
                         "group_id":toUserId,
                         "user_id":userID]
            strRequest = SERVER_BASE_URL + GET_GROUP_CHAT
        }else{
            paramDict = ["token":token,
                         "to_user_id":toUserId,
                         "from_user_id":userID]
            strRequest = SERVER_BASE_URL + CHAT_HISTORY
        }
        
        RequestClient().PostFormData(strRequest, parameters: paramDict) {
            [unowned self] (response) in
            print(response)
            
            AppUtility.hideProgress()
            
            do {
                messages.removeAll()
                if let rawPersons = response as? GenDictionary {
                    let jsonData = try JSON(data: rawPersons.to_data)
                    print(jsonData)
                    let data = jsonData["data"]
                    print(data)
                    for da in data{
                        let model = MessageModel.init(fromJson: da.1)
                        self.messages.append(model)
                    }
                }
               
                
            } catch{
                print(error.localizedDescription)
            }
            tblChat.reloadData()
            
            
            return
        } failure: {
             (error) in
            AppUtility.hideProgress()
//            self.showErrorAlert(error: error)
        }
    }
    
    
    func sendMessages(){
        AppUtility.showProgress()
        guard let message = tVChat.text, tVChat.text != "" else {
            return
        }
        guard let user = AppUtility.shared.session, let userID = user.ID, let token = user.token else {
            return
        }
        self.tVChat.text = ""
        var paramDict : Parameters = [:]
        
        var strRequest = String()
        if isFromGroup{
            paramDict = ["token":token,
                         "group_id":toUserId,
                         "from_user_id":userID,
                         "message": message.encode(),
                         "message_type":"message"]
            strRequest = SERVER_BASE_URL + SEND_GROUP_MESSAGE
        }else{
            paramDict = ["token":token,
                         "to_user_id":toUserId,
                         "from_user_id":userID,
                         "message": message.encode(),
                         "message_type":"message"]
            strRequest = SERVER_BASE_URL + SEND_MESSAGE
        }
        
        RequestClient().PostFormData(strRequest, parameters: paramDict) {
            [unowned self] (response) in
            print(response)
            
            AppUtility.hideProgress()
            
            do {
                if let rawPersons = response as? GenDictionary {
                    let jsonData = try JSON(data: rawPersons.to_data)
                    print(jsonData)
                    AppUtility.showProgress()
                    self.getMessages()
                }
               
                
            } catch{
                print(error.localizedDescription)
            }
            
            
            return
        } failure: {
             (error) in
            AppUtility.hideProgress()
            self.showErrorAlert(error: error)
        }
    }

    
    @IBAction func btnMoreTapped(){
        if isFromGroup{
            if moreGroupView.isHidden{
                moreGroupView.isHidden = false
            }else{
                moreGroupView.isHidden = true
            }
        }else{
            if moreOptionView.isHidden{
                moreOptionView.isHidden = false
            }else{
                moreOptionView.isHidden = true
            }
        }
    }
    
    @IBAction func btnRemoveMember(_ sender: UIButton){
        self.mainView.isHidden = true
        self.groupView.isHidden = true
        self.moreOptionView.isHidden = true
        self.moreGroupView.isHidden = true
        let viewController = RemoveMemberViewController()
        viewController.groupId = toUserId
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func btnDeleteChatTapped(){
        self.deleteChat()
    }
    
    @IBAction func btnBlockUserTapped(){
        self.blockUser()
    }
    
    
    func deleteChat(){
        AppUtility.showProgress()
        
        guard let user = AppUtility.shared.session, let userID = user.ID, let token = user.token else {
            return
        }
        let paramDict = ["token":token,
                         "to_user_id":toUserId,
                         "from_user_id":userID]
        
        RequestClient().PostFormData(SERVER_BASE_URL + DELETE_CHAT, parameters: paramDict) {
            [unowned self] (response) in
            print(response)
            
            AppUtility.hideProgress()
            
            do {
                if let rawPersons = response as? GenDictionary {
                    let jsonData = try JSON(data: rawPersons.to_data)
                    print(jsonData)
                    self.messages.removeAll()
                    self.moreOptionView.isHidden = true
                    self.moreGroupView.isHidden = true
                }
               
                
            } catch{
                print(error.localizedDescription)
            }
            tblChat.reloadData()
            
            
            return
        } failure: {
             (error) in
            AppUtility.hideProgress()
//            self.showErrorAlert(error: error)
        }
    }
    
    func blockUser(){
        AppUtility.showProgress()
        
        guard let user = AppUtility.shared.session, let userID = user.ID, let token = user.token else {
            return
        }
        let paramDict = ["token":token,
                         "to_user_id":toUserId,
                         "user_id":userID,
                         "block":"1"]
        
        RequestClient().PostFormData(SERVER_BASE_URL + BLOCK_CHAT, parameters: paramDict) {
            [unowned self] (response) in
            print(response)
            
            AppUtility.hideProgress()
            
            do {
                if let rawPersons = response as? GenDictionary {
                    let jsonData = try JSON(data: rawPersons.to_data)
                    print(jsonData)
                    self.isBlock = true
                    let viewController = BlockViewController()
                    viewController.hidesBottomBarWhenPushed = true
                    viewController.toUserId = toUserId
                    viewController.delegate = self
                    self.navigationController?.pushViewController(viewController, animated: true)
                    self.moreOptionView.isHidden = true
                    self.moreGroupView.isHidden = true
                }
               
                
            } catch{
                print(error.localizedDescription)
            }
            tblChat.reloadData()
            
            
            return
        } failure: {
             (error) in
            AppUtility.hideProgress()
//            self.showErrorAlert(error: error)
        }
    }
    
    @IBAction func btnManageNoti(_ sender: UISwitch){
        if sender.isOn{
            self.strNoti = "on"
        }else{
            self.strNoti = "off"
        }
        AppUtility.showProgress()
        
        guard let user = AppUtility.shared.session, let userID = user.ID, let token = user.token else {
            return
        }
        
        let paramDict = ["token":token,
                         "group_id":toUserId,
                         "user_id":userID,
                         "notification":strNoti]
        
        RequestClient().PostFormData(SERVER_BASE_URL + MANAGE_GROUP_NOTIFICATION, parameters: paramDict) {
            [unowned self] (response) in
            print(response)
            
            AppUtility.hideProgress()
            
            do {
                if let rawPersons = response as? GenDictionary {
                    let jsonData = try JSON(data: rawPersons.to_data)
                    print(jsonData)
                    //sender.isSelected = !sender.isSelected
                }
               
                
            } catch{
                print(error.localizedDescription)
            }
            tblChat.reloadData()
            
            
            return
        } failure: {
             (error) in
            AppUtility.hideProgress()
//            self.showErrorAlert(error: error)
        }
    }
    
    @IBAction func btnEditGroupTapped(){
        self.mainView.isHidden = false
        self.groupView.isHidden = false
        self.moreOptionView.isHidden = true
        self.moreGroupView.isHidden = true
        self.tfName.text = strName
    }
    
    @IBAction func btnCloseTapped(_ sender: UIButton){
        self.moreOptionView.isHidden = true
        self.moreGroupView.isHidden = true
        self.mainView.isHidden = true
        self.groupView.isHidden = true
    }
    
    @IBAction func btnDoneTapped(_ sender: UIButton){
        AppUtility.showProgress()
        
        guard let name = tfName.text, tfName.text != "" else {
            self.showSuccessAlert(msg: "Please Enter Group Name.")
            return
        }
        
        guard let user = AppUtility.shared.session, let userID = user.ID, let token = user.token else {
            return
        }
        let paramDict = ["token":token,
                         "user_id":userID,
                         "group_id":toUserId,
                         "group_name": name]
        
        RequestClient().PostFormData(SERVER_BASE_URL + EDIT_CHAT_GROUP, parameters: paramDict) {
            [unowned self] (response) in
            print(response)
            
            AppUtility.hideProgress()
            
            do {
                if let rawPersons = response as? GenDictionary {
                    let jsonData = try JSON(data: rawPersons.to_data)
                    print(jsonData)
                    self.moreOptionView.isHidden = true
                    self.moreGroupView.isHidden = true
                    self.mainView.isHidden = true
                    self.groupView.isHidden = true
                    self.lblName.text = name
                }
                
                
            } catch{
                print(error.localizedDescription)
            }
            tblChat.reloadData()
            
            
            return
        } failure: {
            (error) in
            AppUtility.hideProgress()
            //            self.showErrorAlert(error: error)
        }
    }
    
    @IBAction func btnDeleteGroupTapped(_ sender: UIButton){
        self.mainView.isHidden = true
        self.groupView.isHidden = true
        self.moreOptionView.isHidden = true
        self.moreGroupView.isHidden = true
        AppUtility.showProgress()
        
        guard let user = AppUtility.shared.session, let userID = user.ID, let token = user.token else {
            return
        }
        let paramDict = ["token":token,
                         "user_id":userID,
                         "group_id":toUserId]
        
        RequestClient().PostFormData(SERVER_BASE_URL + DELETE_CHAT_GROUP, parameters: paramDict) {
            [unowned self] (response) in
            print(response)
            
            AppUtility.hideProgress()
            
            do {
                if let rawPersons = response as? GenDictionary {
                    let jsonData = try JSON(data: rawPersons.to_data)
                    print(jsonData)
                    self.moreOptionView.isHidden = true
                    self.moreGroupView.isHidden = true
                    self.mainView.isHidden = true
                    self.groupView.isHidden = true
                    self.navigationController?.popViewController(animated: true)
//                    let msg = jsonData["msg"].stringValue
//                    self.showSuccessAlert(msg: msg)
                }
                
                
            } catch{
                print(error.localizedDescription)
            }
            tblChat.reloadData()
            
            
            return
        } failure: {
            (error) in
            AppUtility.hideProgress()
            //            self.showErrorAlert(error: error)
        }
    }
    
    @IBAction func btnLeaveGroupTapped(_ sender: UIButton){
        self.mainView.isHidden = true
        self.groupView.isHidden = true
        self.moreOptionView.isHidden = true
        self.moreGroupView.isHidden = true
        AppUtility.showProgress()
        
        guard let user = AppUtility.shared.session, let userID = user.ID, let token = user.token else {
            return
        }
        let paramDict = ["token":token,
                         "user_id":userID,
                         "group_id":toUserId]
        
        RequestClient().PostFormData(SERVER_BASE_URL + LEAVE_CHAT_GROUP, parameters: paramDict) {
            [unowned self] (response) in
            print(response)
            
            AppUtility.hideProgress()
            
            do {
                if let rawPersons = response as? GenDictionary {
                    let jsonData = try JSON(data: rawPersons.to_data)
                    print(jsonData)
                    self.moreOptionView.isHidden = true
                    self.moreGroupView.isHidden = true
                    self.mainView.isHidden = true
                    self.groupView.isHidden = true
//                    self.navigationController?.popViewController(animated: true)
                    let msg = jsonData["msg"].stringValue
                    self.showSuccessAlert(msg: msg)
                }
                
                
            } catch{
                print(error.localizedDescription)
            }
            tblChat.reloadData()
            
            
            return
        } failure: {
            (error) in
            AppUtility.hideProgress()
            //            self.showErrorAlert(error: error)
        }
    }
    
    @IBAction func btnAddMemberTapped(_ sender: UIButton){
        self.mainView.isHidden = true
        self.groupView.isHidden = true
        self.moreOptionView.isHidden = true
        self.moreGroupView.isHidden = true
        let viewController = ChatUserListViewController()
        viewController.isFromGroupChat = true
        viewController.groupID = toUserId
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if messages[indexPath.row].fromUserId == AppUtility.shared.session?.ID{
            if messages[indexPath.row].messageType == "message"{
                tblChat.register(UINib(nibName: "SendMessageTableViewCell", bundle: nil), forCellReuseIdentifier: "SendMessageTableViewCell")
                let cell = tblChat.dequeueReusableCell(withIdentifier: "SendMessageTableViewCell", for: indexPath) as! SendMessageTableViewCell
                cell.configCell(model: messages[indexPath.row])
                cell.selectionStyle = .none
                return cell
            }else{
                tblChat.register(UINib(nibName: "SendImageTableViewCell", bundle: nil), forCellReuseIdentifier: "SendImageTableViewCell")
                let cell = tblChat.dequeueReusableCell(withIdentifier: "SendImageTableViewCell", for: indexPath) as! SendImageTableViewCell
                cell.configCell(model: messages[indexPath.row], isFromChat: isFromGroup)
                cell.selectionStyle = .none
                return cell
            }
        }else {
            if messages[indexPath.row].messageType == "message"{
                tblChat.register(UINib(nibName: "ReceiveMessageTableViewCell", bundle: nil), forCellReuseIdentifier: "ReceiveMessageTableViewCell")
                let cell = tblChat.dequeueReusableCell(withIdentifier: "ReceiveMessageTableViewCell", for: indexPath) as! ReceiveMessageTableViewCell
                cell.configCell(model: messages[indexPath.row])
                cell.selectionStyle = .none
                return cell
            }else{
                tblChat.register(UINib(nibName: "ReceiveImageTableViewCell", bundle: nil), forCellReuseIdentifier: "ReceiveImageTableViewCell")
                let cell = tblChat.dequeueReusableCell(withIdentifier: "ReceiveImageTableViewCell", for: indexPath) as! ReceiveImageTableViewCell
                cell.configCell(model: messages[indexPath.row], isFromChat: isFromGroup)
                cell.selectionStyle = .none
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if messages[indexPath.row].messageType == "message"{
            return 55
        }else{
            return 255
        }
    }
    
    
}

extension ChatViewController: EmojiViewDelegate{
    func emojiViewDidSelectEmoji(_ emoji: String, emojiView: EmojiView) {
        tVChat.insertText(emoji)
    }

    // callback when tap change keyboard button on keyboard
    func emojiViewDidPressChangeKeyboardButton(_ emojiView: EmojiView) {
        tVChat.inputView = nil
        tVChat.keyboardType = .default
        tVChat.reloadInputViews()
    }
        
    // callback when tap delete button on keyboard
    func emojiViewDidPressDeleteBackwardButton(_ emojiView: EmojiView) {
        tVChat.deleteBackward()
    }

    // callback when tap dismiss button on keyboard
    func emojiViewDidPressDismissKeyboardButton(_ emojiView: EmojiView) {
        tVChat.resignFirstResponder()
    }
}

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        let imgData = image.jpegData(compressionQuality: 0.2)!
        sendImageMessage(imgData: imgData)
    }
    
    func sendImageMessage(imgData: Data) {
        guard let user = AppUtility.shared.session, let userID = user.ID, let token = user.token else {
            return
        }
        
        AppUtility.showProgress()
        
        let headers = ["Content-Type": "application/json"]
        var paramDict : Parameters = [:]
        var requestURL = URL(string: "")
        if isFromGroup{
            paramDict = ["token":token,
                         "group_id":toUserId,
                         "from_user_id":userID,
                         "message_type":"image"]
             requestURL = URL(string: SERVER_BASE_URL + SEND_GROUP_MESSAGE)!
        }else{
            
            paramDict = ["token":token,
                         "to_user_id":toUserId,
                         "from_user_id":userID,
                         "message_type":"image"]
            requestURL = URL(string: SERVER_BASE_URL + SEND_MESSAGE)!
        }


//        print(paramDict)

        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(imgData, withName: "file",fileName: "photo.png", mimeType: "image/jpeg")

            for (key, value) in paramDict
            {
                multipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
            }
        },  usingThreshold:UInt64.init(),
            to: requestURL! ,
            method:.post,
            headers:headers,
            encodingCompletion: { encodingResult in

                switch encodingResult {
                case .success(let upload, _, _):

                    upload.responseJSON { response in

                        AppUtility.hideProgress()
                        print("response JSON: '\(response)'")

                        if((response.result.value) != nil)
                        {
                            AppUtility.showProgress()
                            self.getMessages()
                        }
                        else
                        {
                            AppUtility.hideProgress()
                            let result = response.result
                            print("response JSON: '\(result)'")
                            //let userInfo = response.error as? Error
                            let error = response.error

                            let alert = UIAlertController(title: "Error!", message:error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                case .failure(let encodingError):
                    AppUtility.hideProgress()
                    print(encodingError)
                    let alert = UIAlertController(title: "Error!", message:encodingError.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
        })
    }
}

extension ChatViewController: isUnBlock{
    func unblock(isBlock: Bool) {
        self.isBlock = isBlock
    }
}
