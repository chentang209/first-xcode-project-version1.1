//
//  TableViewController.swift
//  CameraApp
//
//  Created by Hang Yang on 2/24/19.
//  Copyright © 2019 hang yang. All rights reserved.
//

import UIKit
import Parse
import Foundation

var first = true
var bool = true

class TableViewController: UIViewController, avatarDelegate, friendDelegate, viewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var profile: [Avatar] = []
    var wentidic: [String : Any] = [ : ]
    var sender: String!
    
    func reactFriendRequest(bol: Bool) {
        
        bool = bol
        print("\(bool)666")
        //viewDidLoad()
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        let getfBook = storyboard?.instantiateViewController(withIdentifier: "FriendViewController") as! FriendViewController
        //        let getfBook = FriendViewController()
        //        getfBook.friendDelegate = self
        
        navigationItem.hidesBackButton = true
        
        if first {
            
            let alert = UIAlertController(title: "稍等片刻，数据加载中......", message: "", preferredStyle: .alert)
            // 确保视图已添加到窗口层次结构中再显示警告
            if self.view.window != nil {
                self.present(alert, animated: true)
                alert.dismiss(animated: true, completion: {
                    self.tableView.reloadData()
                })
            }
            
            
            first = false
            
        }
        
        
        
        let tu = UIImage(named: "woodbackground")
        if let nav = self.navigationController {
            nav.navigationBar.setBackgroundImage(tu, for: .default)
        }
        
        
        let tempImageView = UIImageView(image: tu)
        tempImageView.frame = self.tableView.frame
        self.tableView.backgroundView = tempImageView
        
        /*
         let add = UIBarButtonItem(image: UIImage(named: "givequestion")!.withRenderingMode(.alwaysOriginal), landscapeImagePhone: UIImage(named: "givequestion")!.withRenderingMode(.alwaysOriginal), style: .plain,  target: self, action: #selector(addTapped))
         */
        
        guard let image = UIImage(named: "givequestion") else {
            print("名为givequestion的图片资源未找到")
            return
        }
        
        
        let add = UIBarButtonItem(image: image.withRenderingMode(.alwaysOriginal), landscapeImagePhone: image.withRenderingMode(.alwaysOriginal), style:.plain, target: self, action: #selector(addTapped))
        //   这样在图片资源不存在时，能更优雅地处理，避免程序崩溃。
        
        let search = UIBarButtonItem(title: "🔍好友", style: .plain, target: self, action: #selector(searchTapped))
        let logout = UIBarButtonItem(title: "登出", style: .plain, target: self, action: #selector(logoutTapped))
        
        navigationItem.rightBarButtonItems = [logout, add, search]
        
        search.imageInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0, right: -70)
        add.imageInsets = UIEdgeInsets(top: 0.0, left: 35, bottom: 0, right: 25)
        logout.imageInsets = UIEdgeInsets(top: 0.0, left: -55, bottom: 0, right: 0)
        
        createArray()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        print("will")
        self.tableView.reloadData()
        if let nav = self.navigationController {
            nav.navigationBar.setBackgroundImage(UIImage(named: "wood2"), for: .default)
        }
        
        
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        print("did")
        //self.tableView.reloadData()
        appendArray()
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        if let nav = self.navigationController {
            nav.navigationBar.setBackgroundImage(UIImage(named: "white"), for: .default)
        }
        
        
    }
    
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    
    @objc func addTapped(sender: UITapGestureRecognizer) {
        
        // 安全获取当前用户，避免强制解包导致的崩溃
        guard let current = PFUser.current() else {
            print("错误: 当前无用户登录或Parse服务器连接问题")
            let alert = UIAlertController(title: "登录状态异常", message: "请重新登录后再试", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { _ in
                self.performSegue(withIdentifier: "logoutSegue", sender: self)
            }))
            // 确保当前视图已经加载到视图层次结构中
            if self.view.window != nil {
                self.present(alert, animated: true)
            }
            
            
            return
        }
        
        
        
        guard let friendList = current["friendList"] as? [PFObject] else {
            print("获取好友列表失败")
            return
        }
        
        
        
        if friendList.count == 0 {
            let alert = UIAlertController(title: "请添加好友", message: "", preferredStyle: .alert)
            // 确保当前视图已经加载到视图层次结构中
            if self.view.window != nil {
                self.present(alert, animated: true)
                alert.dismiss(animated: true) { [weak self] in
                    guard let self = self else { return }
                    
                    // 确保在提示消失后正确跳转
//                    if friendList.count == 0 {
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                            self.performSegue(withIdentifier: "chutiSegue", sender: self)
//                        }
//                    }
                    
                    self.profile[0].bool = bool
                    self.tableView.reloadData()
                }
            }
        } else {
            performSegue(withIdentifier: "chutiSegue", sender: self)
        }
    }
    
    
    
    @objc func searchTapped(sender: UITapGestureRecognizer) {
        self.performSegue(withIdentifier: "searchSegue", sender: self)
    }
    
    
    
    @objc func logoutTapped(sender: UITapGestureRecognizer) {
        
        let alert = UIAlertController(title: "确定退出账户吗?", message: "", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { action in
            
            PFUser.logOut()
            
            self.performSegue(withIdentifier: "logoutSegue", sender: self)
        }))
        
        alert.addAction(UIAlertAction(title: "再等会", style: .cancel, handler: nil
                                     ))
        
        // 确保当前视图已经加载到视图层次结构中
        if self.view.window != nil {
            self.present(alert, animated: true)
        }
        
        
    }
    
    
    
    func createArray() {
        
        guard let target = PFUser.current() else {
            print("错误: 当前无用户登录或Parse服务器连接问题")
            // 显示错误提示
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "登录状态异常", message: "请重新登录后再试", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { _ in
                    self.performSegue(withIdentifier: "logoutSegue", sender: self)
                }))
                // 确保当前视图已经加载到视图层次结构中
                if self.view.window != nil {
                    self.present(alert, animated: true)
                }
                
                
            }
            
            
            return
        }
        
        
        
        guard let username = target["username"] else {
            // 处理不存在 "username" 键的情况
            print("用户名不存在")
            return
        }
        
        
        // 在这里使用 username
        
        var img: UIImage!
        var ziji: Avatar!
        let group = DispatchGroup()
        
        //        group.enter()
        //        (file as! PFFileObject).getDataInBackground {
        //            (data: Data?, error: Error?) -> Void in
        //            print(error?.localizedDescription)
        //            img = UIImage(data: data!)!
        //            group.leave()
        //        }
        
        
        
        group.enter()
        // 安全地获取用户头像
        if let userPicture = target.value(forKey: "avatar") as? PFFileObject {
            userPicture.getDataInBackground(block: {
                (imageData, error) -> Void in
                if error == nil, let imageData = imageData {
                    img = UIImage(data: imageData)
                } else {
                    print(error?.localizedDescription ?? "未知错误")
                    print("wawawwawaw")
                }
                
                
                group.leave()
            })
        } else {
            print("用户头像获取失败")
            group.leave()
        }
        
        
        
        group.notify(queue: .main){
            // 安全检查，确保img不为nil
            let defaultImage: UIImage?
            if #available(iOS 13.0, *) {
                defaultImage = UIImage(named: "user") ?? UIImage(systemName: "person.circle")
            } else {
                defaultImage = UIImage(named: "user")
            }
            let usernameStr = (username as? String) ?? "未知用户"
            
            if let validImg = img ?? defaultImage {
                ziji = Avatar(image: validImg, title: usernameStr + "的好友列表", id: "", bool: bool)
                self.profile.append(ziji)
                self.tableView.reloadData()
            } else {
                print("错误: 无法获取用户图像")
                let alert = UIAlertController(title: "数据加载失败", message: "无法获取用户信息，请重试", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "重试", style: .default) { _ in
                    self.createArray()
                })
                if self.view.window != nil {
                    self.present(alert, animated: true)
                }
            }
            
            
        }
        
        
        
    }
    
    
    
    func appendArray() {
        
        print("appendArray")
        let qe = PFQuery(className: "JoinTable")
        // 安全获取当前用户，避免强制解包导致的崩溃
        guard let currentUser = PFUser.current() else {
            print("错误: 当前无用户登录或Parse服务器连接问题")
            // 无用户时返回空结果
            return
        }
        
        
        qe.whereKey("to", equalTo: currentUser)
        qe.findObjectsInBackground{ (objs:[PFObject]?, err:Error?) in
            
            print(err?.localizedDescription as Any)
            print(111111111)
            
            if let objs = objs {
                print(22222)
                if self.profile.count == 0 {
                    print(3333333)
                    let alert = UIAlertController(title: "稍等片刻，数据加载中......", message: "", preferredStyle: .alert)
                    // 确保视图已添加到窗口层次结构中再显示警告
                    if self.view.window != nil {
                        self.present(alert, animated: true)
                        let when = DispatchTime.now() + 3
                        DispatchQueue.main.asyncAfter(deadline: when){
                            alert.dismiss(animated: true)
                            self.tableView.reloadData()
                        }
                    }
                    
                } else {
                    print(44444)
                    self.profile[0].bool = bool
                    let first = self.profile[0]
                    self.profile.removeAll()
                    self.profile.append(first)
                    
                    for o in objs {
                        print(555555555)
                        if o["request"] == nil {
                            print(6666666)
                            guard let dic = o["question"] as? [String: Any] else {
                                // Handle error case and return/throw
                                return
                            }
                            // Use dic here
                            let sender_name = dic["self_name"] as? String
                            let idd = o.objectId
                            self.wentidic.updateValue(dic, forKey: idd!)
                            
                            let op1 = dic["op1"] as? String
                            let title = sender_name! + " : " + op1! + "......"
                            let self_icon = dic["self_icon"]
                            var pic_data: Data?
                            print(77777777)
                            if let base64String = self_icon as? String {
                                print(88888888)
                                // 老数据，Base64 字符串
                                pic_data = Data(base64Encoded: base64String, options: [])
                                // pic_data 就是图片二进制
                            } else if let file = self_icon as? PFFileObject {
                                print(999999)
                                // 新数据，PFFileObject，同步获取
                                do {
                                    print(5738478)
                                    pic_data = try file.getData()
                                    // pic_data 就是图片二进制
                                } catch {
                                    print("获取PFFileObject数据失败: \(error)")
                                }
                            }
                            print(07844534)
                            let tou = UIImage(data: pic_data! as Data)
                            
                            self.profile.append(Avatar(image: tou!, title: title, id: idd as! String, bool: bool))
                            self.tableView.reloadData()
                            
                        }
                    }
                }
            }
        }
        // self.tableView.reloadData()
    }
}



