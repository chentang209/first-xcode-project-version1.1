//
//  LoginViewController.swift
//  CameraApp
//
//  Created by Hang Yang on 2/22/19.
//  Copyright © 2019 hang yang. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController{

    @IBOutlet weak var Login: UIButton!
    @IBOutlet weak var createNew: UIButton!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    var user: PFUser!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        Login.layer.cornerRadius = 30
        Login.clipsToBounds = true
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        usernameTextField.becomeFirstResponder()
        
//        if PFUser.current() != nil {
//            
//            let alert = CustomAlert(title: "", image: UIImage(named: "enter")!)
//            alert.show(animated: true)
//            
//            let when = DispatchTime.now() + 3
//            DispatchQueue.main.asyncAfter(deadline: when){
//                alert.dismiss(animated: true)
//                self.performSegue(withIdentifier: "loginSuccess", sender: self)
//            }
//            
//        }
        
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
    
    @IBAction func loginTapped(_ sender: UIButton) {
        
        if usernameTextField.text != "" && passwordTextField.text != "" {
            PFUser.logInWithUsername(inBackground: usernameTextField.text!, password: passwordTextField.text!) { (user: PFUser?, error: Error?) in
            print("🔵 登录回调触发 - 主线程状态:", Thread.isMainThread ? "主线程" : "后台线程")
            print("🔄 当前执行队列:", OperationQueue.current?.name ?? "未命名队列")
            print("🔵 登录回调触发 - 主线程状态:", Thread.isMainThread ? "主线程" : "后台线程")
            print("🔍 用户对象状态:", user != nil ? "有效用户" : "空用户")

            if let loggedInUser = user {
                    print("✅ 登录回调被触发，当前用户:", loggedInUser.username ?? "无名用户")
                    
                    // User object isn't nill
                    // TODO: User logged in successfully, transition into homepage
                    self.user = loggedInUser
                    let alert = CustomAlert(title: "", image: UIImage(named: "enter")!)
                    alert.show(animated: true)
                    let when = DispatchTime.now() + 3
                    DispatchQueue.main.asyncAfter(deadline: when){
                        alert.dismiss(animated: true)
                        self.performSegue(withIdentifier: "loginSuccess", sender: self)
                    }
                    // 添加计时逻辑，30分钟后自动登出
                    print("⏱️ 开始调度延迟登出任务，当前时间:", Date())
                    print("ℹ️ 主线程状态:", Thread.isMainThread ? "主线程" : "后台线程")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1800) {
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
                } else {
                    
                    // User object is nil, check error parameter
                    print(error as Any)
                    
                    let alert = UIAlertController(title: "用户名或密码错误", message: "", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "知道了", style: .default, handler: nil))
                    self.present(alert, animated: true)
                
                }
            }
            
        } else {
            
            let alert = UIAlertController(title: "用户名和密码不能为空", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "知道了", style: .default, handler: nil))
            self.present(alert, animated: true)
        
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
//        if segue.destination is ViewController
//        {
//            let vc = segue.destination as? ViewController
//            vc?.user = self.user
//        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        NotificationCenter.default.post(name: .userDidInteract, object: nil)
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
}

extension LoginViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        NotificationCenter.default.post(name: .userDidInteract, object: nil)
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        return true
    }
        
}
