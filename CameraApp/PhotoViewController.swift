//
//  PhotoViewController.swift
//  CameraApp
//
//  Created by hang yang on 1/22/19.
//  Copyright © 2019 hang yang. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var takePhoto: UIButton!
    @IBOutlet weak var photoLibrary: UIButton!
    @IBOutlet weak var imageDisplay: UIImageView!
    @IBOutlet weak var confirm: UIButton!
    @IBOutlet weak var cancel: UIButton!
    var whichButton: String?
    var dictionary =  [Int:UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func TakePhotoAction(_ sender: UIButton) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .camera
        
        present(picker, animated: true, completion: nil)
        
    }
    
    
    @IBAction func PhotoLibraryAction(_ sender: UIButton) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
        
    }
    
    @IBAction func CancelAction(_ sender: UIButton) {
        imageDisplay.image = nil
    }
    
    
    
    @IBAction func ConfirmAction(_ sender: UIButton) {
        
        
        //let buttonView = ButtonViewController(nibName: "ButtonViewController",bundle: nil)
        //buttonView.image = imageDisplay.image
        //self.tuPian = UIImage(named: "minus.png")!
        
        if imageDisplay.image == nil{
            let alert = UIAlertController(title: "请选择图片！", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "👌", style: .default, handler: nil))
            self.present(alert, animated: true)
        }else{
            self.performSegue(withIdentifier: "secondSegue", sender: self)
        }
        /*NotificationCenter.default.post(name: Holder.notificationName, object: nil, userInfo: ["data": 42, "isImportant": true])
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let resultViewController = storyBoard.instantiateViewController(withIdentifier: "ButtonViewController") as! ButtonViewController
    self.navigationController?.pushViewController(resultViewController, animated: true)*/
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is ButtonViewController
        {
            let vc = segue.destination as? ButtonViewController
            vc?.username = "123"
            vc?.which = whichButton!
            
            switch whichButton{
            case "a": vc?.counter = 1
            dictionary.updateValue(imageDisplay.image!, forKey: 1)
                vc?.diction = dictionary
            case "b": vc?.counter = 2
            dictionary.updateValue(imageDisplay.image!, forKey: 2)
            vc?.diction = dictionary
            case "c": vc?.counter = 3
            dictionary.updateValue(imageDisplay.image!, forKey: 3)
            vc?.diction = dictionary
            case "d": vc?.counter = 4
            dictionary.updateValue(imageDisplay.image!, forKey: 4)
            vc?.diction = dictionary
            default: break
            }
            
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage;dismiss(animated: true, completion: nil)
        
        imageDisplay.image = self.scaleImageWith(image: pickedImage!, and: CGSize(width: 1000, height: 1000))
    }
    
    func scaleImageWith(image: UIImage, and newSize: CGSize)->UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        let rect = CGRect(origin: .zero, size: CGSize(width: newSize.width, height: newSize.height))
        image.draw(in: rect)
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return newImage
    }

}
