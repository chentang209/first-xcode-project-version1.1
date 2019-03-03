//
//  TableViewController.swift
//  CameraApp
//
//  Created by Hang Yang on 2/24/19.
//  Copyright © 2019 hang yang. All rights reserved.
//

import UIKit
import Parse

var first = true

class TableViewController: UIViewController, avatarDelegate {

    @IBOutlet weak var tableView: UITableView!
    var profile : [Avatar] = []
    //var rxquestions = [Avatar]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        
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
        self.navigationController!.navigationBar.setBackgroundImage(tu, for: .default)
        let tempImageView = UIImageView(image: tu)
        tempImageView.frame = self.tableView.frame
        self.tableView.backgroundView = tempImageView
        
        let add = UIBarButtonItem(image: UIImage(named: "givequestion")!.withRenderingMode(.alwaysOriginal), landscapeImagePhone: UIImage(named: "givequestion")!.withRenderingMode(.alwaysOriginal), style: .plain,  target: self, action: #selector(addTapped))
        let search = UIBarButtonItem(title: "Search", style: .plain, target: self, action: #selector(searchTapped))
        let logout = UIBarButtonItem(title: "Log out", style: .plain, target: self, action: #selector(logoutTapped))
        
        navigationItem.rightBarButtonItems = [logout, add, search]
        
        search.imageInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0, right: -70);
        add.imageInsets = UIEdgeInsets(top: 0.0, left: 35, bottom: 0, right: 25);
        logout.imageInsets = UIEdgeInsets(top: 0.0, left: -55, bottom: 0, right: 0);
        
        createArray()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(named: "wood2"), for: .default)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(named: "white"), for: .default)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @objc func addTapped(sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "chutiSegue", sender: self)
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
        let file = target!["avatar"]
        let username = target!["username"]
        var img: UIImage!
        var ziji: Avatar!
      
        let group = DispatchGroup()
        group.enter()
        
        (file as! PFFileObject).getDataInBackground {
            (data: Data?, error: Error?) -> Void in
            img = UIImage(data: data!)!
           
            ziji = Avatar(image: img, title: (username as! String) + "的好友列表")
            self.profile.append(ziji)
            self.tableView.reloadData()
            
            //let nowDate = DispatchTime.now()
            //print(nowDate)
            
            let qe = PFQuery(className: "JoinTable")
            qe.whereKey("to", equalTo: PFUser.current()!)
            qe.findObjectsInBackground{ (objs:[PFObject]?, err:Error?) in
                
                print(err?.localizedDescription)
                
                if let objs = objs {
                    
                    for o in objs{
                        print("pao")
                        let dic = o["question"] as! [String : String]
                        let sender_name = dic["self_name"]
                        //let sender = o["from"] as! PFUser
                        //let id = sender.objectId
                        //let qq = PFUser.query()
                        //qq?.whereKey("objectId", equalTo: id)
                        //let user = try! qq?.getFirstObject()
                        //let name = user!["username"] as! String
                        //print(name)
                        let op1 = dic["op1"]
                        let title = sender_name! + " : " + op1! + "......"
                        let self_icon = dic["self_icon"]
                        let pic_data = NSData(base64Encoded: self_icon!, options: [])
                        let tou = UIImage(data: pic_data as! Data)
                        
                        //let file = user!["avatar"]
                        //let group = DispatchGroup()
                        //group.enter()
                        
                        //(file as! PFFileObject).getDataInBackground {
                        //    (data: Data?, error: Error?) -> Void in
                        //    img = UIImage(data: data!)!
                        //    group.leave()
                        //}
                        
                        //group.notify(queue: .main) {
                          //  print("add")
                          //  ziji = Avatar(image: img, title: title)
                          //  self.profile.append(ziji)
                        self.profile.append(Avatar(image: tou!, title: title))
                        self.tableView.reloadData()
                        //}
                        
                    }
                    
                }
               
            }
            
            group.leave()
            
        }
        
        group.notify(queue: .main) {
            print(self.profile.count)
        }
            
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
        
        if (profilerx.title as! String) == (str as! String) + "的好友列表" {

            cell.setAvatar1(profile: profilerx)
        
        } else {
        
            cell.setAvatar2(rx: profilerx)
            
        }
        
        return cell
    }
    
    func avatarDelegate(title: String) {
        
        let ziji = PFUser.current()
        let str = ziji!["username"] as! String
        if title == str + "的好友列表" {
            performSegue(withIdentifier: "friendList", sender: self)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is FriendViewController
        {
            let vc = segue.destination as? FriendViewController
            vc?.cond = true
        }
    }
    
}
