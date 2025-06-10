//
//  AnswerViewController.swift
//  CameraApp
//
//  Created by Hang Yang on 3/7/19.
//  Copyright © 2019 hang yang. All rights reserved.
//

import UIKit
import Parse
var ente = true

class AnswerViewController: UIViewController {

    @IBOutlet weak var but1: UIButton!
    @IBOutlet weak var but2: UIButton!
    @IBOutlet weak var but3: UIButton!
    @IBOutlet weak var but4: UIButton!
    @IBOutlet weak var tuichu: UIButton!
    @IBOutlet weak var opt4: UITextField!
    @IBOutlet weak var opt3: UITextField!
    @IBOutlet weak var opt2: UITextField!
    @IBOutlet weak var opt1: UITextField!
    
    var dict : [String : Any] = [ : ]
    var result = false
    var img : UIImage!
    var objectId : String!
    
    func getFileDataSync(fileObject: PFFileObject) -> Data? {
        var fileData: Data?
        let semaphore = DispatchSemaphore(value: 0)

        fileObject.getDataInBackground { (data: Data?, error: Error?) in
            if let error = error {
                print("文件下载失败: \(error.localizedDescription)")
            } else {
                fileData = data
            }
            semaphore.signal() // 通知等待的线程
        }

        semaphore.wait() // 阻塞当前线程，直到回调完成
        return fileData
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.hidesBackButton = true
        
        if ente {
            let alert = UIAlertController(title: "点击图片可放大🔍, 多张图一起点轮流播放😊", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "知道了", style: .default, handler: nil))
            self.present(alert, animated: true)
            ente = false
        }
        
        opt1.text = dict["op1"] as? String
        opt2.text = dict["op2"] as? String
        opt3.text = dict["op3"] as? String
        opt4.text = dict["op4"] as? String
        
        DispatchQueue.global().async { [self] in
            guard let fileObject = dict["pic1"]! as? PFFileObject else { return }
            if let data = self.getFileDataSync(fileObject: fileObject) {
                let pic1 = UIImage(data: data)
                DispatchQueue.main.async {
                    self.but1.setImage(pic1, for: [])
                }
            }
            
            guard let fileObject = dict["pic2"]! as? PFFileObject else { return }
            if let data = self.getFileDataSync(fileObject: fileObject) {
                let pic2 = UIImage(data: data)
                DispatchQueue.main.async {
                    self.but2.setImage(pic2, for: [])
                }
            }
            
            guard let fileObject = dict["pic3"]! as? PFFileObject else { return }
            if let data = self.getFileDataSync(fileObject: fileObject) {
                let pic3 = UIImage(data: data)
                DispatchQueue.main.async {
                    self.but3.setImage(pic3, for: [])
                }
            }
            
            guard let fileObject = dict["pic4"]! as? PFFileObject else { return }
            if let data = self.getFileDataSync(fileObject: fileObject) {
                let pic4 = UIImage(data: data)
                DispatchQueue.main.async {
                    self.but4.setImage(pic4, for: [])
                }
            }
        }
       
        let myColor = UIColor.green
        opt1.layer.borderColor = myColor.cgColor
        opt1.layer.borderWidth = 0.0
        opt2.layer.borderColor = myColor.cgColor
        opt2.layer.borderWidth = 0.0
        opt3.layer.borderColor = myColor.cgColor
        opt3.layer.borderWidth = 0.0
        opt4.layer.borderColor = myColor.cgColor
        opt4.layer.borderWidth = 0.0
        
        opt1.delegate = self
        opt2.delegate = self
        opt3.delegate = self
        opt4.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        SessionManager.shared.resetTimer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @IBAction func tuichuAct(_ sender: UIButton) {
        self.performSegue(withIdentifier: "exitAnswer", sender: self)
    }
    
    @IBAction func but1Act(_ sender: UIButton) {
        img = but1.image(for: [])
        self.performSegue(withIdentifier: "peekSegue", sender: self)
    }
    
    @IBAction func but2Act(_ sender: UIButton) {
        img = but2.image(for: [])
        self.performSegue(withIdentifier: "peekSegue", sender: self)
    }
    
    @IBAction func but3Act(_ sender: UIButton) {
        img = but3.image(for: [])
        self.performSegue(withIdentifier: "peekSegue", sender: self)
    }
    
    @IBAction func but4Act(_ sender: UIButton) {
        img = but4.image(for: [])
        self.performSegue(withIdentifier: "peekSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is ResultViewController
        {
            let vc = segue.destination as? ResultViewController
            vc?.result = result
            print("2: " + objectId)
            vc?.objectId = objectId
        }
        
        if segue.destination is FullPicViewController
        {
            let vc = segue.destination as? FullPicViewController
            vc?.image = img
            vc?.dic = dict
            vc?.objectId = objectId
        }
        
        if segue.destination is TableViewController
        {
            let trans = CATransition()
            trans.type = CATransitionType.moveIn
            trans.subtype = CATransitionSubtype.fromLeft
            trans.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            trans.duration = 0.35
            self.navigationController?.view.layer.add(trans, forKey: nil)
        }
    }
    
}

extension AnswerViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        textField.resignFirstResponder()
        textField.layer.borderWidth = 2.0
        let alert = UIAlertController(title: "确定是这个答案吗?", message: "", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { action in
            
            if textField.text == self.dict["correct"] as! String {
                self.result = true
            } else {
                self.result = false
            }
            
            self.performSegue(withIdentifier: "resultSegue", sender: self)
        }))
        
        alert.addAction(UIAlertAction(title: "再改改", style: .cancel, handler: { action in
            self.opt1.layer.borderWidth = 0.0
            self.opt2.layer.borderWidth = 0.0
            self.opt3.layer.borderWidth = 0.0
            self.opt4.layer.borderWidth = 0.0
        }))
        
        self.present(alert, animated: true)
    }
}
