//
//  FriendViewController.swift
//  CameraApp
//
//  Created by Hang Yang on 3/1/19.
//  Copyright 2019 hang yang. All rights reserved.
//

import UIKit
import Parse

protocol friendDelegate {
    func reddot(bol: String)
}

class FriendViewController: UIViewController, tableDelegate {

    @IBOutlet weak var tableView: UITableView!
    var friendList: [PFObject] = []
    var friendReqList: [PFObject] = []
    var arrayUserObj: [PFObject] = []
    var store = [String: AnyObject]()
    var newdict = [String: String]()
    var afterchuti = false
    var cond = false
    var friendListUpdate: Bool!
    var friendDelegate: friendDelegate!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        friendListUpdate = false
        friendList = []
        friendReqList = []
        arrayUserObj = []
        tableView.delegate = self
        tableView.dataSource = self
        
        let qe = PFQuery(className: "JoinTable")
        qe.whereKey("to", equalTo: PFUser.current()!)
        qe.whereKey("request", equalTo: "sendrequest")
        let group1 = DispatchGroup()
        
        group1.enter()
        
        qe.findObjectsInBackground{ (objs:[PFObject]?, err:Error?) in
            
            print(err?.localizedDescription as Any)
            
            if let objs = objs {
                
                for o in objs {
                    
                    print("aatttt")
                    
                    let sender = o["from"] as! PFUser
                    print(sender.objectId)
                    let current = PFUser.current()
                    let friendReqList = current!["friendReqList"] as! [PFObject]
                    
                    self.friendReqList = friendReqList
                    
                    if self.friendReqList.count > 0 {
                        print("1.\(self.friendReqList.count)")
                        var flag = 0
                        for i in 0 ..< self.friendReqList.count {
                            print("2.\(self.friendReqList.count)")
                            print(self.friendReqList[i].objectId)
                            if self.friendReqList[i].objectId == sender.objectId {
                                
                                flag = 1
                                break
                                
                            }
                        }
                        
                        if flag == 0 {
                            
                            print("equal")
                            self.friendReqList.append(sender)
                            current!.setObject(self.friendReqList, forKey: "friendReqList")
                            current?.saveEventually()
                            
                        }
                        
                    } else {
                        
                        print("69696969")
                        self.friendReqList.append(sender)
                        current!.setObject(self.friendReqList, forKey: "friendReqList")
                        current?.saveEventually()
                        
                    }
                    
                }
                
            }
            
            group1.leave()
            
        }
        
