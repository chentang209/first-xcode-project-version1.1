//
//  FullPicViewController.swift
//  CameraApp
//
//  Created by Hang Yang on 2/23/19.
//  Copyright © 2019 hang yang. All rights reserved.
//

import UIKit

class FullPicViewController: UIViewController {

    @IBOutlet weak var mainView: UIImageView!
    var image: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mainView.image = self.image
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapHandler(sender:)))
        
        self.mainView.addGestureRecognizer(tapGestureRecognizer)
        self.mainView.isUserInteractionEnabled = true
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @objc func tapHandler(sender: UITapGestureRecognizer) {
        self.performSegue(withIdentifier: "backSegue", sender: self)
        
    }

    

}
