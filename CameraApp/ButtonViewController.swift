//
//  ViewController.swift
//  CameraApp
//
//  Created by hang yang on 1/21/19.
//  Copyright © 2019 hang yang. All rights reserved.
//

import UIKit

class ButtonViewController: UIViewController{
    
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!
    @IBOutlet weak var option1: UITextField!
    @IBOutlet weak var option2: UITextField!
    @IBOutlet weak var option3: UITextField!
    @IBOutlet weak var option4: UITextField!
    var image: UIImage?
    var username: String = "456"
    var counter: Int?
    var which: String = "nil"
    var diction = [Int:UIImage]()
    var store = [String:AnyObject]()
    var hao: Bool = false
    var green: Bool = true
    var cur: Int = 0
    var correct: String = "nil"
    var alert1: UIAlertController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.option1.isUserInteractionEnabled = false
        self.option2.isUserInteractionEnabled = false
        self.option3.isUserInteractionEnabled = false
        self.option4.isUserInteractionEnabled = false
        
        let myColor = UIColor.green
        option1.layer.borderColor = myColor.cgColor
        option1.layer.borderWidth = 0.0
        option2.layer.borderColor = myColor.cgColor
        option2.layer.borderWidth = 0.0
        option3.layer.borderColor = myColor.cgColor
        option3.layer.borderWidth = 0.0
        option4.layer.borderColor = myColor.cgColor
        option4.layer.borderWidth = 0.0
        
        option1.delegate = self
        option2.delegate = self
        option3.delegate = self
        option4.delegate = self
        
        if username == "123"{
            
            //let photoViewController = PhotoViewController(nibName: "PhotoViewController",bundle: nil)
            
            //counter = photoViewController.dictionary[which]
            //print(photoViewController.dictionary)
            if diction.count == 4{
                
                let alert = UIAlertController(title: "确定用这四张图吗?", message: "", preferredStyle: .alert)

                alert.addAction(UIAlertAction(title: "是", style: .default, handler: { action in
                    
                    self.navigationItem.hidesBackButton = true
                    self.option1.isUserInteractionEnabled = true
                    self.option2.isUserInteractionEnabled = true
                    self.option3.isUserInteractionEnabled = true
                    self.option4.isUserInteractionEnabled = true
                    self.button.isUserInteractionEnabled = false
                    self.button2.isUserInteractionEnabled = false
                    self.button3.isUserInteractionEnabled = false
                    self.button4.isUserInteractionEnabled = false
                    
                    self.store.updateValue(self.diction[1]!, forKey: "pic1")
                    self.store.updateValue(self.diction[2]!, forKey: "pic2")
                    self.store.updateValue(self.diction[3]!, forKey: "pic3")
                    self.store.updateValue(self.diction[4]!, forKey: "pic4")
                    
                }))
                
                alert.addAction(UIAlertAction(title: "否", style: .cancel, handler: { action in
                    
                    let alert = UIAlertController(title: "请点击你想要更换的图片", message: "", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "好", style: .default, handler: nil))
                
                    self.present(alert, animated: true)
                }))
            
                self.present(alert, animated: true)
            }
            
