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
            PFUser.logInWithUsername(inBackground: usernameTextField.text!, password: passwordTextField.text!) { (user, error) in
                if let loggedInUser = user {
                    
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
        if segue.destination is ViewController
        {
            let vc = segue.destination as? ViewController
            vc?.user = self.user
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            //Dismiss the keyboards
            usernameTextField.resignFirstResponder()
            passwordTextField.resignFirstResponder()
    }
}

extension LoginViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    
            usernameTextField.resignFirstResponder()
            passwordTextField.resignFirstResponder()
     
        return true
    }
        
}
