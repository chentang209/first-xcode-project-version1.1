//
//  FriendViewController.swift
//  CameraApp
//
//  Created by Hang Yang on 3/1/19.
//  Copyright © 2019 hang yang. All rights reserved.
//

import UIKit
import Parse

class FriendViewController: UIViewController, tableDelegate {

    @IBOutlet weak var tableView: UITableView!
    var friendList: [PFObject] = []
    var store = [String: AnyObject]()
    var newdict = [String: String]()
    var afterchuti = false
    var cond = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

        let current = PFUser.current()
        friendList = current!["friendList"] as! [PFObject]
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
                
                let his_id = id
                let query = PFUser.query()
                query?.whereKey("username", equalTo: his_id)
                query?.findObjectsInBackground(block: { (objects: [PFObject]?, error: Error?) in
                    
                    if(error == nil){
                        
                        let user = objects?.first
                        let current = PFUser.current()
                        let groupACL = PFACL()
                        
                        groupACL.setReadAccess(true, for:user as! PFUser)
                        
                        let joinTable = PFObject(className: "JoinTable")
                        let question = self.newdict
                        joinTable.acl = groupACL
                        joinTable.setObject(question , forKey: "question")
                        joinTable.setObject(user as Any, forKey: "to")
                        joinTable.setObject(current as Any, forKey: "from")
                        
                        joinTable.saveInBackground{(success, error) in
                            if success {
                                print("table saved")
                                let alert = UIAlertController(title: "发送完毕！", message: "", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "好👌", style: .default, handler: { action in
                                    self.performSegue(withIdentifier: "finishSendTi", sender: self)
                                }))
                                self.present(alert, animated: true)
                            } else {
                                if let error = error {
                                    print(error)
                                } else {
                                    print("table error")
                                }
                            }
                        }
                        
                    }
                    
                })
                
            }))
            
            alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil
            ))
            
            self.present(alert, animated: true)
        }
    }
    
}