        group1.notify(queue: .main) {
            
            let group2 = DispatchGroup()
            let current = PFUser.current()
            var friendList = current!["friendList"] as! [PFObject]
            self.arrayUserObj = friendList
            let tableQuery = PFQuery(className: "JoinTable")
            let userQuery = PFUser.query()
            tableQuery.whereKey("to", equalTo: current)
            tableQuery.whereKey("request", equalTo: "approverequest")
            
            group2.enter()
            
            tableQuery.findObjectsInBackground { (objs, error) in
                
                print("xinxin")
                
                if let objs = objs {
                    
                    for o in objs {
                        print("xinkkk")
                        group2.enter()
                        print("ojbk")
                        let user = o["from"] as! PFUser
                        var flag = 0
                        
                        for i in 0 ..< friendList.count {
                            
                            if friendList[i].objectId == user.objectId {
                                
                                flag = 1
                                group2.leave()
                                break
                                
                            }
                            
                        }
                        
                        if flag == 0 {
                            
                            let gp2 = DispatchGroup()
                            
                            self.arrayUserObj.append(user)
                            print("\(self.arrayUserObj.count)nnnn")
                            current!.setObject(self.arrayUserObj, forKey: "friendList")
                            
                            //group2.enter()
                            
                            current!.saveInBackground{(success, error) in
                                
                                if success {
                                    
                                    self.friendListUpdate = true
                                    print("friendlist saved")
                                    
                                }
                                
                                group2.leave()
                                
                            }
                        
                        }
                    
                    }
                    
                }
                
                group2.leave()
                
            }
            
            group2.notify(queue: .main) {
                
                let group3 = DispatchGroup()
                let current2 = PFUser.current()
                var friendList2 = current2!["friendList"] as! [PFObject]
                self.arrayUserObj = friendList2
                let tableQuery2 = PFQuery(className: "JoinTable")
                let userQuery2 = PFUser.query()
                tableQuery2.whereKey("from", equalTo: current2)
                tableQuery2.whereKey("request", equalTo: "approverequest")
                
                group3.enter()
                
                tableQuery2.findObjectsInBackground { (objs, error) in
                    
                    print("xinxin2")
                    
                    if let objs = objs {
                        
                        for o in objs {
                            
                            group3.enter()
                            print("ojbk2")
                            
                            let user = o["to"] as! PFUser
                            var flag = 0
                            
                            for i in 0 ..< self.friendReqList.count {
                                
                                if (self.friendReqList[i] as! PFObject).objectId == user.objectId {
                                    
                                    self.friendReqList.remove(at: i)
                                    
                                }
                                
                            }
                            
                            for i in 0 ..< friendList2.count {
                                
                                if friendList2[i].objectId == user.objectId {
                                    
                                    flag = 1
                                    group3.leave()
                                    break
                                    
                                }
                                
                            }
                            
                            if flag == 0 {
                                
                                self.arrayUserObj.append(user)
                                
                                current2!.setObject(self.arrayUserObj, forKey: "friendList")
                                
                                current2!.saveInBackground{(success, error) in
                                    
                                    if success {
                                        
                                        self.friendListUpdate = true
                                        print(self.friendListUpdate)
                                        print("friendlist2 saved")
                                        
                                    }
                                    
                                    group3.leave()
                                    
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                    group3.leave()
                    
                }
                
                group3.notify(queue: .main) {
                    
                    print("enter 3")
                    print(self.friendListUpdate)
                    
                    if self.friendListUpdate == true {
                        
                        let current = PFUser.current()
                        var friendList = current!["friendList"] as! [PFObject]
                        
                        friendList = current!["friendList"] as! [PFObject]
                        
                        for i in 0 ..< friendList.count {
                            
                            let user = friendList[i] as! PFUser
                            var flag = false
                            let group = DispatchGroup()
                            let groupACL = PFACL()
                            let query = PFQuery(className: "Rapport")
                            query.whereKey("from", equalTo: current)
                            group.enter()
                            query.findObjectsInBackground(block: { (objs, err) in
                                
                                if let objs = objs {
                                    
                                    for obj in objs {
                                        
                                        if (obj["to"] as! PFUser).objectId == user.objectId {
                                            
                                            flag = true
                                            break
                                            
                                        }
                                        
                                    }
                                    
                                    group.leave()
                                
                                }
                                
                            })
                            
                            group.notify(queue: .main) {
                                
                                if flag == false {
                                    
                                    groupACL.setReadAccess(true, for: user)
                                    groupACL.setWriteAccess(true, for: user)
                                    groupACL.setReadAccess(true, for: current!)
                                    groupACL.setWriteAccess(true, for: current!)
                                    
                                    let rapport = PFObject(className: "Rapport")
                                    rapport.setObject([user.objectId : 0], forKey: "numOfQuestionToHim")
                                    rapport.setObject([user.objectId : 0], forKey: "numHisCorrect")
                                    rapport.acl = groupACL
                                    
                                    rapport.setObject(user as Any, forKey: "to")
                                    rapport.setObject(current as Any, forKey: "from")
                                    
                                    rapport.saveInBackground{(success, error) in
                                        
                                        if success {
                                            
                                            print("numOfQuestionToHim2 saved")
                                            
                                        }
                                        
                                    }
                                    
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                    let current = PFUser.current()
                    
                    if self.friendReqList.count == 0 {
                        
                        self.title = "好友列表"
                        print("bb1")
                        
                        self.friendList = current!["friendList"] as! [PFObject]
                        
                        if self.friendDelegate != nil {
                            
                            self.friendDelegate.reddot(bol: "false")
                            
                        }
                        
                    } else {
                        
                        self.title = "请求列表"
                        print("bb2")
                        
                        self.friendList = self.friendReqList
                        
                        if self.friendDelegate != nil {
                            
                            self.friendDelegate.reddot(bol: "true")
                            
                        }
                        
                    }
                    
                    if self.friendList.count == 0 {
                        
                        self.title = "好友列表"
                        
                        let alert = UIAlertController(title: "请添加好友", message: "", preferredStyle: .alert)
                        self.present(alert, animated: true)
                        let when = DispatchTime.now() + 1
                        DispatchQueue.main.asyncAfter(deadline: when) {
                            
                            alert.dismiss(animated: true)
                            self.performSegue(withIdentifier: "finishSendTi", sender: self)
                            
                        }
                        
                    }
                    
                    self.tableView.reloadData()
                    
                }
            
            }
        
        }
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if !cond {
            
            self.navigationItem.hidesBackButton = !cond
        
        } else {
        
            self.navigationItem.hidesBackButton = !cond
        
        }
    
    }
    
    // 显示错误提示弹窗
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "错误", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    // 显示成功提示弹窗
    private func showSuccessAlert(message: String) {
        let alert = UIAlertController(title: "成功", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
}

extension FriendViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
       
        if self.friendList != self.friendReqList {
            
            if (editingStyle == .delete) {
                
                if !afterchuti {
                    
                    // handle delete (by removing the data from your array and updating the tableview)
                    let currentCell = self.tableView.cellForRow(at: indexPath) as! FriendCell
                    let name = currentCell.friendName.text
                    let query1 = PFUser.query()!
                    query1.whereKey("username", equalTo: name)
                    let userObj = try! query1.getFirstObject()
                    let objId = userObj.objectId
                    let currentUser = PFUser.current()!
                    let group = DispatchGroup()
                    var list = currentUser["friendList"] as! [PFUser]
                    
                    print(list.count)
                    
                    group.enter()
                    
                    do {
                        
                        let query1 = PFQuery(className: "JoinTable")
                        query1.whereKey("from", equalTo: PFUser.current())
                        query1.whereKey("to", equalTo: userObj)
                        query1.whereKey("request", equalTo: "approverequest")
                        query1.findObjectsInBackground(block: {(objects, error) in
                            
                           if (objects?.first) != nil {
                                
                                (objects?.first as! PFObject).deleteEventually()
                            
                            }
                            
                        })
                        
                        let query2 = PFQuery(className: "JoinTable")
                        query2.whereKey("to", equalTo: PFUser.current())
                        query2.whereKey("from", equalTo: userObj)
                        query2.whereKey("request", equalTo: "approverequest")
                        query2.findObjectsInBackground(block: {(objects, error) in
                            
                            if (objects?.first) != nil {
                                
                                (objects?.first as! PFObject).deleteEventually()
                                
                            }
                            
                        })
                        
                        for i in 0 ..< list.count {
                            
                            if objId == (list[i].objectId) {
                                list.remove(at: i)
                                friendList = list
                                break
                            }
                            
                        }
                        
                        currentUser.setObject(list, forKey: "friendList")
                        currentUser.saveInBackground()
                        
                        let pfq = PFQuery(className: "Rapport")
                        pfq.whereKey("from", equalTo: PFUser.current()!)
                        pfq.whereKey("to", equalTo: userObj)
                        let rapport = try! pfq.getFirstObject()
                        try! rapport.delete()
                        
                        print("done")
                        group.leave()
                        
                    }
                    
                    group.notify(queue: .main) {
                        
                        print("roger")
                        self.tableView.reloadData()
                        
                    }
                    
                } else {
                    
                    let alert = UIAlertController(title: "此时不能删除好友", message: "", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "知道了", style: .default, handler: nil))
                    
                    self.present(alert, animated: true)
                    
                }
                
            }
        
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell") as! FriendCell
        cell.delegate = self
        
        // 设置默认状态，避免显示空白
        cell.friendName.text = "加载中..."
        // 设置默认图像
        if let defaultImage = UIImage(named: "placeholder") {
            cell.friendIcon.image = defaultImage
        } else {
            // 使用自定义默认图像，而不是系统图像
            cell.friendIcon.image = UIImage(named: "default_avatar") ?? UIImage()
        }
        
        // 确保索引有效
        guard indexPath.row < friendList.count else {
            print("Index out of bounds: \(indexPath.row), friendList count: \(friendList.count)")
            return cell
        }
        
        let friend = friendList[indexPath.row]
        guard let userId = friend.objectId else {
            print("User ID is nil for friend at index \(indexPath.row)")
            return cell
        }
        
        print("Loading user with ID: \(userId)")
        
        // 获取当前用户对象
        let directUser = friendList[indexPath.row]
        let objectId = directUser.objectId ?? "Unknown"
        
        // 设置默认显示信息
        cell.friendName.text = "用户(已删除)"
        
        // 1. 尝试从本地对象直接读取数据
        if directUser.allKeys.count > 0 {
            print("\(objectId): 本地对象有\(directUser.allKeys.count)个属性")
            
            // 检查是否有用户名
            if let username = directUser["username"] as? String {
                cell.friendName.text = username
                print("\(objectId): 直接读取到用户名 - \(username)")
            }
            
            // 试图读取头像
            if let avatarFile = directUser["avatar"] as? PFFileObject {
                avatarFile.getDataInBackground { (imageData, error) in
                    if let error = error {
                        print("\(objectId): 读取头像失败 - \(error.localizedDescription)")
                        return
                    }
                    
                    if let data = imageData, let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            // 确保cell仍然可见
                            if let cells = tableView.visibleCells as? [FriendCell],
                               let visibleCell = cells.first(where: { $0.tag == indexPath.row }) {
                                visibleCell.friendIcon.image = image
                                print("\(objectId): 设置头像成功")
                            }
                        }
                    }
                }
            }
        } else {
            print("\(objectId): 本地对象没有可用属性")
        }
        
        // 2. 设置cell的tag便于后续识别
        cell.tag = indexPath.row
        
        // 3. 使用Cloud Function来绕过ACL限制查询用户
        let params = ["userId": objectId]
        
        print("\(objectId): 使用Cloud Function获取用户")
        PFCloud.callFunction(inBackground: "fetchUserWithMasterKey", withParameters: params) { (result, error) in
            if let error = error {
                print("\(objectId): Cloud Function调用失败 - \(error.localizedDescription)")
                
                DispatchQueue.main.async {
                    if let cells = tableView.visibleCells as? [FriendCell],
                       let visibleCell = cells.first(where: { $0.tag == indexPath.row }) {
                        visibleCell.friendName.text = "无法获取用户 (ID: \(objectId.prefix(6))...)"
                    }
                }
                return
            }
            
            // 解析返回结果
            guard let resultDict = result as? [String: Any],
                  let success = resultDict["success"] as? Bool else {
                print("\(objectId): 无法解析返回数据")
                return
            }
            
            if success, let userData = resultDict["user"] as? [String: Any] {
                // 成功获取用户数据
                let username = userData["username"] as? String ?? "未知用户"
                let avatarUrl = userData["avatar"] as? String
                
                print("\(objectId): 使用Cloud Function成功获取用户 - \(username)")
                
                DispatchQueue.main.async {
                    // 查找标记为当前索引的可见cell
                    if let cells = tableView.visibleCells as? [FriendCell],
                       let visibleCell = cells.first(where: { $0.tag == indexPath.row }) {
                        
                        // 设置用户名
                        visibleCell.friendName.text = username
                        
                        // 获取头像如果有URL
                        if let avatarUrlString = avatarUrl, let url = URL(string: avatarUrlString) {
                            URLSession.shared.dataTask(with: url) { (data, response, urlError) in
                                if let urlError = urlError {
                                    print("\(objectId): 下载头像失败 - \(urlError.localizedDescription)")
                                    return
                                }
                                
                                if let data = data, let image = UIImage(data: data) {
                                    DispatchQueue.main.async {
                                        // 再次检查cell可见性
                                        if let cells = tableView.visibleCells as? [FriendCell],
                                           let stillVisibleCell = cells.first(where: { $0.tag == indexPath.row }) {
                                            stillVisibleCell.friendIcon.image = image
                                            print("\(objectId): 设置来自服务器的头像成功")
                                        }
                                    }
                                }
                            }.resume()
                        }
                    }
                }
            } else {
                // 服务器上没有找到用户或没有权限
                let message = resultDict["message"] as? String ?? "未知错误"
                print("\(objectId): Cloud Function返回错误 - \(message)")
                
                DispatchQueue.main.async {
                    // 查找标记为当前索引的可见cell
                    if let cells = tableView.visibleCells as? [FriendCell],
                       let visibleCell = cells.first(where: { $0.tag == indexPath.row }) {
                        visibleCell.friendName.text = "已删除的用户 (ID: \(objectId.prefix(6))...)"
                    }
                }
            }
        }
        // 返回配置好的cell
        return cell
    }
    
    
    // 压缩图片后再上传（示例）
    func compressImage(_ image: UIImage, maxSizeKB: Int) -> Data? {
        var compression: CGFloat = 1.0
        let maxSizeBytes = maxSizeKB * 1024
        
        guard var imageData = image.jpegData(compressionQuality: compression) else {
            return nil
        }
        
        while imageData.count > maxSizeBytes, compression > 0.1 {
            compression -= 0.1
            imageData = image.jpegData(compressionQuality: compression) ?? imageData
        }
        
        return imageData
    }
    
    func myTableDelegate(id: String, icon: UIImage) {
        
        if afterchuti {
            
            let alert = UIAlertController(title: "是否把题目发送给该好友?", message: "", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { action in
                
                var f1 = true
                var f2 = true
                let query1 = PFQuery(className: "JoinTable")
                
                let gp = DispatchGroup()
                
//                let uquery = PFUser.query()
//                uquery?.whereKey("username", equalTo: id)
//                let target = try! uquery?.getFirstObject()
                
                var foundUser: PFUser? = nil
                
                do {
                    print("Calling searchUsers Cloud Function with username: \(id)")
                    
                    do {
                        let result = try PFCloud.callFunction("searchUsers", withParameters: ["username": id]) as? [PFObject]
                        guard let users = result, let user = users.first as? PFUser else {
                            print("No user found with username: \(id)")
                            return
                        }
                        print("Found user: \(user.username ?? "N/A")")
                        foundUser = user
                    } catch {
                        print("Cloud function error: \(error.localizedDescription)")
                        self.showErrorAlert(message: "Failed to search users")
                    }
                    
                } catch {
                    print("Error in Cloud Function call: \(error.localizedDescription)")
                    self.showErrorAlert(message: "处理请求时出错，请稍后再试")
                    return
                }
                
                query1.whereKey("from", equalTo: PFUser.current())
                query1.whereKey("to", equalTo: foundUser)
                query1.whereKey("request", equalTo: "approverequest")
                gp.enter()
                query1.findObjectsInBackground( block:{(objs,err) in
                
                    if objs?.count == 0 {
                    
                        f1 = false
                    
                    }
                    
                    gp.leave()
                
                })
                
                let query2 = PFQuery(className: "JoinTable")
                query2.whereKey("to", equalTo: PFUser.current())
                query2.whereKey("from", equalTo: foundUser)
                query2.whereKey("request", equalTo: "approverequest")
                gp.enter()
                query2.findObjectsInBackground( block:{(objs,err) in
                    
                    if objs?.count == 0 {
                        
                        f2 = false
                        
                    }
                    
                    gp.leave()
                
                })
                
                gp.notify(queue: .main) {
                    
                    if f1 || f2 {
                        
                        var alertt = UIAlertController(title: "数据传送中......", message: "", preferredStyle: .alert)
                        self.present(alertt, animated: true)
                        
                        var imageData:NSData = (self.store["pic1"] as! UIImage).jpegData(compressionQuality: 0)! as NSData
                        var compressedData = self.compressImage(UIImage(data: imageData as Data)!, maxSizeKB: 500)
                        var strBase64 = compressedData!.base64EncodedString(options: [])
                        self.newdict.updateValue(strBase64 as String, forKey: "pic1")
                        
                        imageData = (self.store["pic2"] as! UIImage).jpegData(compressionQuality: 0)! as NSData
                        compressedData = self.compressImage(UIImage(data: imageData as Data)!, maxSizeKB: 500)
                        strBase64 = compressedData!.base64EncodedString(options: [])
                        self.newdict.updateValue(strBase64 as String, forKey: "pic2")
                        
                        imageData = (self.store["pic3"] as! UIImage).jpegData(compressionQuality: 0)! as NSData
                        compressedData = self.compressImage(UIImage(data: imageData as Data)!, maxSizeKB: 500)
                        strBase64 = compressedData!.base64EncodedString(options: [])
                        self.newdict.updateValue(strBase64 as String, forKey: "pic3")
                        
                        imageData = (self.store["pic4"] as! UIImage).jpegData(compressionQuality: 0)! as NSData
                        compressedData = self.compressImage(UIImage(data: imageData as Data)!, maxSizeKB: 500)
                        strBase64 = compressedData!.base64EncodedString(options: [])
                        self.newdict.updateValue(strBase64 as String, forKey: "pic4")
                        
                        let op1 = self.store["op1"]
                        let op2 = self.store["op2"]
                        let op3 = self.store["op3"]
                        let op4 = self.store["op4"]
                        let correct = self.store["correct"]
                        let self_icon = self.store["self_icon"]
                        let self_name = self.store["self_name"]
                        imageData = (self_icon as! UIImage).jpegData(compressionQuality: 0)! as NSData
                        strBase64 = imageData.base64EncodedString(options: [])
                        
                        self.newdict.updateValue(op1 as! String, forKey: "op1")
                        self.newdict.updateValue(op2 as! String, forKey: "op2")
                        self.newdict.updateValue(op3 as! String, forKey: "op3")
                        self.newdict.updateValue(op4 as! String, forKey: "op4")
                        self.newdict.updateValue(correct as! String, forKey: "correct")
                        self.newdict.updateValue(strBase64 as! String, forKey: "self_icon")
                        self.newdict.updateValue(self_name as! String, forKey: "self_name")
                        imageData = (icon as! UIImage).jpegData(compressionQuality: 0)! as NSData
                        strBase64 = imageData.base64EncodedString(options: [])
                        self.newdict.updateValue(strBase64 as String, forKey: "his_icon")
                        self.newdict.updateValue(id, forKey: "his_id")
                        
                        var user: PFObject!
//                        let his_id = id
//                        let query = PFUser.query()
//                        query?.whereKey("username", equalTo: his_id)
                        let gp1 = DispatchGroup()
                        gp1.enter()
                        
                        PFCloud.callFunction(inBackground: "searchUsers", withParameters: ["username": id]) { (result: Any?, error1: Error?) in
                            
                            if(error1 == nil) {
//                              user = result?.first
                                guard let userObjects = result as? [PFObject],
                                let u = userObjects.first as? PFUser else {
                                    print("No user found with username: \(id)")
                                    self.showErrorAlert(message: "User not found")
                                    return
                                }
                                let current = PFUser.current()
                                let groupACL = PFACL()
                                
                                user = u
                                
                                groupACL.setReadAccess(true, for: user as! PFUser)
                                groupACL.setWriteAccess(true, for: user as! PFUser)
                                
                                let joinTable = PFObject(className: "JoinTable")
                                let question = self.newdict
//                                var jsonData: String!
//                                if let prettyData = try? JSONSerialization.data(withJSONObject: question, options: .prettyPrinted) {
//                                    if let prettyString = String(data: prettyData, encoding: .utf8) {
//                                        print("格式化后的 JSON:\n\(prettyString)")
//                                        jsonData = prettyString
//                                    }
//                                }
//                              question = String(data: jsonData!, encoding: .utf8)
                                
                                joinTable.acl = groupACL
                                
                                // 在保存之前添加详细的日志
                                print("Before saving joinTable:")
                                print("Current thread: \(Thread.current)")
                                print("Is main thread: \(Thread.isMainThread)")

                                // 检查 question 数据
//                                print("Question data type: \(type(of: self.newdict))")
//                                print("Question keys: \(Array(self.newdict.keys))")
//                                for (key, value) in self.newdict {
//                                    print("Key: \(key), Value type: \(type(of: value)), Value: \(value)")
//                                }

                                // 检查用户数据
                                print("To user: \(user.objectId ?? "no id")")
                                print("From user: \(PFUser.current()?.objectId ?? "no id")")
                                
                                if let dict = question as? [String: Any] {
                                    joinTable.setObject(dict, forKey: "question")  // 自动转为 Parse Object
                                }
//                                joinTable.setObject(question, forKey: "question")
                                joinTable.setObject(user as Any, forKey: "to")
                                joinTable.setObject(current as Any, forKey: "from")
                                
                                // 添加日志输出，查看 question 内容
//                                print("即将保存的 question 内容: \(question)")
                                
                                joinTable.saveInBackground{(success, error) in
                                    
                                    if success {
                                        
                                        print("table saved")
                                        gp1.leave()
                                        
                                    } else {
                                        
                                        if let error = error {
                                            print(error)
                                            alert.dismiss(animated: true)
                                            let alert = UIAlertController(title: "发生内部错误，请稍后再试", message: "", preferredStyle: .alert)
                                            alert.addAction(UIAlertAction(title: "知道了", style: .default, handler: nil))
                                            self.present(alert, animated: true)
                                        } else {
                                            print("table error")
                                            alert.dismiss(animated: true)
                                            let alert = UIAlertController(title: "发生内部错误，请稍后再试", message: "", preferredStyle: .alert)
                                            alert.addAction(UIAlertAction(title: "知道了", style: .default, handler: nil))
                                            self.present(alert, animated: true)
                                        }
                                        
                                        // 显示错误给用户
                                        alertt.dismiss(animated: true) {
                                            let alert = UIAlertController(title: "发送失败", message: "请检查网络连接后重试", preferredStyle: .alert)
                                            alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
                                            self.present(alert, animated: true)
                                        }
                                        
                                    }
                                    
                                }
                                
                            } else {
                                
                                print(error1 as Any)
                                alert.dismiss(animated: true)
                                let alert = UIAlertController(title: "发生内部错误，请稍后再试", message: "", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "知道了", style: .default, handler: nil))
                                self.present(alert, animated: true)
                                
                            }
                            
                        }
                        
                        gp1.notify(queue: .main) {
                            
                            let gp2 = DispatchGroup()
                            let qy = PFQuery(className: "Rapport")
                            qy.whereKey("from", equalTo: PFUser.current()!)
                            qy.whereKey("to", equalTo: user!)
                            let that = try! qy.getFirstObject()
                            let numdic = that["numOfQuestionToHim"] as! [String : Int]
                            var num = numdic[user!.objectId!]
                            num = num! + 1
                            that.setObject([user!.objectId! : num] , forKey: "numOfQuestionToHim")
                            gp2.enter()
                            that.saveInBackground{ (success, error) in
                                if success {
                                    print("numOfQuestionToHim saved")
                                    
                                    PFCloud.callFunction(inBackground: "sendTiPush", withParameters: ["someId": user.objectId, "someName": PFUser.current()!.username]) {
                                        (result, error) in
                                        if (error == nil) {
                                            print("rt")
                                            print(result)
                                        } else {
                                            print(error?.localizedDescription)
                                        }
                                    }
                                    
                                    gp2.leave()
                                    
                                } else {
                                    
                                    if let error = error {
                                        print(error)
                                        alert.dismiss(animated: true)
                                        let alert = UIAlertController(title: "发生内部错误，请稍后再试", message: "", preferredStyle: .alert)
                                        alert.addAction(UIAlertAction(title: "知道了", style: .default, handler: nil))
                                        self.present(alert, animated: true)
                                    } else {
                                        print("table error")
                                        alert.dismiss(animated: true)
                                        let alert = UIAlertController(title: "发生内部错误，请稍后再试", message: "", preferredStyle: .alert)
                                        alert.addAction(UIAlertAction(title: "知道了", style: .default, handler: nil))
                                        self.present(alert, animated: true)
                                    }
                                }
                            }
                            
                            gp2.notify(queue: .main) {
                                
                                alertt.dismiss(animated: true) {
                                    
                                    OperationQueue.main.addOperation {
                                        
                                        let alert = UIAlertController(title: "发送完毕！", message: "", preferredStyle: .alert)
                                        alert.addAction(UIAlertAction(title: "好👌", style: .default, handler: { action in
                                            self.performSegue(withIdentifier: "finishSendTi", sender: self)
                                        }))
                                        self.present(alert, animated: true)
                                        
                                    }
                                    
                                }
                                
                            }
                            
                        }
                        
                    } else {
                        
                        let alert = UIAlertController(title: "你还不是TA的好友，请发送好友请求", message: "", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "知道了", style: .default, handler: { action in
                            self.performSegue(withIdentifier: "finishSendTi", sender: self)
                        }))
                        self.present(alert, animated: true)
                        
                    }
                    
                }
            
            })
                
            )
            
            alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil
            ))
            
            self.present(alert, animated: true)
        }
        
        if self.friendList == self.friendReqList {
            
            let alert = UIAlertController(title: "是否同意该好友请求?", message: "", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "同意", style: .default, handler: { action in
                
                // 安全地查询用户
                let tableQuery = PFQuery(className: "JoinTable")
                guard let userQuery = PFUser.query() else {
                    print("Error: 无法创建User查询")
                    self.showErrorAlert(message: "无法处理该请求，请稍后再试")
                    return
                }
                
                let acl = PFACL()
                
                // 查询用户
                userQuery.whereKey("username", equalTo: id)
                
                // 声明一个外部变量保存用户对象，可在整个handler中使用
                var foundUser: PFUser? = nil
                
                // 使用Cloud Function "searchUsers"获取用户
                // 在调用Cloud Function之前添加调试日志
                print("Before calling searchUsers Cloud Function")
                
                let currentConfig = PFConfig.current()
                print("Current Parse configuration: \(currentConfig)")
                 
                if let serverURL = Parse.currentConfiguration?.server {
                    print("Current Parse server URL: \(serverURL)")
                } else {
                    print("No Parse server URL configured")
                }

                // 在调用Cloud Function之前添加调试日志
                print("Before calling searchUsers Cloud Function")

                do {
                    print("Calling searchUsers Cloud Function with username: \(id)")
                    
                    do {
                        let result = try PFCloud.callFunction("searchUsers", withParameters: ["username": id]) as? [PFObject]
                        guard let users = result, let user = users.first as? PFUser else {
                            print("No user found with username: \(id)")
                            return
                        }
                        print("Found user: \(user.username ?? "N/A")")
                        foundUser = user
                    } catch {
                        print("Cloud function error: \(error.localizedDescription)")
                        self.showErrorAlert(message: "Failed to search users")
                    }
                    
                } catch {
                    print("Error in Cloud Function call: \(error.localizedDescription)")
                    self.showErrorAlert(message: "处理请求时出错，请稍后再试")
                    return
                }
                
                do {
                    // 检查是否成功获取到用户
                    guard let user = foundUser else {
                        print("Error: 不能继续处理，用户对象为空")
                        self.showErrorAlert(message: "处理请求时出错，请稍后再试")
                        return
                    }
                    
                    // 查询请求
                    tableQuery.whereKey("from", equalTo: user)
                    tableQuery.whereKey("to", equalTo: PFUser.current()!)
                    tableQuery.whereKey("request", equalTo: "sendrequest")
                    
                    let requestObjects = try tableQuery.findObjects()
                    guard let request = requestObjects.first else {
                        print("Error: 没有找到匹配的请求")
                        self.showErrorAlert(message: "请求信息不存在，可能已被删除")
                        return
                    }
                    
                    print("Request found: \(request.objectId ?? "<no id>")")
                    
                    // 设置请求和权限
                    request.setObject("approverequest", forKey: "request")
                    acl.setReadAccess(true, for: PFUser.current()!)
                    acl.setWriteAccess(true, for: PFUser.current()!)
                    acl.setReadAccess(true, for: (foundUser)!)
                    acl.setWriteAccess(true, for: (foundUser)!)
                    request.acl = acl
                    request.saveEventually()
                } catch {
                    print("Error processing friend request: \(error.localizedDescription)")
                    self.showErrorAlert(message: "处理请求时出错，请稍后再试")
                    return
                }
                
                // 检查是否成功获取到用户
                guard let user = foundUser else {
                    print("Error: 不能继续处理，用户对象为空")
                    self.showErrorAlert(message: "处理请求时出错，请稍后再试")
                    return
                }
                
                // 现在可以安全地使用user对象
                var list = PFUser.current()!["friendReqList"] as! [PFObject]
               
                print(list.count)
                    
                for i in 0 ..< list.count {
                    // 安全地使用user.objectId，不需要强制解包
                    if user.objectId == list[i].objectId {
                        print("JIN")
                        list.remove(at: i)
                        self.friendReqList = list
                        break
                    }
                }
                
                print(list.count)
                PFUser.current()!.setObject(list, forKey: "friendReqList")
                
                let group = DispatchGroup()
                group.enter()
                
                do {
                    PFUser.current()!.saveEventually()
                    print("long\((PFUser.current()!["friendReqList"] as! [PFObject]).count)")
                    group.leave()
                }
                
                group.notify(queue: .main) {
                    print("waahh")
                    
                    // 使用user.objectId，安全地访问
                    let userId = user.objectId ?? ""
                    
//                    PFCloud.callFunction(inBackground: "friendReqApprove", withParameters: [
//                        "someId": userId,
//                        "someName": PFUser.current()!["username"] ?? ""
//                    ]) { (result, error) in
//                        if error == nil {
//                            print(result ?? "Success")
//                        } else {
//                            print(error?.localizedDescription ?? "Unknown error")
//                        }
//                    }
                    
                    do {
                        let result = try PFCloud.callFunction("friendReqApprove", withParameters: [
                            "someId": userId,
                            "someName": PFUser.current()!["username"] ?? ""
                        ])
                        print("Friend request approved: \(String(describing: result))")
                    } catch {
                        print("Error approving friend request: \(error.localizedDescription)")
                        self.showErrorAlert(message: "处理好友请求时出错，请稍后再试")
                    }
                    
                    // 更新本地数据源
//                    if var friendReqList = PFUser.current()?["friendReqList"] as? [String] {
//                        friendReqList.removeAll { $0 == user.username }
//                        PFUser.current()?["friendReqList"] = friendReqList
//                        try PFUser.current()?.save()
//                    }
                    
                    // 更新好友请求列表
                    var list = PFUser.current()!["friendReqList"] as! [PFObject]
                    
                    for i in 0 ..< list.count {
                        if foundUser?.objectId == list[i].objectId {
                            list.remove(at: i)
                            break
                        }
                    }
                    
                    // 更新用户数据
                    PFUser.current()!.setObject(list, forKey: "friendReqList")
                    PFUser.current()!.saveEventually()
                    
                    // 刷新表格
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    
                    print("second")
                    self.viewDidLoad()
                }
            }))
            
            alert.addAction(UIAlertAction(title: "不同意", style: .cancel, handler: { action in
                // 创建Query对象
                let tableQuery = PFQuery(className: "JoinTable")
                guard let userQuery = PFUser.query() else {
                    print("Error: 无法创建User查询")
                    self.showErrorAlert(message: "无法处理操作，请稍后再试")
                    return
                }
                
                // 安全地查询用户
                userQuery.whereKey("username", equalTo: id)
                
                // 声明一个外部变量保存用户对象，可在整个handler中使用
                var foundUser: PFUser? = nil
                
                // 使用Cloud Function "searchUsers"获取用户
                do {
                    print("Calling searchUsers Cloud Function with username: \(id)")
                    
                    do {
                        let result = try PFCloud.callFunction("searchUsers", withParameters: ["username": id]) as? [PFObject]
                        guard let users = result, let user = users.first as? PFUser else {
                            print("No user found with username: \(id)")
                            return
                        }
                        print("Found user: \(user.username ?? "N/A")")
                        foundUser = user
                    } catch {
                        print("Cloud function error: \(error.localizedDescription)")
                        self.showErrorAlert(message: "Failed to search users")
                    }
                    
                } catch {
                    print("Error in Cloud Function call: \(error.localizedDescription)")
                    self.showErrorAlert(message: "处理请求时出错，请稍后再试")
                    return
                }
                
                do {
                    // 检查是否成功获取到用户
                    guard let user = foundUser else {
                        print("Error: 不能继续处理，用户对象为空")
                        self.showErrorAlert(message: "处理请求时出错，请稍后再试")
                        return
                    }
                    
                    // 查询请求
                    tableQuery.whereKey("from", equalTo: user)
                    tableQuery.whereKey("to", equalTo: PFUser.current()!)
                    tableQuery.whereKey("request", equalTo: "sendrequest")
                    
                    let results = try tableQuery.findObjects()
                    if let request = results.first {
                        // 更新请求状态
                        request["request"] = "rejectrequest"
                        
                        // 设置ACL
                        let acl = PFACL()
                        request.setObject("rejectrequest", forKey: "request")
                        acl.setReadAccess(true, for: PFUser.current()!)
                        acl.setWriteAccess(true, for: PFUser.current()!)
                        acl.setReadAccess(true, for: (foundUser)!)
                        acl.setWriteAccess(true, for: (foundUser)!)
                        request.acl = acl
                        request.saveEventually()
                        
                        // 保存更新
//                        try request.save()
                        
                        // 更新本地数据源
//                        if var friendReqList = PFUser.current()?["friendReqList"] as? [String] {
//                            friendReqList.removeAll { $0 == user.username }
//                            PFUser.current()?["friendReqList"] = friendReqList
//                            try PFUser.current()?.save()
//                        }
                        
                    }
                    
                    // 更新好友请求列表
                    var list = PFUser.current()!["friendReqList"] as! [PFObject]
                    
                    for i in 0 ..< list.count {
                        if foundUser?.objectId == list[i].objectId {
                            list.remove(at: i)
                            break
                        }
                    }
                    
                    // 更新用户数据
                    PFUser.current()!.setObject(list, forKey: "friendReqList")
                    PFUser.current()!.saveEventually()
                    
                    // 通知用户
                    self.showSuccessAlert(message: "已拒绝用户 \(foundUser?.username ?? id) 的好友请求")
                    
                    // 刷新界面
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.viewDidLoad()
                    }
                    // 刷新表格
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                } catch {
                    print("Error rejecting friend request: \(error.localizedDescription)")
                    self.showErrorAlert(message: "处理请求时出错，请稍后再试")
                }
            }))
            
            self.present(alert, animated: true)
            
        }
    
    }
    
}
