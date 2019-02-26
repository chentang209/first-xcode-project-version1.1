//
//  TableViewController.swift
//  CameraApp
//
//  Created by Hang Yang on 2/24/19.
//  Copyright © 2019 hang yang. All rights reserved.
//

import UIKit
import Parse

class TableViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var avatar: [Avatar] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
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
        
        avatar = createArray()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @objc func addTapped(sender: UITapGestureRecognizer) {
        print("addTapped")
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
    
    func createArray() -> [Avatar] {
        
        var tempAvatars: [Avatar] = []
        
        //tempAvatars.append(<#T##newElement: Avatar##Avatar#>)
        
        
        
        return tempAvatars
    }

}

extension TableViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return avatar.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let avatar = self.avatar[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AvatarCell") as! AvatarCell
        
        cell.setAvatar(avatar: avatar)
        
        return cell
    }
    
}