            switch counter{
                case 1: print(diction)
                        button.setImage(diction[1], for: [])
                        if diction[2] != nil
                        {button2.setImage(diction[2], for: [])}
                        if diction[3] != nil
                        {button3.setImage(diction[3], for: [])}
                        if diction[4] != nil
                        {button4.setImage(diction[4], for: [])}
                case 2: print(diction)
                        button2.setImage(diction[2], for: [])
                        if diction[1] != nil
                        {button.setImage(diction[1], for: [])}
                        if diction[3] != nil
                        {button3.setImage(diction[3], for: [])}
                        if diction[4] != nil
                        {button4.setImage(diction[4], for: [])}
                case 3: print(diction)
                        button3.setImage(diction[3], for: [])
                        if diction[1] != nil
                        {button.setImage(diction[1], for: [])}
                        if diction[2] != nil
                        {button2.setImage(diction[2], for: [])}
                        if diction[4] != nil
                        {button4.setImage(diction[4], for: [])}
                case 4: print(diction)
                        button4.setImage(diction[4], for: [])
                        if diction[1] != nil
                        {button.setImage(diction[1], for: [])}
                        if diction[2] != nil
                        {button2.setImage(diction[2], for: [])}
                        if diction[3] != nil
                        {button3.setImage(diction[3], for: [])}
                default: break
            }
        }
    }
    
    
    
    @IBAction func action(_ sender: UIButton) {
        print("1")
        which = "a"
        self.performSegue(withIdentifier: "firstSegue", sender: self)
    }
    
    @IBAction func action2(_ sender: UIButton) {
        print("2")
        which = "b"
        self.performSegue(withIdentifier: "firstSegue", sender: self)
    }
    
    @IBAction func action3(_ sender: UIButton) {
        print("3")
        which = "c"
        self.performSegue(withIdentifier: "firstSegue", sender: self)
    }
    
    @IBAction func action4(_ sender: UIButton) {
        print("4")
        which = "d"
        self.performSegue(withIdentifier: "firstSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is PhotoViewController
        {
            let vc = segue.destination as? PhotoViewController
            vc?.whichButton = which
            vc?.dictionary = diction
        }
        
        if segue.destination is ShowViewController
        {
            let vc = segue.destination as? ShowViewController
            vc?.accept = store
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if (option1.text!.count > 6) || (option2.text!.count > 6)||(option3.text!.count > 6) || (option4.text!.count > 6){
            
            let alert = UIAlertController(title: "选项长度不能大于6!", message: "", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "知道了", style: .default, handler: nil))
            
            self.present(alert, animated: true)
        }
        
        if (option1.text == store["op2"] as? String && cur == 1 && option1.text != "") || (option1.text == store["op3"] as? String && cur == 1 && option1.text != "") || (option1.text == store["op4"] as? String && cur == 1 && option1.text != "") || (option2.text == store["op1"] as? String && cur == 2 && option2.text != "") || (option2.text == store["op3"] as? String && cur == 2 && option2.text != "") || (option2.text == store["op4"] as? String && cur == 2 && option2.text != "") || (option3.text == store["op1"] as? String && cur == 3 && option3.text != "") || (option3.text == store["op2"] as? String && cur == 3 && option3.text != "") || (option3.text == store["op4"] as? String && cur == 3 && option3.text != "") || (option4.text == store["op1"] as? String && cur == 4 && option4.text != "") || (option4.text == store["op2"] as? String && cur == 4 && option4.text != "") || (option4.text == store["op3"] as? String && cur == 4 && option4.text != ""){
            
            let alert = UIAlertController(title: "选项不能相同!", message: "", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "知道了", style: .default, handler: nil))
            
            self.present(alert, animated: true)
        }
        
        option1.resignFirstResponder()
        option2.resignFirstResponder()
        option3.resignFirstResponder()
        option4.resignFirstResponder()
    }
    
}

