//
//  FriendViewController.swift
//  CameraApp
//
//  Created by Hang Yang on 3/1/19.
//  Copyright © 2019 hang yang. All rights reserved.
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
       
        var img: UIImage!
        var fd: PFObject!
        var name: String!
        var file: PFFileObject!
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell") as! FriendCell
        cell.delegate = self
        
        let friend = friendList[indexPath.row]
        let userId = friend.objectId
        
        let profileQuery:PFQuery = PFUser.query()!
        let group = DispatchGroup()
        group.enter()
        profileQuery.getObjectInBackground(withId: userId as! String) { (object: PFObject?, error: Error?) in
            fd = object!
            group.leave()
        }
        
        group.notify(queue: .main) {
            name = (fd["username"] as! String)
            file = (fd["avatar"] as! PFFileObject)
        
            let group2 = DispatchGroup()
            group2.enter()
        
            (file as! PFFileObject).getDataInBackground {
                (data: Data?, error: Error?) -> Void in
                img = UIImage(data: data!)!
                group2.leave()
            }
        
            group2.notify(queue: .main) {
                cell.setAvatar(username: name as! String, icon: img)
            }
        }
        
        return cell
    }
    
    func myTableDelegate(id: String, icon: UIImage) {
        
        if afterchuti {
            
            let alert = UIAlertController(title: "是否把题目发送给该好友?", message: "", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { action in
                
                var f1 = true
                var f2 = true
                let query1 = PFQuery(className: "JoinTable")
                let uquery = PFUser.query()
                let gp = DispatchGroup()
                uquery?.whereKey("username", equalTo: id)
                let target = try! uquery?.getFirstObject()
                query1.whereKey("from", equalTo: PFUser.current())
                query1.whereKey("to", equalTo: target)
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
                query2.whereKey("from", equalTo: target)
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
                        var strBase64 = imageData.base64EncodedString(options: [])
                        self.newdict.updateValue(strBase64 as String, forKey: "pic1")
                        
                        imageData = (self.store["pic2"] as! UIImage).jpegData(compressionQuality: 0)! as NSData
                        strBase64 = imageData.base64EncodedString(options: [])
                        self.newdict.updateValue(strBase64 as String, forKey: "pic2")
                        
                        imageData = (self.store["pic3"] as! UIImage).jpegData(compressionQuality: 0)! as NSData
                        strBase64 = imageData.base64EncodedString(options: [])
                        self.newdict.updateValue(strBase64 as String, forKey: "pic3")
                        
                        imageData = (self.store["pic4"] as! UIImage).jpegData(compressionQuality: 0)! as NSData
                        strBase64 = imageData.base64EncodedString(options: [])
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
                        let his_id = id
                        let query = PFUser.query()
                        query?.whereKey("username", equalTo: his_id)
                        let gp1 = DispatchGroup()
                        gp1.enter()
                        query?.findObjectsInBackground { (objects: [PFObject]?, error1: Error?) in
                            
                            if(error1 == nil) {
                                
                                user = objects?.first
                                let current = PFUser.current()
                                let groupACL = PFACL()
                                
                                groupACL.setReadAccess(true, for: user as! PFUser)
                                groupACL.setWriteAccess(true, for: user as! PFUser)
                                
                                let joinTable = PFObject(className: "JoinTable")
                                let question = self.newdict
                                joinTable.acl = groupACL
                                
                                joinTable.setObject(question , forKey: "question")
                                joinTable.setObject(user as Any, forKey: "to")
                                joinTable.setObject(current as Any, forKey: "from")
                                
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
                                    
                                    PFCloud.callFunction(inBackground: "sendTiPush", withParameters: ["someId": user.objectId , "someName": PFUser.current()!["username"]]) {
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
                
                let tableQuery = PFQuery(className: "JoinTable")
                let userQuery = PFUser.query()
                let acl = PFACL()
                
                userQuery?.whereKey("username", equalTo: id)
                let user = try! userQuery?.findObjects().first
                print(user!["username"])
                tableQuery.whereKey("from", equalTo: user)
                tableQuery.whereKey("to", equalTo: PFUser.current())
                tableQuery.whereKey("request", equalTo: "sendrequest")
                let request = try! tableQuery.findObjects().first as! PFObject
                print(request.objectId)
                request.setObject("approverequest", forKey: "request")
                acl.setReadAccess(true, for: PFUser.current()!)
                acl.setWriteAccess(true, for: PFUser.current()!)
                acl.setReadAccess(true, for: user as! PFUser)
                acl.setWriteAccess(true, for: user as! PFUser)
                request.acl = acl
                request.saveEventually()
                var list = PFUser.current()!["friendReqList"] as! [PFObject]
               
                print(list.count)
                    
                for i in 0 ..< list.count {
                        
                    if user!.objectId == (list[i].objectId) {
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
                    
                    //print((try! PFQuery(className: "JoinTable").getFirstObject())["request"] as! String)
                    print("waahh")
                    PFCloud.callFunction(inBackground: "friendReqApprove", withParameters: ["someId": user!.objectId , "someName": PFUser.current()!["username"]]) {(result, error) in
                        
                        if (error == nil) {
                            print(result)
                        } else {
                            print(error?.localizedDescription)
                        }
                    }
                    
                    print("second")
                    self.viewDidLoad()
                
                }
                
            }))
            
            alert.addAction(UIAlertAction(title: "不同意", style: .cancel, handler: { action in
            
                let tableQuery = PFQuery(className: "JoinTable")
                let userQuery = PFUser.query()
                
                userQuery?.whereKey("username", equalTo: id)
                let user = try! userQuery?.findObjects().first
                
                tableQuery.whereKey("from", equalTo: user)
                tableQuery.whereKey("to", equalTo: PFUser.current())
                tableQuery.whereKey("request", equalTo: "sendrequest")
                
                var list = PFUser.current()!["friendReqList"] as! [PFObject]
                
                for i in 0 ..< list.count {
                    
                    if user!.objectId == (list[i].objectId) {
                     
                        list.remove(at: i)
                        break
                    
                    }
                    
                }
                
                PFUser.current()!.setObject(list, forKey: "friendReqList")
                let group = DispatchGroup()
                
                group.enter()
                
                do {
                    
                    let request = try! tableQuery.findObjects().first as! PFObject
                    request.deleteEventually()
                    PFUser.current()!.saveEventually()
                    
                    group.leave()
                    
                }
                
                group.notify(queue: .main) {
                    
                    PFCloud.callFunction(inBackground: "friendReqReject", withParameters: ["someId": user!.objectId , "someName": PFUser.current()!["username"]]) {(result, error) in
                        
                        if (error == nil) {
                            print(result)
                        } else {
                            print(error?.localizedDescription)
                        }
                    }
                    
                    print("sec")
                    self.viewDidLoad()
                    
                }
                
            }))
            
            self.present(alert, animated: true)
            
        }
    
    }
    
}
