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
        
        user = PFUser.current()
        let qe = PFQuery(className: "JoinTable")
        qe.whereKey("to", equalTo: PFUser.current()!)
        qe.whereKey("request", equalTo: "sendrequest")
        let obj = try! qe.findObjects().first
        
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
        
        let pfi = PFInstallation.current()
        pfi?.setObject(user, forKey: "user")
        pfi?.setObject(0, forKey: "badge")
        try! pfi?.save()
        
    }
    
}
