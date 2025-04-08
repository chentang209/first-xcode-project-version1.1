//
//  ViewController.swift
//  CameraApp
//
//  Created by Hang Yang on 2/24/19.
//  Copyright © 2019 hang yang. All rights reserved.
//

import UIKit
import Parse

protocol viewDelegate {
    func redot(bol: String)
}

class ViewController: UIViewController {

    var user: PFUser!
    var viewDelegate: viewDelegate!
    var friendReqList: [PFObject] = []
    var tableViewController = TableViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        
        // 安全获取当前用户，避免强制解包导致的崩溃
        guard let currentUser = PFUser.current() else {
            print("错误: 当前无用户登录或Parse服务器连接问题")
            // 可以在这里添加提示用户登录的代码或返回登录页面
            return
        }
        
        user = currentUser
        let qe = PFQuery(className: "JoinTable")
        qe.whereKey("to", equalTo: currentUser)
        qe.whereKey("request", equalTo: "sendrequest")
        
        // 使用do-catch处理查询错误，避免强制try导致的崩溃
        var obj: PFObject? = nil
        do {
            obj = try qe.findObjects().first
        } catch {
            print("查询失败: \(error.localizedDescription)")
        }
        
        if obj != nil {
            
            let sender = obj!["from"] as! PFUser
            
            self.friendReqList.append(sender)
            user.setObject(self.friendReqList, forKey: "friendReqList")
            let group = DispatchGroup()
            group.enter()
            do {
                user.saveEventually()
                group.leave()
            }
            
            group.notify(queue: .main) {
                
                self.viewDelegate = self.tableViewController
                self.viewDelegate.redot(bol: "false")
                let friendReqList = self.user["friendReqList"] as! [PFObject]
                if friendReqList.count != 0 {
                    
                    print("kkkkklllll")
                    self.viewDelegate.redot(bol: "true")
                    
                }
                
            }
        
        }
        
        // 安全获取当前安装信息并保存
        if let pfi = PFInstallation.current() {
            pfi.setObject(user, forKey: "user")
            pfi.setObject(0, forKey: "badge")
            
            // 使用do-catch处理保存错误
            do {
                try pfi.save()
            } catch {
                print("保存安装信息失败: \(error.localizedDescription)")
            }
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        NotificationCenter.default.post(name: .userDidInteract, object: nil)
    }
}
