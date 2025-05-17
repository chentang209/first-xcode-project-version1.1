//
//  SearchViewController.swift
//  CameraApp
//
//  Created by Hang Yang on 2/25/19.
//  Copyright © 2019 hang yang. All rights reserved.
//

import UIKit
import Parse

class SearchViewController: UIViewController, UIGestureRecognizerDelegate, myTableDelegate {

    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var userObj: PFObject!
    var searching = false
    var arrayUserObj: [PFObject] = []
    var flag: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tblView.delegate = self
        tblView.dataSource = self
        searchBar.delegate = self
    }
    
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        let group = DispatchGroup()
        group.enter()
        print(searchText)
        
//        let query = PFUser.query()
//        query?.whereKey("username", equalTo: searchText)
//        query?.findObjectsInBackground(block: {(objects:[PFObject]?, error: Error?) in
//       
//            if (error == nil) {
//                self.userObj = objects?.first
//            } else {
//                print(error as Any)
//                self.searching = false
//            }
//            
//            group.leave()
//        
//        })
        
        // ✅ 正确做法：通过 Cloud Function 间接查询
        PFCloud.callFunction(inBackground: "searchUsers",
                             withParameters: ["username": searchText]) {
          (results, error) in
          if let error = error {
            print("搜索用户出错: \(error.localizedDescription)")
            self.userObj = nil
            group.leave()
            return
          }
          
          if let users = results as? [PFObject], !users.isEmpty {
            self.userObj = users.first
          } else {
            self.userObj = nil
          }
          group.leave()
        }
        
        group.notify(queue: .main) {
            
            if self.userObj == nil {
                self.searching = false
            } else {
                self.searching = true
            }
            self.tblView.reloadData()
        }
       
    }
   
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        self.searching = false
        self.tblView.reloadData()
    }

}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IconCell") as! IconCell

        if searching {
            
            cell.delegate = self
            let target = userObj
            let file = target!["avatar"]
            let username = target!["username"]
            var img: UIImage!
       
            let group = DispatchGroup()
            group.enter()
        
            (file as! PFFileObject).getDataInBackground {
                (data: Data?, error: Error?) -> Void in
            
                img = UIImage(data: data!)!
            
                group.leave()
            }
            
            group.notify(queue: .main) {
                
                cell.setAvatar(username: username as! String, icon: img, search: self.searching)
                
                let alert = UIAlertController(title: "点击结果栏添加", message: "", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "知道了", style: .default, handler: nil))
                
                self.present(alert, animated: true)
                
            }
            
        } else {
            
            cell.setAvatar(username: "", icon: UIImage(), search: self.searching)
        
        }
        
        return cell
        
    }
    
    func myTableDelegate(name: String) {
        
        if searching {
            
            var con = true
            var array: [String] = []

            let list = PFUser.current()!["friendList"] as! [PFObject]

            for o in list {
                
                let ta = o.objectId
                // let qt = PFUser.query()
                // qt?.whereKey("objectId", equalTo: ta)
                do {
                    let result = try PFCloud.callFunction("searchUsers", withParameters: ["userId": ta]) as? [PFUser]
                    
                    // let oo = try! qt?.getFirstObject()
                    guard let userObjects = result as? [PFObject], let user = userObjects.first as? PFUser else {
                        print("Error: 没有找到用户名为\(ta)的用户")
                        print("Received result type: \(type(of: result))")
                        print("Result description: \(String(describing: result))")
                        
                        throw NSError(domain: "UserNotFound", code: 404, userInfo: nil)
                    }
                    let na = user["username"] as! String
                    array.append(na)
                } catch {
                    print("Cloud function error: \(error.localizedDescription)")
                }
            
            }

            for o in array {

                if o == name {

                    con = false

                }

            }
            
//            let qt = PFUser.query()
//            let gp1 = DispatchGroup()
//            qt?.whereKey("username", equalTo: name)
//            let oo = try! qt?.getFirstObject()
//            let pfQuery = PFQuery(className: "JoinTable")
//            pfQuery.whereKey("to", equalTo: PFUser.current())
//            pfQuery.whereKey("from", equalTo: oo)
//            pfQuery.whereKey("request", equalTo: "approverequest")
//            //gp1.enter()
//            pfQuery.findObjectsInBackground( block:{(objs,err) in
//
//                if objs?.count != 0 {
//
//                    con = true
//
//                }
//
//              //  gp1.leave()
//
//            })
//
//            pfQuery.whereKey("from", equalTo: PFUser.current())
//            pfQuery.whereKey("to", equalTo: oo)
//            pfQuery.whereKey("request", equalTo: "approverequest")
//            //gp1.enter()
//            pfQuery.findObjectsInBackground( block:{(objs,err) in
//
//                if objs?.count != 0 {
//
//                    con = true
//
//                }
//
//              //  gp1.leave()
//
//            })
//
//           // gp1.notify(queue: .main) {
            
                if con {
                    
                    let str = PFUser.current()!["username"] as! String
                    
                    if name != str {
                        
                        let alert = UIAlertController(title: "是否添加该用户为好友", message: "", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "是", style: .cancel, handler: {action in
                            
                            let dgroup = DispatchGroup()
                            let tableQuery = PFQuery(className: "JoinTable")
                            
                            tableQuery.whereKey("to", equalTo: PFUser.current())
                            tableQuery.whereKey("request", equalTo: "sendrequest")
                            
                            dgroup.enter()
                            tableQuery.findObjectsInBackground(block: { (objs, err) in
                                
                                if let objs = objs {
                                    
                                    for obj in objs {
                                        
                                        if (obj["from"] as! PFUser).objectId  ==  self.userObj.objectId {
                                            
                                            self.flag = true
                                            let alert = UIAlertController(title: "你已接收到对方的好友请求", message: "", preferredStyle: .alert)
                                            self.present(alert, animated: true)
                                            let when = DispatchTime.now() + 2
                                            DispatchQueue.main.asyncAfter(deadline: when) {
                                                
                                                alert.dismiss(animated: true)
                                                
                                            }
                                            
                                        }
                                        
                                    }
                                    
                                }
                                
                                dgroup.leave()
                                
                            })
                            
                            dgroup.notify(queue: .main) {
                                
                                let tableQuery = PFQuery(className: "JoinTable")
                                
                                tableQuery.whereKey("from", equalTo: PFUser.current())
                                tableQuery.whereKey("to", equalTo: self.userObj)
                                tableQuery.whereKeyExists("request")
                                
                                tableQuery.findObjectsInBackground(block: { (objs, err) in
                                    
                                    if objs?.first != nil {
                                        
                                        print(objs?.first!["request"] as! String)
                                        
                                        if objs?.first!["request"] as! String == "sendrequest" {
                                            
                                            let alert = UIAlertController(title: "你已经给该用户发送过请求", message: "", preferredStyle: .alert)
                                            self.present(alert, animated: true)
                                            let when = DispatchTime.now() + 2
                                            DispatchQueue.main.asyncAfter(deadline: when) {
                                                
                                                alert.dismiss(animated: true)
                                                
                                            }
                                            
                                        } else if objs?.first!["request"] as! String == "approverequest" {
                                            
                                            let alert = UIAlertController(title: "你发送的请求已经被通过", message: "", preferredStyle: .alert)
                                            self.present(alert, animated: true)
                                            let when = DispatchTime.now() + 2
                                            DispatchQueue.main.asyncAfter(deadline: when) {
                                                
                                                alert.dismiss(animated: true)
                                                
                                            }
                                            
                                        } else {
                                            
                                            let alert = UIAlertController(title: "好友请求已发送！", message: "", preferredStyle: .alert)
                                            self.present(alert, animated: true)
                                            
                                            let joinTable = PFObject(className: "JoinTable")
                                            
                                            joinTable.setObject("sendrequest" , forKey: "request")
                                            joinTable.setObject(self.userObj as Any, forKey: "to")
                                            joinTable.setObject(PFUser.current() as Any, forKey: "from")
                                            let groupACL = PFACL()
                                            groupACL.setReadAccess(true, for: self.userObj as! PFUser)
                                            groupACL.setReadAccess(true, for: PFUser.current()!)
                                            groupACL.setWriteAccess(true, for: self.userObj as! PFUser)
                                            joinTable.acl = groupACL
                                            
                                            let gp11 = DispatchGroup()
                                            
                                            gp11.enter()
                                            joinTable.saveInBackground{(success, error) in
                                                
                                                if success {
                                                    
                                                    gp11.leave()
                                                    
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
                                                
                                                gp11.notify(queue: .main) {
                                                    
                                                    alert.dismiss(animated: true)
                                                    
                                                }
                                                
                                                PFCloud.callFunction(inBackground: "friendReqPush", withParameters: [
                                                    "someId": self.userObj.objectId ?? "",
                                                    "someName": PFUser.current()?["username"] ?? ""
                                                ]) { (result, error) in
                                                    if let error = error {
                                                        print("[Cloud] 发送好友申请通知失败: \(error.localizedDescription)")
                                                    } else {
                                                        print("[Cloud] 好友申请通知已发送: \(String(describing: result))")
                                                    }
                                                }
                                                
                                            }
                                            
                                        }
                                        
                                    } else {
                                        
                                        if self.flag != true {
                                            
                                            let alert = UIAlertController(title: "好友请求已发送！", message: "", preferredStyle: .alert)
                                            self.present(alert, animated: true)
                                            
                                            let joinTable = PFObject(className: "JoinTable")
                                            
                                            joinTable.setObject("sendrequest" , forKey: "request")
                                            joinTable.setObject(self.userObj as Any, forKey: "to")
                                            joinTable.setObject(PFUser.current() as Any, forKey: "from")
                                            let groupACL = PFACL()
                                            groupACL.setReadAccess(true, for: self.userObj as! PFUser)
                                            groupACL.setReadAccess(true, for: PFUser.current()!)
                                            groupACL.setWriteAccess(true, for: self.userObj as! PFUser)
                                            joinTable.acl = groupACL
                                            
                                            let gp11 = DispatchGroup()
                                            
                                            gp11.enter()
                                            joinTable.saveInBackground{(success, error) in
                                                
                                                if success {
                                                    
                                                    gp11.leave()
                                                    
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
                                                
                                                gp11.notify(queue: .main) {
                                                    
                                                    alert.dismiss(animated: true)
                                                    
                                                }
                                                
                                                PFCloud.callFunction(inBackground: "friendReqPush", withParameters: ["someId": self.userObj.objectId , "someName":PFUser.current()!["username"]]) {(result, error) in
                                                    
                                                    if (error == nil) {
                                                        print(result)
                                                    } else {
                                                        print(error?.localizedDescription)
                                                    }
                                                    
                                                }
                                                
                                            }
                                            
                                        }
                                        
                                    }
                                    
                                })
                                
                            }
                            
                        }))
                        
                        alert.addAction(UIAlertAction(title: "否", style: .default, handler: nil))
                        
                        self.present(alert, animated: true)
                        
                    } else {
                        
                        let alert = UIAlertController(title: "不能添加自己为好友", message: "", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "知道了", style: .default, handler: nil))
                        self.present(alert, animated: true)
                        
                    }
                    
                } else {
                    
                    let alert = UIAlertController(title: "你已经添加过该好友", message: "", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "知道了", style: .default, handler: nil))
                    self.present(alert, animated: true)
                    
                }
                
            //}
        
        }
    
    }
    
}


