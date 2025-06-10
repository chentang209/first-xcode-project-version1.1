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
    let current = PFUser.current()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //        SessionManager.shared.resetTimer()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //        SessionManager.shared.resetTimer()
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        friendListUpdate = false
        friendList = []
        friendReqList = []
        arrayUserObj = []
        tableView.delegate = self
        tableView.dataSource = self
        
        // 设置导航栏标题样式
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.black,
            .font: UIFont.boldSystemFont(ofSize: 18)
        ]
        
        // 确保导航栏不透明
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.barTintColor = UIColor.white
        
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
                    print("Friend request sender's objectId: \(sender.objectId)")
                    
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
                            self.current!.setObject(self.friendReqList, forKey: "friendReqList")
                            self.current?.saveEventually()
                            
                        }
                        
                    } else {
                        
                        print("69696969")
                        self.friendReqList.append(sender)
                        self.current!.setObject(self.friendReqList, forKey: "friendReqList")
                        self.current?.saveEventually()
                        
                    }
                    
                }
                
            }
            
            group1.leave()
            
        }
        
        group1.notify(queue: .main) {
            
            let friendReqList = self.current!["friendReqList"] as! [PFObject]
            
            self.friendReqList = friendReqList.compactMap { $0 as? PFUser }
            
            print("显示friendReqList数据: \(self.friendReqList)")
            
            let grp = DispatchGroup()
            
            // 优先展示请求列表逻辑：有未处理请求时显示请求列表，否则显示好友列表
            if !self.friendReqList.isEmpty {
                self.title = "请求列表"
                print("显示请求列表，共\(self.friendReqList.count)条请求")
                DispatchQueue.main.async {
                    self.friendList = self.friendReqList
                    self.tableView.reloadData()
                }
                if self.friendDelegate != nil {
                    self.friendDelegate.reddot(bol: "true")
                }
            } else {
                //            self.title = "好友列表"
                print("无未处理请求，显示好友列表")
                
                grp.enter()
                // 清除本地缓存，从 Parse 服务器获取最新数据
                self.fetchFriendList(cachePolicy: .networkOnly) { [weak self] friends in
                    self?.friendList = friends
                    grp.leave()
                    self?.tableView.reloadData()
                }
                
                // self.friendList = current!["friendList"] as! [PFObject]
                DispatchQueue.main.async {
                    self.title = "好友列表"
                    self.tableView.reloadData()
                }
                if self.friendDelegate != nil {
                    self.friendDelegate.reddot(bol: "false")
                }
            }
            
            grp.notify(queue: .main) {
                if self.friendReqList.isEmpty && self.friendList.isEmpty {
                    
                    let alert = UIAlertController(title: "请添加好友", message: "", preferredStyle: .alert)
                    self.present(alert, animated: true)
                    let when = DispatchTime.now() + 1
                    DispatchQueue.main.asyncAfter(deadline: when) {
                        
                        alert.dismiss(animated: true)
                        self.performSegue(withIdentifier: "finishSendTi", sender: self)
                        
                    }
                    
                }
            }
            
            // 强制更新标题显示
            DispatchQueue.main.async {
                if !self.friendReqList.isEmpty {
                    self.title = "请求列表"
                } else {
                    self.title = "好友列表"
                }
            }
            
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
                                                        
                            self.arrayUserObj.append(user)
                            print("\(self.arrayUserObj.count)nnnn")
                            
                            // 不自动保存到服务器，只在本地更新
                            self.arrayUserObj = current!["friendList"] as! [PFObject]
                            print("只读取本地数据，不修改服务器")
                            self.friendListUpdate = true
                            
                            // 直接返回而不保存
                            group2.leave()
                            
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
                            
                            for i in 0 ..< friendList2.count {
                                
                                if friendList2[i].objectId == user.objectId {
                                    
                                    flag = 1
                                    group3.leave()
                                    break
                                    
                                }
                                
                            }
                            
                            if flag == 0 {
                                
                                // 不自动保存到服务器，只在本地更新
                                self.arrayUserObj = current2!["friendList"] as! [PFObject]
                                self.friendListUpdate = true
                                print("只读取本地数据，不修改服务器")
                                
                                // 直接返回而不保存
                                group3.leave()
                                
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
                                    
                                    print("只在本地创建关系，不自动保存到服务器")
                                    
                                }
                                
                            }
                            
                        }
                        
                    }
                    
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
    
    // 滑动删除好友并同步 Parse 后端
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let currentUser = PFUser.current()!
        
        // 检查是否在好友列表模式（而非请求列表模式）
        let isInFriendListMode = (self.friendList != self.friendReqList && self.title == "好友列表")
        
        if isInFriendListMode {
            
            if (editingStyle == .delete) {
                
                if !afterchuti {
                    
                    var userObj: PFUser?
                    
                    let name = currentUser.username
                    let params = ["username": name]
                    
                    print("\(name): 使用Cloud Function获取用户")
                    
                    let gr = DispatchGroup()
                    
                    gr.enter()
                    
                    // 直接使用当前用户实例避免云函数查询延迟
                    let currentUser = PFUser.current()!
                    userObj = currentUser
                    gr.leave()
                    
                    gr.notify(queue: .main) {
                        
                        // 1. 本地 friendList 数组移除
                        let toDelUser = self.friendList[indexPath.row] as? PFUser
                        print("    在存之前的indexPath.row   : \(indexPath.row)")
                        print("    在存之前的toDelUser   : \(toDelUser)")
                        self.friendList.remove(at: indexPath.row)
                        self.tableView.deleteRows(at: [indexPath], with: .automatic)
                        self.tableView.reloadData()
                        
                        // 2. Parse 后端 friendList 字段移除（增加错误提示和强制刷新）
                        if var friends = userObj?["friendList"] as? [PFUser] {
                            friends.removeAll {$0.objectId == toDelUser?.objectId}
                            print("    在存之前的friends   : \(friends)")
                            userObj?["friendList"] = friends
                            userObj?.saveInBackground { (success, error) in
                                if success {
                                    print("Parse friendList 已移除好友")
                                    
                                    let params = ["userId": toDelUser?.objectId]
                                    
                                    print("\(toDelUser?.objectId): 使用Cloud Function获取对方用户")
                                    
                                    PFCloud.callFunction(inBackground: "fetchUserWithMasterKey", withParameters: params) { (result, error) in
                                        if let error = error {
                                            print("调用失败: \(error)")
                                            return
                                        }
                                        
                                        guard let resultDict = result as? [String: Any],
                                              let success = resultDict["success"] as? Bool,
                                              success,
                                              let userDict = resultDict["user"] as? [String: Any],
                                              let objectId = userDict["objectId"] as? String else {
                                            print("数据解析失败")
                                            return
                                        }
                                        
                                        print("对方用户的objectId: \(objectId)")
                                        
                                        // 修改对方好友列表
                                        PFCloud.callFunction(inBackground: "removeFriend", withParameters: [
                                            "userId": toDelUser?.objectId!, // 对方用户 ID
                                            "friendId": userObj?.objectId!  // 当前用户 ID
                                        ]) { (result, error) in
                                            DispatchQueue.main.async {
                                                if let error = error {
                                                    self.showErrorAlert(message: "删除失败: \(error.localizedDescription)")
                                                } else {
                                                    self.showSuccessAlert(message: "删除成功")
                                                    print("双向删除好友结束")
                                                }
                                            }
                                        }
                                    }
                                    
                                } else {
                                    print("Parse 移除失败: \(String(describing: error))")
                                    self.showErrorAlert(message: "删除失败，请检查网络连接")
                                    // 回滚本地数组（避免本地与服务器不一致）
                                    self.friendList.insert(toDelUser!, at: indexPath.row)
                                    self.tableView.insertRows(at: [indexPath], with: .automatic)
                                }
                            }
                        }
                        
                        // 后续Rapport表删除逻辑保持不变...
                    }
                }
            }
        }
    }
    
    // 修改fetchFriendList方法，支持缓存策略
    func fetchFriendList(cachePolicy: PFCachePolicy = .cacheThenNetwork, completion: @escaping ([PFUser]) -> Void) {
        guard let objectId = PFUser.current()?.objectId else {
            print("objectId 为空，无法调用云函数")
            completion([])
            return
        }
        print("准备调用云函数，objectId=\(objectId)")
        // 显式设置缓存策略为仅网络（避免读取旧缓存）
        let query = PFQuery(className: "_User")
        query.cachePolicy = cachePolicy
        query.getObjectInBackground(withId: objectId) { [weak self] (user, error) in
            if let error = error {
                print("获取用户失败: \(error.localizedDescription)")
                completion([])
                return
            }
            guard let user = user as? PFUser, let friends = user["friendList"] as? [PFUser] else {
                completion([])
                return
            }
            completion(friends)
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
        print("看看    friendList: \(friendList)")
        print("看看    indexPath.row: \(indexPath.row)")
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
            
            if let avatarUrlString = directUser["avatar"] as? String,
               let avatarUrl = URL(string: avatarUrlString) {
                
                // 使用URLSession或第三方库加载网络图片
                URLSession.shared.dataTask(with: avatarUrl) { [weak self] (data, _, error) in
                    if let error = error {
                        print("\(objectId): 下载头像失败 - \(error.localizedDescription)")
                        return
                    }
                    
                    if let data = data, let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            guard let self = self,
                                  let cell = self.tableView?.cellForRow(at: indexPath) as? FriendCell else {
                                print("\(objectId): Cell已不可见")
                                return
                            }
                            
                            cell.friendIcon.image = image
                            print("\(objectId): 设置头像成功")
                        }
                    }
                }.resume()
                
            } else {
                print("用户没有有效头像URL")
                DispatchQueue.main.async {
                    (self.tableView?.cellForRow(at: indexPath) as? FriendCell)?.friendIcon.image = UIImage(named: "user")
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
                print("看看userData: \(userData)")
                let username = userData["username"] as? String ?? "未知用户"
                let avatarUrl = userData["avatar"] as? String
                
                print("\(objectId): 使用Cloud Function成功获取用户 - \(username)")
                
                DispatchQueue.main.async {
                    // 查找标记为当前索引的可见cell
                    if let cells = tableView.visibleCells as? [FriendCell],
                       let visibleCell = cells.first(where: { $0.tag == indexPath.row }) {
                        
                        guard let userId = userData["objectId"] as? String else {
                            print("用户ID缺失")
                            return
                        }
                        
                        var tmpUser: PFUser?
                        do {
                            let result = try PFCloud.callFunction("searchUsers", withParameters: ["username": username]) as? [PFObject]
                            guard let users = result, let user = users.first as? PFUser else {
                                print("No user found with username: \(username)")
                                return
                            }
                            print("Found user: \(user.username ?? "N/A")")
                            tmpUser = user
                        } catch {
                            print("Cloud function error: \(error.localizedDescription)")
                            self.showErrorAlert(message: "Failed to search users")
                        }
                        
                        let pq = PFQuery(className: "Rapport")
                        pq.whereKey("from", equalTo: PFUser.current()!)
                        pq.whereKey("to", equalTo: tmpUser)
                        
                        var level : String = "无"
                        var score : Double = 0.0
                        
                        let dispatchGroup = DispatchGroup()
                        dispatchGroup.enter()
                        
                        pq.getFirstObjectInBackground { (obj, err) in
                            // 安全获取字段值（避免强制解包崩溃）
                            level = obj?["level"] as? String ?? "无"
                            score = obj?["compatibilityScore"] as? Double ?? 0.0
                            
                            if let error = err {
                                print(error)
                            }
                            
                            dispatchGroup.leave()
                        }
                        
                        dispatchGroup.notify(queue: .main) {
                            visibleCell.friendName.text = username + "   " + "默契程度 ：" + level + "(\(score)%)"
                        }
                        
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
    
    func printDict(_ dict: [String: Any], prefix: String = "") {
        for (k, v) in dict {
            print("\(prefix)\(k): \(v), type: \(type(of: v))")
            if let subDict = v as? [String: Any] {
                printDict(subDict, prefix: prefix + "  ")
            } else if let arr = v as? [Any] {
                for (i, item) in arr.enumerated() {
                    print("\(prefix)  [\(i)]: \(item), type: \(type(of: item))")
                    if let subDict = item as? [String: Any] {
                        printDict(subDict, prefix: prefix + "    ")
                    }
                }
            }
        }
    }
    
    // MARK: - Parse 图片上传相关
    /// 直接上传图片Data到Parse，完成后回调PFFileObject
    func uploadImageDataToParse(imageData: Data, imageName: String, completion: @escaping (PFFileObject?) -> Void) {
        let file = PFFileObject(name: imageName, data: imageData)
        file?.saveInBackground { (success, error) in
            if success {
                print("[Parse] 图片文件上传成功: \(file?.name ?? imageName)")
                completion(file)
            } else {
                print("[Parse] 图片文件上传失败[\(file?.name ?? imageName)]: \(error?.localizedDescription ?? "未知错误")")
                completion(nil)
            }
        }
    }
    
    /// 上传图片到Parse（UIImage接口，内部转Data）
    func uploadImageToParse(image: UIImage, imageName: String, completion: @escaping (PFFileObject?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("[ERROR] 图片压缩失败")
            completion(nil)
            return
        }
        uploadImageDataToParse(imageData: imageData, imageName: imageName, completion: completion)
    }
    
    /// 上传图片到JoinTable的question字段，支持自定义图片键名
    func uploadPicToJoinTableQuestion(image: UIImage, imageKey: String) {
        uploadImageToParse(image: image, imageName: imageKey) { file in
            guard let file = file else {
                print("[ERROR] 图片上传失败，无法存入 JoinTable.question")
                return
            }
            // 构造 question 字典，imageKey 为 PFFileObject
            let questionDict: [String: Any] = [
                imageKey: file
                // 可添加其它字段
            ]
            let joinTable = PFObject(className: "JoinTable")
            joinTable["question"] = questionDict
            joinTable.saveInBackground { success, error in
                if success {
                    print("[Parse] 图片已作为 PFFileObject 存入 JoinTable.question.\(imageKey)")
                } else {
                    print("[ERROR] 保存到 JoinTable 失败: \(error?.localizedDescription ?? "未知错误")")
                }
            }
        }
    }
    
    func myTableDelegate(id: String, icon: UIImage) {
        
        var concatId : String = id
        
        if let range = id.range(of: "   ") {
            concatId = String(id.prefix(upTo: range.lowerBound))
        }
        
        if afterchuti {
            
            let alert = UIAlertController(title: "是否把题目发送给该好友?", message: "", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { action in
                
                var f1 = true
                var f2 = true
                let query1 = PFQuery(className: "JoinTable")
                
                let gp = DispatchGroup()
                
                var foundUser: PFUser? = nil
                
                do {
                    print("Calling searchUsers Cloud Function with username: \(concatId)")
                    
                    do {
                        let result = try PFCloud.callFunction("searchUsers", withParameters: ["username": concatId]) as? [PFObject]
                        guard let users = result, let user = users.first as? PFUser else {
                            print("No user found with username: \(concatId)")
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
                        
                        // --- 新图片上传逻辑 ---
                        let imageKeys = ["pic1", "pic2", "pic3", "pic4", "his_icon", "self_icon"]
                        let imageSources: [String: UIImage] = [
                            "pic1": self.store["pic1"] as! UIImage,
                            "pic2": self.store["pic2"] as! UIImage,
                            "pic3": self.store["pic3"] as! UIImage,
                            "pic4": self.store["pic4"] as! UIImage,
                            "his_icon": icon as! UIImage,
                            "self_icon": self.store["self_icon"] as! UIImage
                        ]
                        
                        var questionDict = [String: Any]()
                        let uploadGroup = DispatchGroup()
                        for key in imageKeys {
                            if let img = imageSources[key] {
                                uploadGroup.enter()
                                let compressedData = self.compressImage(img, maxSizeKB: 500) ?? img.jpegData(compressionQuality: 0.8)
                                if let data = compressedData {
                                    self.uploadImageDataToParse(imageData: data, imageName: key) { file in
                                        if let file = file {
                                            questionDict[key] = file
                                        } else {
                                            print("[ERROR] 图片上传失败: \(key)")
                                        }
                                        uploadGroup.leave()
                                    }
                                } else {
                                    print("[ERROR] 压缩图片失败: \(key)")
                                    uploadGroup.leave()
                                }
                            }
                        }
                        
                        // 其它非图片字段直接赋值到questionDict
                        questionDict["op1"] = self.store["op1"] as! String
                        questionDict["op2"] = self.store["op2"] as! String
                        questionDict["op3"] = self.store["op3"] as! String
                        questionDict["op4"] = self.store["op4"] as! String
                        questionDict["correct"] = self.store["correct"] as! String
                        questionDict["self_name"] = self.store["self_name"] as! String
                        questionDict["his_id"] = concatId
                        
                        let joinTable = PFObject(className: "JoinTable")
                        var user: PFUser?
                        let gp1 = DispatchGroup()
                        
                        gp1.enter()
                        
                        // 等全部图片上传完毕后再保存JoinTable
                        uploadGroup.notify(queue: .main) {
                            joinTable.setObject(questionDict, forKey: "question")
                            
                            PFCloud.callFunction(inBackground: "searchUsers", withParameters: ["username": concatId]) { (result: Any?, error1: Error?) in
                                if(error1 == nil) {
                                    
                                    guard let userObjects = result as? [PFObject],
                                          let u = userObjects.first as? PFUser else {
                                        print("No user found with username: \(concatId)")
                                        self.showErrorAlert(message: "User not found")
                                        return
                                    }
                                    let current = PFUser.current()
                                    let groupACL = PFACL()
                                    
                                    user = u
                                    
                                    groupACL.setReadAccess(true, for: user as! PFUser)
                                    groupACL.setWriteAccess(true, for: user as! PFUser)
                                    
                                    joinTable.acl = groupACL
                                    
                                    // 在保存之前添加详细的日志
                                    print("Before saving joinTable:")
                                    print("Current thread: \(Thread.current)")
                                    print("Is main thread: \(Thread.isMainThread)")
                                    joinTable.setObject(user as Any, forKey: "to")
                                    joinTable.setObject(current as Any, forKey: "from")
                                    
                                    joinTable.saveInBackground { (success, error) in
                                        if success {
                                            print("table saved")
                                            gp1.leave()
                                        } else {
                                            if let error = error {
                                                print("打印后台保存join表的错误: \(error)")
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
                        }
                        
                        gp1.notify(queue: .main) {
                            
                            let gp2 = DispatchGroup()
                            
                            var that: PFObject?
                            
                            // 1. 定义查询条件（检查是否存在 from → to 的记录）
                            let qy = PFQuery(className: "Rapport")
                            qy.whereKey("from", equalTo: PFUser.current()!) // 当前用户
                            qy.whereKey("to", equalTo: user!)               // 目标用户
                            
                            // 2. 尝试获取记录
                            let d1 = DispatchGroup()
                            d1.enter()
                            do {
                                that = try qy.getFirstObject()
                                print("记录已存在: \(that?.objectId ?? "")")
                                d1.leave()
                            } catch {
                                // 3. 如果记录不存在（或查询失败），则创建双向记录
                                let newRapportFromTo = PFObject(className: "Rapport")
                                newRapportFromTo["from"] = PFUser.current()!
                                newRapportFromTo["to"] = user!
                                newRapportFromTo["numOfQuestionToHim"] = [user?.objectId : 0]
                                newRapportFromTo["numHisCorrect"] = [user?.objectId : 0]
                                newRapportFromTo["level"] = "无"
                                newRapportFromTo["compatibilityScore"] = 0.0
                                newRapportFromTo.acl?.setWriteAccess(true, for: user!)
                                newRapportFromTo.acl?.setWriteAccess(true, for: PFUser.current()!)
                                
                                let newRapportToFrom = PFObject(className: "Rapport")
                                newRapportToFrom["from"] = user!  // 交换 from/to
                                newRapportToFrom["to"] = PFUser.current()!
                                newRapportToFrom["numOfQuestionToHim"] = [PFUser.current()?.objectId : 0]
                                newRapportToFrom["numHisCorrect"] = [PFUser.current()?.objectId : 0]
                                newRapportToFrom["level"] = "无"
                                newRapportToFrom["compatibilityScore"] = 0.0
                                newRapportToFrom.acl?.setWriteAccess(true, for: PFUser.current()!)
                                newRapportToFrom.acl?.setWriteAccess(true, for: user!)
                                
                                // 4. 批量保存两条记录（原子操作，避免部分成功）
                                PFObject.saveAll(inBackground: [newRapportFromTo, newRapportToFrom]) { (success, error) in
                                    if success {
                                        print("双向记录创建成功: From=\(newRapportFromTo.objectId ?? ""), To=\(newRapportToFrom.objectId ?? "")")
                                        that = newRapportFromTo  // 根据需要返回其中一个
                                        d1.leave()
                                    } else {
                                        print("创建失败: \(error?.localizedDescription ?? "")")
                                    }
                                }
                            }
                            
                            d1.notify(queue: .main) {
                                let numdic = that?["numOfQuestionToHim"] as! [String : Int]
                                var num = numdic[user!.objectId!]
                                num = num! + 1
                                that?.setObject([user!.objectId! : num] , forKey: "numOfQuestionToHim")
                                gp2.enter()
                                that?.saveInBackground{ (success, error) in
                                    if success {
                                        print("numOfQuestionToHim saved")
                                        
                                        PFCloud.callFunction(inBackground: "sendTiPush", withParameters: ["someId": user?.objectId, "someName": PFUser.current()!.username]) {
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
                userQuery.whereKey("username", equalTo: concatId)
                
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
                    print("Calling searchUsers Cloud Function with username: \(concatId)")
                    
                    do {
                        let result = try PFCloud.callFunction("searchUsers", withParameters: ["username": concatId]) as? [PFObject]
                        guard let users = result, let user = users.first as? PFUser else {
                            print("No user found with username: \(concatId)")
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
                    print("传入云函数friendReqApprove的userId: \(userId)")
                    
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
                    
                    // 更新好友请求列表
                    //                    var list = PFUser.current()!["friendReqList"] as! [PFObject]
                    
                    //                    for i in stride(from: list.count - 1, through: 0, by: -1) {
                    //                        if foundUser?.objectId == list[i].objectId {
                    //                            list.remove(at: i)
                    //                            break
                    //                        }
                    //                    }
                    
                    for i in stride(from: self.friendReqList.count - 1, through: 0, by: -1) {
                        if (self.friendReqList[i] as! PFObject).objectId == foundUser?.objectId {
                            self.friendReqList.remove(at: i)
                            break
                        }
                    }
                    
                    // 更新用户数据
                    PFUser.current()!.setObject(self.friendReqList, forKey: "friendReqList")
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
                userQuery.whereKey("username", equalTo: concatId)
                
                // 声明一个外部变量保存用户对象，可在整个handler中使用
                var foundUser: PFUser? = nil
                
                // 使用Cloud Function "searchUsers"获取用户
                do {
                    print("Calling searchUsers Cloud Function with username: \(concatId)")
                    
                    do {
                        let result = try PFCloud.callFunction("searchUsers", withParameters: ["username": concatId]) as? [PFObject]
                        guard let users = result, let user = users.first as? PFUser else {
                            print("No user found with username: \(concatId)")
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
                    }
                    
                    // 更新好友请求列表
                    //                    var list = PFUser.current()!["friendReqList"] as! [PFObject]
                    
                    for i in 0 ..< self.friendReqList.count {
                        if foundUser?.objectId == self.friendReqList[i].objectId {
                            self.friendReqList.remove(at: i)
                            break
                        }
                    }
                    
                    // 更新用户数据
                    PFUser.current()!.setObject(self.friendReqList, forKey: "friendReqList")
                    PFUser.current()!.saveEventually()
                    
                    let foundUserId = foundUser?.objectId ?? ""
                    print("传入云函数friendReqReject的 userId: \(foundUserId)")
                    
                    do {
                        let result = try PFCloud.callFunction("friendReqReject", withParameters: [
                            "someId": foundUserId
                        ])
                        print("Friend request rejected: \(String(describing: result))")
                    } catch {
                        print("Error rejecting friend request: \(error.localizedDescription)")
                        self.showErrorAlert(message: "拒绝好友请求时出错，请稍后再试")
                    }
                    
                    // 通知用户
                    self.showSuccessAlert(message: "已拒绝用户 \(foundUser?.username ?? concatId) 的好友请求")
                    
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
