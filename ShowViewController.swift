//
//  ShowViewController.swift
//  CameraApp
//
//  Created by hang yang on 2/1/19.
//  Copyright © 2019 hang yang. All rights reserved.
//

import UIKit
import CloudKit

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
    
    let database = CKContainer.default().publicCloudDatabase
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.hidesBackButton = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        print("appear")
       
    }
    
    
    @IBAction func test(_ sender: UIButton) {
        print("test!")
    }
    

    @IBAction func showact(_ sender: UIButton) {
      
        
        let query = CKQuery(recordType: "Question", predicate: NSPredicate(value: true))
        
        let queryOperation : CKQueryOperation = CKQueryOperation()
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
        
        
        
        
       /* database.perform(query, inZoneWith: nil){ (records, _) in
            //print(error)
            guard let records = records else { print("notget"); return }
            self.notes = records
            let asset = self.notes[0].value(forKey: "content")
            //let data = NSData(contentsOf: (asset as! CKAsset).fileURL)
            
            let text2 = try! String(contentsOf: (asset as! CKAsset).fileURL, encoding: .utf8)
            let dat = text2.data(using: .utf8)
            let actual = try! JSONSerialization.jsonObject(with: dat!, options: []) as! [String : String]
            
            let x = actual["pic3"]!
            
            let data = NSData(base64Encoded: x, options: [])
            let tu = UIImage(data: data! as Data)
            //let new = UIImage(cgImage: tu!.cgImage!, scale:1, orientation: UIImage.Orientation.upMirrored)
            //print(tu?.isEqual(self.accept["pic3"]))
            self.img = tu
        }*/
        
        
        self.button2.setImage(self.img, for: [])
        self.button2.reloadInputViews()
        
    }
    
    @IBAction func click(_ sender: UIButton) {
            saveToCloud()
    }
    
    func saveToCloud(){
        var imageData:NSData = (accept["pic1"] as! UIImage).pngData()! as NSData
        var strBase64 = imageData.base64EncodedString(options: [])
        newdic.updateValue(strBase64 as String, forKey: "pic1")
        
        imageData = (accept["pic2"] as! UIImage).pngData()! as NSData
        strBase64 = imageData.base64EncodedString(options: [])
        newdic.updateValue(strBase64 as String, forKey: "pic2")
        
        imageData = (accept["pic3"] as! UIImage).pngData()! as NSData
        strBase64 = imageData.base64EncodedString(options: [])
        very = strBase64
        pp = imageData
        newdic.updateValue(strBase64 as String, forKey: "pic3")
        
        imageData = (accept["pic4"] as! UIImage).pngData()! as NSData
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
        
        let jsonData = try! JSONSerialization.data(withJSONObject: newdic, options: [])
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
        
        database.save(question){ (record, error) in
            print(error)
            guard record != nil else { print("nol") ; return }
            print("record saved")
            
        }
    
    }

}

