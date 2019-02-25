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
        tapToChange.clipsToBounds = true;
        tapToChange.layer.cornerRadius = tapToChange.layer.frame.size.width/2;
        
        submit.layer.cornerRadius = 30
        submit.clipsToBounds = true
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        confirmTextField.delegate = self
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    
    @IBAction func changeAvatar(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
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

        print(" continue tapped")
        let currentUser = PFUser.current();
        if (currentUser != nil) {
            PFUser.logOut();
        }
        
        if usernameTextField.text != "" && passwordTextField.text != "" && confirmTextField.text != "" {
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
            
            let file:PFFileObject = PFFileObject(data: avatar)!
            user.setObject(file, forKey:"avatar")
            user.signUpInBackground{
                (result,error) -> Void in
            
                if error == nil && result == true {
                    //User was successfully created
                } else {
                    let alert = UIAlertController(title: error!.localizedDescription, message: "", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "知道了", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
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