extension ButtonViewController: UITextFieldDelegate{
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if hao{
            
            
            if textField.text == store["op1"] as? String{
                option1.resignFirstResponder()
                self.option1.layer.borderWidth = 2.0
                let alert = UIAlertController(title: "确定是这个答案吗?", message: "", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { action in
                    self.correct = textField.text!
                    self.store.updateValue(self.correct as AnyObject, forKey: "correct")
                    self.performSegue(withIdentifier: "showSegue", sender: self)
                }))
                
                alert.addAction(UIAlertAction(title: "再改改", style: .cancel, handler: { action in
                    self.option1.layer.borderWidth = 0.0
                    self.option2.layer.borderWidth = 0.0
                    self.option3.layer.borderWidth = 0.0
                    self.option4.layer.borderWidth = 0.0
                }))
                
                //self.present(alert, animated: true)
                if presentedViewController == nil {
                    self.present(alert, animated: true, completion: nil)
                } else {
                    self.dismiss(animated: false) { () -> Void in
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                
            }else if textField.text == store["op2"] as? String{
                option2.resignFirstResponder()
                self.option2.layer.borderWidth = 2.0
                let alert = UIAlertController(title: "确定是这个答案吗?", message: "", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { action in
                    self.correct = textField.text!
                    self.store.updateValue(self.correct as AnyObject, forKey: "correct")
                    self.performSegue(withIdentifier: "showSegue", sender: self)
                }))
                
                alert.addAction(UIAlertAction(title: "再改改", style: .cancel, handler: { action in
                    self.option1.layer.borderWidth = 0.0
                    self.option2.layer.borderWidth = 0.0
                    self.option3.layer.borderWidth = 0.0
                    self.option4.layer.borderWidth = 0.0
                }))
                
                //self.present(alert, animated: true)
                if presentedViewController == nil {
                    self.present(alert, animated: true, completion: nil)
                } else {
                    self.dismiss(animated: false) { () -> Void in
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                
            }else if textField.text == store["op3"] as? String{
                option3.resignFirstResponder()
                self.option3.layer.borderWidth = 2.0
                let alert = UIAlertController(title: "确定是这个答案吗?", message: "", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { action in
                    self.correct = textField.text!
                    self.store.updateValue(self.correct as AnyObject, forKey: "correct")
                    self.performSegue(withIdentifier: "showSegue", sender: self)
                }))
                
                alert.addAction(UIAlertAction(title: "再改改", style: .cancel, handler: { action in
                    self.option1.layer.borderWidth = 0.0
                    self.option2.layer.borderWidth = 0.0
                    self.option3.layer.borderWidth = 0.0
                    self.option4.layer.borderWidth = 0.0
                }))
                
                //self.present(alert, animated: true)
                if presentedViewController == nil {
                    self.present(alert, animated: true, completion: nil)
                } else {
                    self.dismiss(animated: false) { () -> Void in
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                
            }else if textField.text == store["op4"] as? String{
                option4.resignFirstResponder()
                self.option4.layer.borderWidth = 2.0
                let alert = UIAlertController(title: "确定是这个答案吗?", message: "", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { action in
                    self.correct = textField.text!
                    self.store.updateValue(self.correct as AnyObject, forKey: "correct")
                    self.performSegue(withIdentifier: "showSegue", sender: self)
                }))
                
                alert.addAction(UIAlertAction(title: "再改改", style: .cancel, handler: { action in
                    self.option1.layer.borderWidth = 0.0
                    self.option2.layer.borderWidth = 0.0
                    self.option3.layer.borderWidth = 0.0
                    self.option4.layer.borderWidth = 0.0
                }))
                
                //self.present(alert, animated: true)
                if presentedViewController == nil {
                    self.present(alert, animated: true, completion: nil)
                } else {
                    self.dismiss(animated: false) { () -> Void in
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
            
            green = false
            
            
        }
        
        if textField == option1{
            cur = 1
        }else if textField == option2{
            cur = 2
        }else if textField == option3{
            cur = 3
        }else if textField == option4{
            cur = 4
        }
        
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
    
        if green{
            
            if textField.text!.count <= 6{
                self.store.updateValue(option1.text! as AnyObject, forKey: "op1")
                self.store.updateValue(option2.text! as AnyObject, forKey: "op2")
                self.store.updateValue(option3.text! as AnyObject, forKey: "op3")
                self.store.updateValue(option4.text! as AnyObject, forKey: "op4")
                
            }
            
            if (store["op1"] as? String != "") && (store["op2"] as? String != "") &&   (store["op3"] as? String != "") && (store["op4"] as? String != ""){
            
                alert1 = UIAlertController(title: "确定用这些选项吗?", message: "", preferredStyle: .alert)
            
                alert1.addAction(UIAlertAction(title: "确定", style: .default, handler: { action in
                
                    let alert = UIAlertController(title: "选择一个正确答案", message: "", preferredStyle: .alert)
                
                    alert.addAction(UIAlertAction(title: "好", style: .default, handler: nil
                    ))
                
                    self.present(alert, animated: true)
                
                    self.hao = true
                    
                    
                }))
            
                alert1.addAction(UIAlertAction(title: "再改改", style: .cancel, handler: { action in
                
                    /*self.option1.isUserInteractionEnabled = true
                    self.option2.isUserInteractionEnabled = true
                    self.option3.isUserInteractionEnabled = true
                    self.option4.isUserInteractionEnabled = true*/
                    
                }))
            
                self.present(alert1, animated: true, completion: nil)
                
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if (textField.text == store["op1"] as? String && cur != 1 && textField.text != "") || (textField.text == store["op2"] as? String && cur != 2 && textField.text != "") || (textField.text == store["op3"] as? String && cur != 3 && textField.text != "") || (textField.text == store["op4"] as? String && cur != 4 && textField.text != ""){
            
            let alert = UIAlertController(title: "选项不能相同!", message: "", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "知道了", style: .default, handler: nil))
            
            self.present(alert, animated: true)
        }
        
        if textField.text!.count > 6{
            
            let alert = UIAlertController(title: "选项长度不能大于6!", message: "", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "知道了", style: .default, handler: nil))
            
            self.present(alert, animated: true)
        }
        
        option1.resignFirstResponder()
        option2.resignFirstResponder()
        option3.resignFirstResponder()
        option4.resignFirstResponder()
        return true
    }
    
    /*override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        option1.resignFirstResponder()
    }*/
    
    
}


