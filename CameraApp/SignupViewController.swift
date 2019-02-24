//
//  SignupViewController.swift
//  CameraApp
//
//  Created by Hang Yang on 2/22/19.
//  Copyright © 2019 hang yang. All rights reserved.
//

import UIKit
import Parse

class SignupViewController: UIViewController {

    
    @IBOutlet weak var submit: UIButton!
    
    @IBOutlet weak var tapToChange: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tapToChange.clipsToBounds = true;
        tapToChange.layer.cornerRadius = tapToChange.layer.frame.size.width/2;
        
        submit.layer.cornerRadius = 30
        submit.clipsToBounds = true
        
        let user = PFObject(className: "Ubsers")
        user["name"] = "Matt"
        user.saveInBackground{(success, error) in
            if success {
                print("Object saved")
            } else {
                if let error = error {
                    print(error)
                } else {
                    print("Error")
                }
            }
        }
    }
    

    

}
