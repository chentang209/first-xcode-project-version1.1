//
//  SearchViewController.swift
//  CameraApp
//
//  Created by Hang Yang on 2/25/19.
//  Copyright © 2019 hang yang. All rights reserved.
//

import UIKit
import Parse

class SearchViewController: UIViewController, UIGestureRecognizerDelegate, myTableDelegate{

    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var userObj: PFObject!
    var searching = false
    
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
            let target = self.userObj
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
                cell.setAvatar(username: username as! String, icon: img)
                
                let alert = UIAlertController(title: "点击结果栏添加", message: "", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "知道了", style: .default, handler: nil))
                
                self.present(alert, animated: true)
                
            }
            
        }
        
        return cell
        
    }
    
    func myTableDelegate() {
        let alert = UIAlertController(title: "是否添加该用户为好友？", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "是", style: .cancel, handler: {action in
            print("wu tian jia")
            
        }))
        
        alert.addAction(UIAlertAction(title: "否", style: .default, handler: nil))
        
        self.present(alert, animated: true)
    }
    
}
