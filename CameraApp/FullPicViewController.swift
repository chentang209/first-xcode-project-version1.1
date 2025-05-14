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
    var image: UIImage = UIImage(named: "user")!
    var dic: [String : Any] = [ : ]
    var objectId : String!

    override func viewDidLoad() {
        super.viewDidLoad()

        mainView.image = self.image
    
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapHandler(sender:)))
        
        self.mainView.addGestureRecognizer(tapGestureRecognizer)
        self.mainView.isUserInteractionEnabled = true
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    @objc func tapHandler(sender: UITapGestureRecognizer) {
        self.performSegue(withIdentifier: "backSegue", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is AnswerViewController
        {
            let vc = segue.destination as? AnswerViewController
            vc?.dict = dic
            vc?.objectId = objectId
            let trans = CATransition()
            trans.type = CATransitionType.moveIn
            trans.subtype = CATransitionSubtype.fromLeft
            trans.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            trans.duration = 0.35
            self.navigationController?.view.layer.add(trans, forKey: nil)
        }
    }
    
}