extension TableViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        NotificationCenter.default.post(name: .userDidInteract, object: nil)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        NotificationCenter.default.post(name: .userDidInteract, object: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profile.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let profilerx = self.profile[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AvatarCell") as! AvatarCell
        
        cell.delegate = self
        
        // 安全获取当前用户，避免强制解包导致的崩溃
        guard let ziji = PFUser.current(), let str = ziji["username"] as? String else {
            print("错误: 当前无用户登录或Parse服务器连接问题")
            // 如果用户未登录，返回一个普通单元格
            return cell
        }
        
        
        
        if (profilerx.title) == str + "的好友列表" {
            
            cell.setAvatar1(profile: profilerx)
            
        } else {
            
            cell.setAvatar2(rx: profilerx)
            
        }
        
        
        
        return cell
    }
    
    
    
    func reddot(bol: String) {
        
        print("0000000000000")
        
        if bol != "false" {
            bool = false
            print(bool)
        } else {
            bool = true
            print(bool)
        }
        
        
        
    }
    
    
    
    func redot(bol: String) {
        
        print("1111111111111111g")
        
        if bol != "false" {
            bool = false
            print(bool)
        } else {
            bool = true
            print(bool)
        }
        
        
        
    }
    
    
    
    func avatarDelegate(title: String, id: String) {
        
        // 安全获取当前用户，避免强制解包导致的崩溃
        guard let ziji = PFUser.current(), let str = ziji["username"] as? String else {
            print("错误: 当前无用户登录或Parse服务器连接问题")
            return
        }
        
        
        
        if title == str + "的好友列表" {
            performSegue(withIdentifier: "friendList", sender: self)
        } else {
            sender = id
            performSegue(withIdentifier: "answerSegue", sender: self)
        }
        
        
        
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is FriendViewController
        {
            let vc = segue.destination as? FriendViewController
            vc?.cond = true
            vc?.friendDelegate = self
            let backItem = UIBarButtonItem()
            backItem.title = "返回"
            navigationItem.backBarButtonItem = backItem
        }
        
        
        
        if segue.destination is AnswerViewController
        {
            let vc = segue.destination as? AnswerViewController
            let objectId = self.sender
            print("1: " + objectId!)
            vc?.dict = wentidic[objectId!] as! [String : Any]
            vc?.objectId = objectId
        }
        
        
        
        if segue.destination is ButtonViewController
        {
            let backItem = UIBarButtonItem()
            backItem.title = "返回"
            navigationItem.backBarButtonItem = backItem
        }
        
        
    }
    
    
    
}
