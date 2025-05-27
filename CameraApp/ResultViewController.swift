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
import AVFoundation

class ResultViewController: UIViewController {

    var result = false
    var objectId: String!
    var ratio: Double!
    var flag: Bool!
    var audioPlayer: AVAudioPlayer?
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
        
        flag = false
        
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        playCustomSound()
    }
    
    func playCustomSound() {
        var soundURL: URL?

        if result {
            guard let url = Bundle.main.url(forResource: "correct", withExtension: "m4a") else {
                print("无法找到正确音频文件")
                return
            }
            soundURL = url
        } else {
            guard let url = Bundle.main.url(forResource: "incorrect", withExtension: "m4a") else {
                print("无法找到错误音频文件")
                return
            }
            soundURL = url
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL!)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("播放声音时出错: \(error.localizedDescription)")
        }
    }
    
    func calculate() {
        
        let pfq = PFQuery(className: "JoinTable")
        pfq.whereKey("objectId", equalTo: objectId)
        pfq.getFirstObjectInBackground { (object, err) in
            
            let sender = object!["from"] as! PFUser
            let pfq = PFQuery(className: "Rapport")
            let gp = DispatchGroup()
            pfq.whereKey("to", equalTo: PFUser.current()!)
            pfq.whereKey("from", equalTo: sender)
            
            gp.enter()
            
            let rapport = pfq.findObjectsInBackground { (objs, error) in
                
                let obj = objs?.first
                
                if  obj == nil {
                    
                    self.text1.text = "你对TA的了解: N/A"
                    self.text3.text = "你还不是TA的好友，请发送好友请求"
                    self.flag = true
                    
                } else {
                    
                    let numqmap = obj!["numOfQuestionToHim"] as! [String : Int]
                    var correctmap = obj!["numHisCorrect"] as! [String : Int]
                    let numq = numqmap[PFUser.current()!.objectId!]!
                    var correct = correctmap[PFUser.current()!.objectId!]!
                    
                    if self.result {
                        
                        correct = correct + 1
                        correctmap.updateValue(correct, forKey: PFUser.current()!.objectId!)
                        obj!.setObject(correctmap, forKey: "numHisCorrect")
                        
                        do {
                            try obj?.save()
                            print("保存成功")
                        } catch {
                            print("保存失败: \(error.localizedDescription)")
                        }
                        
//                      try! obj!.save()
                        
                    }
                    
                    self.ratio = Double(correct) / Double(numq)
                    let y = Double(round(100000 * self.ratio)/1000)
                    self.text1.text = "你对TA的了解: " + "\(y)" + "%"
                    
                }
                
                gp.leave()
                
            }
            
            gp.notify(queue: .main) {
                var h0 : Double = 0.0
                var level0 : String = "无"
                
                let pq = PFQuery(className: "Rapport")
                pq.whereKey("from", equalTo: PFUser.current()!)
                pq.whereKey("to", equalTo: sender)
                pq.getFirstObjectInBackground { (obj, err) in
                    
                    if obj == nil {
                        
                        if self.flag == false {
                            
                            self.text3.text = "快给TA出道题看看你们的默契度吧～"
                            
                        } else {
                            
                            self.text3.text = "你还不是TA的好友，请发送好友请求"
                            
                        }
                        
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
                                
                                if self.flag == false {
                                    
                                    self.text3.text = "快给TA出道题看看你们的默契度吧～"
                                    
                                } else {
                                    
                                    self.text3.text = "你还不是TA的好友，请发送好友请求"
                                    
                                }
                                
                            } else {
                                
                                if self.flag == false {
                                    
                                    let z = obj!["numHisCorrect"] as! [String : Int]
                                    let t = z[sender.objectId!]!
                                    let r: Double = Double(t) / Double(y)
                                    let m = Double(round(1000 * r)/1000)
                                    let n = Double(round(1000 * self.ratio)/1000)
                                    let g = m * n
                                    let h = Double(round(100000 * g)/1000)
                                    var level: String!
                                    
                                    switch h {
                                        
                                    case 0...7.5:
                                        level = "云泥之别"
                                        
                                    case 7.5...15:
                                        level = "人鬼殊途"
                                        
                                    case 15...25:
                                        level = "伯牙绝弦"
                                        
                                    case 25...40:
                                        level = "点头之交"
                                        
                                    case 40...60:
                                        level = "酒逢知己"
                                        
                                    case 60...80:
                                        level = "心有灵犀"
                                        
                                    default:
                                        level = "天造地设"
                                        
                                    }
                                    
                                    self.text3.text = level + ": 你俩的默契度为" + "\(h)" + "%"
                                    level0 = level
                                    h0 = h
                                    
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
                let query1 = PFQuery(className: "Rapport")
                query1.whereKey("from", equalTo: PFUser.current()!)
                query1.whereKey("to", equalTo: sender)
                
                let query2 = PFQuery(className: "Rapport")
                query2.whereKey("from", equalTo: sender)
                query2.whereKey("to", equalTo: PFUser.current()!)
                
                let tableQuery = PFQuery.orQuery(withSubqueries: [query1, query2])
                
                tableQuery.findObjectsInBackground(block: { (objs, err) in
                    
                    if objs != nil && objs?[0] != nil {
                        // ✅ 新增：将 level 保存到 Rapport 文档
                        objs?[0]["level"] = level0  // 添加 level 字段
                        objs?[0]["compatibilityScore"] = h0  // 可选：存储数值型默契度
                        objs?[0].saveInBackground { (success, error) in
                            if success {
                                print("1. ✅ level 和 compatibilityScore 已保存到服务器")
                            } else if let error = error {
                                print("1. ❌ 保存失败: \(error.localizedDescription)")
                            }
                        }
                    }
                    
                    if objs != nil && objs?[1] != nil {
                        // ✅ 新增：将 level 保存到 Rapport 文档
                        objs?[1]["level"] = level0  // 添加 level 字段
                        objs?[1]["compatibilityScore"] = h0  // 可选：存储数值型默契度
                        objs?[1].saveInBackground { (success, error) in
                            if success {
                                print("2. ✅ level 和 compatibilityScore 已保存到服务器")
                            } else if let error = error {
                                print("2. ❌ 保存失败: \(error.localizedDescription)")
                            }
                        }
                    }
                    
                })
                
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
