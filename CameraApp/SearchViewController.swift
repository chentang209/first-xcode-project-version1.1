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
        let query = PFUser.query()
        query?.whereKey("username", equalTo: searchText)
        query?.findObjectsInBackground(block: { (objects:[PFObject]?, error: Error?) in
       
            if (error == nil) {
                self.userObj = objects?.first
            } else {
                print(error as Any)
                self.searching = false
            }
            
            group.leave()
        })
        
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
        
        if searching{
            var array: [String] = []
            var con = true
            
            let list = PFUser.current()!["friendList"] as! [PFObject]
            
            for o in list {
                let ta = o.objectId
                let qt = PFUser.query()
                qt?.whereKey("objectId", equalTo: ta)
                let oo = try! qt?.getFirstObject()
                let na = oo!["username"] as! String
                array.append(na)
            }
            
            for o in array {
                if o == name {
                    con = false
                }
            }
            
            if con {
                
                let str = PFUser.current()!["username"] as! String
                
                if name != str {
                    
                    let alert = UIAlertController(title: "是否添加该用户为好友", message: "", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "是", style: .cancel, handler: {action in
                        
                        let current = PFUser.current()
                        let friendList = current!["friendList"] as! [PFObject]
                        self.arrayUserObj = friendList
                        self.arrayUserObj.append(self.userObj)
                        let user = PFUser.current()!
                        user.setObject(self.arrayUserObj, forKey: "friendList")
                        
                        user.saveInBackground{(success, error) in
                            if success {
                                let alert = UIAlertController(title: "添加成功！", message: "", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "知道了", style: .default, handler: nil))
                                self.present(alert, animated: true)
                                print("friendlist saved")
                            } else {
                                if let error = error {
                                    print(error)
                                } else {
                                    print("Error")
                                }
                            }
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
            
        }
    
    }
    
}


