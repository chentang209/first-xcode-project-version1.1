//
//  LoginViewController.swift
//  CameraApp
//
//  Created by Hang Yang on 2/22/19.
//  Copyright © 2019 hang yang. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    
    @IBOutlet weak var Login: UIButton!
    
    @IBOutlet weak var createNew: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Login.layer.cornerRadius = 30
        Login.clipsToBounds = true
        
    }
    

    

}
