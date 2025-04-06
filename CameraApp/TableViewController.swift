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
            self.present(alert, animated: true)
            let when = DispatchTime.now() + 3
            DispatchQueue.main.asyncAfter(deadline: when){
                alert.dismiss(animated: true)
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
        
        let add = UIBarButtonItem(image: UIImage(named: "givequestion")!.withRenderingMode(.alwaysOriginal), landscapeImagePhone: UIImage(named: "givequestion")!.withRenderingMode(.alwaysOriginal), style: .plain,  target: self, action: #selector(addTapped))
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
        
        let current = PFUser.current()
        let friendList = current!["friendList"] as! [PFObject]
        
        if friendList.count == 0 {
            let alert = UIAlertController(title: "请添加好友", message: "", preferredStyle: .alert)
            self.present(alert, animated: true)
            let when = DispatchTime.now() + 1
            DispatchQueue.main.asyncAfter(deadline: when){
                alert.dismiss(animated: true)
            }
        }
        else {
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
        
        self.present(alert, animated: true)
    }
    
    func createArray() {
        
        let target = PFUser.current()
        //print(target!["username"])
        //let file = target!["avatar"]
        let username = target!["username"]
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
        if let userPicture = target!.value(forKey: "avatar")! as? PFFileObject {
            userPicture.getDataInBackground(block: {
                (imageData, error) -> Void in
                if (error == nil) {
                    img = UIImage(data:imageData!)
                } else {
                    print(error?.localizedDescription)
                    print("wawawwawaw")
                }
                group.leave()
            })
        }
        
        group.notify(queue: .main){
            
            ziji = Avatar(image: img, title: (username as! String) + "的好友列表", id: "", bool: bool)
            self.profile.append(ziji)
            self.tableView.reloadData()
        
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
            
            if let objs = objs {
                
                if self.profile.count == 0 {
                   
                    let alert = UIAlertController(title: "稍等片刻，数据加载中......", message: "", preferredStyle: .alert)
                    self.present(alert, animated: true)
                    let when = DispatchTime.now() + 3
                    DispatchQueue.main.asyncAfter(deadline: when){
                        alert.dismiss(animated: true)
                    }
                    
                } else {
                    
                    self.profile[0].bool = bool
                    let first = self.profile[0]
                    self.profile.removeAll()
                    self.profile.append(first)
                    
                    for o in objs {
                       
                        if o["request"] == nil {
                            
                            let dic = o["question"] as! [String : String]
                            let sender_name = dic["self_name"]
                            let idd = o.objectId
                            self.wentidic.updateValue(dic, forKey: idd!)
                        
                            let op1 = dic["op1"]
                            let title = sender_name! + " : " + op1! + "......"
                            let self_icon = dic["self_icon"]
                            let pic_data = NSData(base64Encoded: self_icon!, options: [])
                            let tou = UIImage(data: pic_data! as Data)
                        
                            self.profile.append(Avatar(image: tou!, title: title, id: idd as! String, bool: bool))
                            self.tableView.reloadData()
                
                        }
                        
                    }
                    
                }
                
            }
               
        }
        
        self.tableView.reloadData()
    
    }
   
}

extension TableViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profile.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let profilerx = self.profile[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AvatarCell") as! AvatarCell
        
        cell.delegate = self
        
        let ziji = PFUser.current()
        let str = ziji!["username"]
        
        if (profilerx.title) == (str as! String) + "的好友列表" {

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
       
        let ziji = PFUser.current()
        let str = ziji!["username"] as! String
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
            vc?.dict = wentidic[objectId!] as! [String : String]
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
