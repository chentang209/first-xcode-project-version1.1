import Foundation

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
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var confirmTextField: UITextField!
    
    @IBOutlet weak var avatar: UIButton!
    
    var avatar2: UIImage = UIImage()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tapToChange.clipsToBounds = true
        tapToChange.layer.cornerRadius = tapToChange.layer.frame.size.width/2
        
        submit.layer.cornerRadius = 30
        submit.clipsToBounds = true
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        confirmTextField.delegate = self
        usernameTextField.becomeFirstResponder()
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
    
    }
    
    @IBAction func changeAvatar(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        NotificationCenter.default.post(name: .userDidInteract, object: nil)
        
            if confirmTextField.text == passwordTextField.text || confirmTextField.text == ""{
                //Dismiss the keyboards
                usernameTextField.resignFirstResponder()
                passwordTextField.resignFirstResponder()
                confirmTextField.resignFirstResponder()
            } else {
                if confirmTextField.text != ""{
                    let alert = UIAlertController(title: "密码不一致", message: "", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "知道了", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
            }
        
    }
    
    @IBAction func signupTapped(_ sender: UIButton) {

        print("continue tapped")
        let currentUser = PFUser.current();
        if (currentUser != nil) {
            PFUser.logOut();
        }
        
        if usernameTextField.text != "" && passwordTextField.text != "" && confirmTextField.text != "" {
            
            if confirmTextField.text == passwordTextField.text {
                
                let user = PFUser()
                user.username = usernameTextField.text!
                user.password = passwordTextField.text!
                
                var avatar3: UIImage
                var avatar: Data
                
                if self.avatar2.size.equalTo(CGSize.zero) {
                    
                    avatar3 = UIImage(named: "user")!
                    avatar = avatar3.jpegData(compressionQuality: 0.5)!
                
                } else {
                    
                    avatar = avatar2.jpegData(compressionQuality: 0.5)!
                
                }
                
                // 先完成用户注册
let file = PFFileObject(data: avatar, contentType: "image/jpeg")
                // 暂时不设置avatar，等注册成功后再设置
                user.setObject([], forKey: "friendReqList")
                user.setObject([], forKey: "friendList")
                user.setObject([], forKey: "receivedQuestions")
                
                // 先完成基础注册
user.signUpInBackground { (result, error) in
    if let error = error {
        // 处理注册错误
        let alert = UIAlertController(title: error.localizedDescription, message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "知道了", style: .default, handler: nil))
        self.present(alert, animated: true)
        return
    }
    
    // 注册成功后设置头像
    PFUser.current()?.setObject(file, forKey: "avatar")
    PFUser.current()?.saveInBackground { (success, error) in
        if let error = error {
            let alert = UIAlertController(title: error.localizedDescription, message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "知道了", style: .default, handler: nil))
            self.present(alert, animated: true)
        } else {
            let alert = CustomAlert(title: "", image: UIImage(named: "enter")!)
            alert.show(animated: true)
            let when = DispatchTime.now() + 3
            DispatchQueue.main.asyncAfter(deadline: when) {
                alert.dismiss(animated: true)
                self.performSegue(withIdentifier: "signupSuccess", sender: self)
            }
        }
    }
                    
                    if error == nil && result == true {
                        
                        let alert = CustomAlert(title: "", image: UIImage(named: "enter")!)
                        alert.show(animated: true)
                        
                        let when = DispatchTime.now() + 3
                        DispatchQueue.main.asyncAfter(deadline: when){
                            alert.dismiss(animated: true)
                            self.performSegue(withIdentifier: "signupSuccess", sender: self)
                            
                            // 添加计时逻辑，5分钟后自动登出
                            print("⏱️ 开始调度延迟登出任务，当前时间:", Date())
                            print("ℹ️ 主线程状态:", Thread.isMainThread ? "主线程" : "后台线程")
                            DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
                                print("🔔 延迟任务开始执行，当前线程:", Thread.isMainThread ? "主线程" : "后台线程")
                                print("👤 当前用户状态:", PFUser.current()?.username ?? "未登录")
                                PFUser.logOut()
                                print("✅ 用户凭证已清除，当前用户状态:", PFUser.current()?.username ?? "未登录")
                                DispatchQueue.main.async {
                                    print("🖥️ 开始界面跳转操作")
                                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                    guard let window = UIApplication.shared.windows.first else {
                                        print("❌ 无法获取主窗口")
                                        return
                                    }
                                    print("🌐 窗口状态: isKeyWindow=(window.isKeyWindow), rootVC=(String(describing: window.rootViewController))")
                                    let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
                                    let navigationController = UINavigationController(rootViewController: loginVC)
                                    UIApplication.shared.windows.first?.rootViewController = navigationController
                                    print("🏁 界面跳转完成")
                                }
                            }
                        }
                        
                    } else {
                        
                        let alert = UIAlertController(title: error!.localizedDescription, message: "", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "知道了", style: .default, handler: nil))
                        self.present(alert, animated: true)
                        
                    }
                    
                }
                
            } else {
                
                let alert = UIAlertController(title: "密码不一致", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "知道了", style: .default, handler: nil))
                self.present(alert, animated: true)
                
            }
            
        } else {
            
            let alert = UIAlertController(title: "横线不能为空", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "知道了", style: .default, handler: nil))
            self.present(alert, animated: true)
        
        }
        
    }
    
}

extension SignupViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        NotificationCenter.default.post(name: .userDidInteract, object: nil)
        
            if confirmTextField.text == passwordTextField.text || confirmTextField.text == ""{
                usernameTextField.resignFirstResponder()
                passwordTextField.resignFirstResponder()
                confirmTextField.resignFirstResponder()
            } else {
                if confirmTextField.text != ""{
                    let alert = UIAlertController(title: "密码不一致", message: "", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "知道了", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
            }
        
        return true
        
    }
    
}

extension SignupViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            avatar.setImage(pickedImage, for: [])
            self.avatar2 = pickedImage
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
}

