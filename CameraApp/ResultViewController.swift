//
//  ResultViewController.swift
//  CameraApp
//
//  Created by Hang Yang on 3/7/19.
//  Copyright © 2019 hang yang. All rights reserved.
//

import UIKit
import Parse
import SwiftGifOrigin

class ResultViewController: UIViewController {

    var result = false
    var objectId : String!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var crowView: UIImageView!
    @IBOutlet weak var yanhuaView: UIImageView!
    @IBOutlet weak var yanView: UIImageView!
    @IBOutlet weak var text1: UITextField!
    @IBOutlet weak var text2: UITextField!
    @IBOutlet weak var text3: UITextField!
    @IBOutlet weak var fanhui: UIButton!
    @IBOutlet weak var yun1: UIImageView!
    @IBOutlet weak var yun2: UIImageView!
    @IBOutlet weak var yun3: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(patternImage: UIImage(named: "yunhai")!)
        
        fanhui.layer.cornerRadius = 15
        fanhui.clipsToBounds = true
        
        yun1.image = UIImage(named: "yun2")
        yun2.image = UIImage(named: "yun2")
        yun3.image = UIImage(named: "yun3")

        fanhui.isUserInteractionEnabled = false
        
        if result {
            imageView.loadGif(name: "zhanghan")
            yanhuaView.loadGif(name: "yanhua")
            text2.text = "Congratulations!"
            let when = DispatchTime.now() + 1
            DispatchQueue.main.asyncAfter(deadline: when){
                self.yanView.loadGif(name: "yanhua")
            }
        } else {
            imageView.loadGif(name: "jinguanzhang")
            text2.text = "Sorry, you're wrong"
            text2.textColor = UIColor.red
            let images = createImageArray(total: 5)
            animate(imageView: crowView, images: images)
        }
        
        doStuff()
        calculate()
    }
    
    func calculate() {
        
        let pfq = PFQuery(className: "JoinTable")
        pfq.whereKey("objectId", equalTo: objectId)
        pfq.getFirstObjectInBackground { (object, err) in
            let sender = object!["from"] as! PFUser
            let pfq = PFQuery(className: "Rapport")
            pfq.whereKey("to", equalTo: PFUser.current()!)
            pfq.whereKey("from", equalTo: sender)
            let rapport = try! pfq.getFirstObject()
            let numqmap = rapport["numOfQuestionToHim"] as! [String : Int]
            var correctmap = rapport["numHisCorrect"] as! [String : Int]
            let numq = numqmap[PFUser.current()!.objectId!]!
            var correct = correctmap[PFUser.current()!.objectId!]!
            if self.result {
                correct = correct + 1
                correctmap.updateValue(correct, forKey: PFUser.current()!.objectId!)
                rapport.setObject(correctmap, forKey: "numHisCorrect")
                try! rapport.save()
            }
            let ratio: Double = Double(correct) / Double(numq)
            let y = Double(round(100000 * ratio)/1000)
            self.text1.text = "你对TA的了解: " + "\(y)" + "%"
            
            let pq = PFQuery(className: "Rapport")
            pq.whereKey("from", equalTo: PFUser.current()!)
            pq.whereKey("to", equalTo: sender)
            pq.getFirstObjectInBackground { (obj, err) in
                if obj == nil {
                    self.text3.text = "快添加对方为好友进行游戏吧～"
                } else {
                    if let error = err {
                        
                        print(error)
                        let alert = UIAlertController(title: "发生内部错误，请稍后再试", message: "", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "知道了", style: .default, handler: nil))
                        self.present(alert, animated: true)
                        
                    } else {
                        
                        let x = obj!["numOfQuestionToHim"] as! [String : Int]
                        let y = x[sender.objectId!]!
                        
                        if y == 0 {
                            self.text3.text = "快给TA出道题看看你们的默契度吧～"
                        } else {
                            let z = obj!["numHisCorrect"] as! [String : Int]
                            let t = z[sender.objectId!]!
                            let r: Double = Double(t) / Double(y)
                            let m = Double(round(1000 * r)/1000)
                            let n = Double(round(1000 * ratio)/1000)
                            let g = m * n
                            let h = Double(round(100000 * g)/1000)
                            self.text3.text = "天作之合: 你俩的默契度为" + "\(h)" + "%"
                            
                        }
                    
                    }
                    
                }
            }
            
        }
        
    }
    
    func doStuff() {
        
        let qe = PFQuery(className: "JoinTable")
        let gp = DispatchGroup()
        gp.enter()
        qe.whereKey("to", equalTo: PFUser.current()!)
        qe.findObjectsInBackground{ (objs:[PFObject]?, err:Error?) in
            
            print(err?.localizedDescription as Any)
            
            if let objs = objs {
                print("iffffffff")
                print("3: " + self.objectId)
                for o in objs {
                    
                    if o.objectId == self.objectId {
                        print("delete")
                        o.deleteEventually()
                    }
                    
                }
            }
            gp.leave()
        }
        gp.notify(queue: .main) {
            self.fanhui.isUserInteractionEnabled = true
        }
        
    }
    
    @IBAction func fanhuiAct(_ sender: UIButton) {
        self.performSegue(withIdentifier: "huiShouYe", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("prepare")
    }
            
    func createImageArray(total: Int)  -> [UIImage] {
        var imageArray: [UIImage] = []

        //imageArray.append(UIImage(named: "null")!)
        for i in 0..<total {
            let i = "\(i + 1)"
            let image = UIImage(named: i)
            imageArray.append(image!)
        }
        //imageArray.append(UIImage(named: "5")!)
        return imageArray
    }
    
    func animate(imageView: UIImageView, images: [UIImage]) {
        imageView.animationImages = images
        imageView.animationDuration = 4
        imageView.animationRepeatCount = 1
        imageView.startAnimating()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}
