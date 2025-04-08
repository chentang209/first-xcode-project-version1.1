//
//  ShowViewController.swift
//  CameraApp
//
//  Created by hang yang on 2/1/19.
//  Copyright © 2019 hang yang. All rights reserved.
//

import UIKit
import CloudKit
import Parse
var enter = true

class ShowViewController: UIViewController {
    
    @IBOutlet weak var button1: UIButton!
    
    @IBOutlet weak var button2: UIButton!
    
    @IBOutlet weak var button3: UIButton!
    
    @IBOutlet weak var button4: UIButton!
    
    @IBOutlet weak var show: UIButton!
    
    @IBOutlet weak var but: UIButton!
    
    var accept = [String:AnyObject]()
    var newdic = [String:String]()
    var fileURL : URL!
    var notes = [CKRecord]()
    var img : UIImage!
    var very : String!
    var pp : NSData!
    
    //let database = CKContainer.default().publicCloudDatabase
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.hidesBackButton = true
        
        if enter {
            let alert = UIAlertController(title: "点击图片可放大🔍", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "知道了", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //super.viewDidAppear(true)
    }
    
    @IBAction func test(_ sender: UIButton) {
        print("test!")
    }
    
    @IBAction func sendPic(_ sender: UIButton) {
        enter = false
        self.performSegue(withIdentifier: "sendSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is FullPicViewController
        {
            let vc = segue.destination as? FullPicViewController
            vc?.image = self.img
        }
    }
    
    @IBAction func showact(_ sender: UIButton) {
      
        let findD = PFQuery(className: "Users")
        let u = try! findD.getFirstObject()
        let y = u.objectId as! String
        let x = u["Name"]
        print(y)
        print(x)
        
        let user = PFObject(className: "JoinTable")
       
        user.setObject("dduo" , forKey: "tu")
        
        user.saveInBackground{(success, error) in
            if success {
                print("tu saved")
            } else {
                if let error = error {
                    print(error)
                } else {
                    print("Error")
                }
            }
        }
        
        let findDi = PFQuery(className: "JoinTable")
        let uu = try! findDi.getFirstObject()
        let yy = uu.objectId as! String
        let qq = uu["tu"]
        print(yy)
        print(qq)
        
        
        
        let findDic = PFQuery(className: "Users")
        findDic.getFirstObjectInBackground{
        (obj: PFObject?, err: Error?) -> Void in
        
            let pf = obj!["question"] as! PFFileObject
            
            let group = DispatchGroup()
            group.enter()
            pf.getDataInBackground{
                (qData: Data?, error: Error?) -> Void in
         
                let actualdic = try! JSONSerialization.jsonObject(with: qData!, options: []) as! [String : String]
                let x = actualdic["pic3"]
                print("5")
                let data = NSData(base64Encoded: x!, options: [])
                self.img = UIImage(data: data! as Data)
                
                print(actualdic["op3"] as Any)
                group.leave()
            }
         
            group.notify(queue: .main) {
                print("7")
                self.button2.setImage(self.img, for: [])
            }
            
        }
        
//            let user = PFUser.current()
//            let file = user!["avatar"]!
//            let group = DispatchGroup()
//
//            group.enter()
//            (file as! PFFileObject).getDataInBackground{
//            (qData: Data?, error: Error?) -> Void in
//
//                self.img = UIImage(data: qData!)
//
//                group.leave()
//            }
//            group.notify(queue: .main) {
//                self.button2.setImage(self.img, for: [])
//            }
        
       // let query = CKQuery(recordType: "Question", predicate: NSPredicate(value: true))
        
       /* let queryOperation : CKQueryOperation = CKQueryOperation()
        queryOperation.query = query
        
        queryOperation.qualityOfService = .userInteractive
        queryOperation.recordFetchedBlock = { record in
            let asset = record.value(forKey: "content")
            let text2 = try! String(contentsOf: (asset as! CKAsset).fileURL, encoding: .utf8)
            let dat = text2.data(using: .utf8)
            let actual = try! JSONSerialization.jsonObject(with: dat!, options: []) as! [String : String]
            let x = actual["pic3"]!
            let data = NSData(base64Encoded: x, options: [])
            let tu = UIImage(data: data! as Data)
            self.img = tu
        }
        
        database.add(queryOperation)
        */
        
        /*let recordID = CKRecord.ID(recordName: "[tizzy]")
        
        database.fetch(withRecordID: recordID) { record, error in
            
            if let record = record, error == nil {
                
                //update your record here
                
                self.database.save(record) { _, error in
                    print("ERROR!!")
                }
            }
        }
        */
        
        /*let group = DispatchGroup()
        group.enter()
        database.perform(query, inZoneWith: nil){ (record, _) in
            //print(error)
            guard let records = record else { print("notget"); return }
            //self.notes = records
            let asset = records[0].value(forKey: "content")
            //let data = NSData(contentsOf: (asset as! CKAsset).fileURL)
            
            let text2 = try! String(contentsOf: (asset as! CKAsset).fileURL, encoding: .utf8)
            let dat = text2.data(using: .utf8)
            let actual = try! JSONSerialization.jsonObject(with: dat!, options: []) as! [String : String]
            
            let x = actual["pic3"]!
            
            let data = NSData(base64Encoded: x, options: [])
            let tu = UIImage(data: data! as Data)
            
            self.img = tu
            group.leave()
        }
        
        group.notify(queue: DispatchQueue.main) {
            print("任务结束")
        }
        self.button2.setImage(self.img, for: [])
        self.button2.reloadInputViews()
        */
    }
    
    @IBAction func click(_ sender: UIButton) {
            saveToCloud()
    }
    
    func saveToCloud(){
        var imageData:NSData = (accept["pic1"] as! UIImage).jpegData(compressionQuality: 0)! as NSData
        var strBase64 = imageData.base64EncodedString(options: [])
        newdic.updateValue(strBase64 as String, forKey: "pic1")
        
        imageData = (accept["pic2"] as! UIImage).jpegData(compressionQuality: 0)! as NSData
        strBase64 = imageData.base64EncodedString(options: [])
        newdic.updateValue(strBase64 as String, forKey: "pic2")
        
        imageData = (accept["pic3"] as! UIImage).jpegData(compressionQuality: 0)! as NSData
        strBase64 = imageData.base64EncodedString(options: [])
        very = strBase64
        pp = imageData
        newdic.updateValue(strBase64 as String, forKey: "pic3")
        
        imageData = (accept["pic4"] as! UIImage).jpegData(compressionQuality: 0)! as NSData
        strBase64 = imageData.base64EncodedString(options: [])
        newdic.updateValue(strBase64 as String, forKey: "pic4")
        
        let op1 = accept["op1"]
        let op2 = accept["op2"]
        let op3 = accept["op3"]
        let op4 = accept["op4"]
        let correct = accept["correct"]
        
        newdic.updateValue(op1 as! String, forKey: "op1")
        newdic.updateValue(op2 as! String, forKey: "op2")
        newdic.updateValue(op3 as! String, forKey: "op3")
        newdic.updateValue(op4 as! String, forKey: "op4")
        newdic.updateValue(correct as! String, forKey: "correct")
        
        print("kaishi")
        
        let user = PFObject(className: "Users")
        let question = try! JSONSerialization.data(withJSONObject: newdic, options: [])
        let file:PFFileObject = PFFileObject(data: question)!
        user.setObject(file , forKey: "question")
        
        print("before")
        
        user.saveInBackground{(success, error) in
            if success {
                print("Object saved")
            } else {
                if let error = error {
                    print(error)
                } else {
                    print("Error")
                }
            }
        }
        
        /*let jsonData = try! JSONSerialization.data(withJSONObject: newdic, options: [])
        let str = String(data: jsonData, encoding: .utf8)!
        //let fileURL = NSURL(string: str)
        let question = CKRecord(recordType: "Question")
        //question.setValue(str, forKey: "content")
        //let url = URL(str)
        
        let fil = "file.txt" //this is the file. we will write to and read from it
        
        //let text = "some text" //just a text
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
        fileURL = dir.appendingPathComponent(fil)
            
        //writing
        do {
            try str.write(to: fileURL, atomically: false, encoding: .utf8)
        }
        catch {/* error handling here */}
            
        //reading
            /*do {
                let text2 = try String(contentsOf: fileURL, encoding: .utf8)
            }
            catch {/* error handling here */}
            */
        }
        
        let file : CKAsset = CKAsset(fileURL: fileURL)
        question.setValue(file, forKey: "content")
        print(question.recordID)
        
        database.save(question){ (record, error) in
            print(error)
            guard record != nil else { print("nol") ; return }
            print("record saved")
            
        }
    */
        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        NotificationCenter.default.post(name: .userDidInteract, object: nil)
    }


}
