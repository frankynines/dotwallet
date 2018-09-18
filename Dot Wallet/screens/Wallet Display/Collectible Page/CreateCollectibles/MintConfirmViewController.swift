//
//  MintConfirmViewController.swift
//  Dot Wallet
//
//  Created by Franky Aguilar on 9/18/18.
//  Copyright © 2018 Ninth Industries. All rights reserved.
//

import Foundation
import UIKit
import Firebase

import SafariServices

class MintConfirmViewController : UIViewController {
    
    var userImage:UIImage?
    
    @IBOutlet var ibo_selectedImage:UIImageView!
    @IBOutlet var ibo_fieldName:UITextField?
    @IBOutlet var ibo_fieldDescription:UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let rightButton = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(iba_mintItem))
        self.navigationItem.rightBarButtonItem = rightButton
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.ibo_selectedImage.image = userImage
    }
    
    @objc func iba_mintItem(){
        
        let storage = Storage.storage()
        var storageRef = storage.reference()

        let timestamp = Date().timeIntervalSinceNow
        let fileName = "dwc\(timestamp)image.png"
        let storagePath = "gs://dotwallet.appspot.com/\(fileName)"
        
        storageRef = storage.reference(forURL: storagePath)
        
        let imagedata = UIImagePNGRepresentation(userImage!)
        
        storageRef.putData(imagedata!, metadata: nil) { (metadata, error) in
           // guard let metadata = metadata else { return }

            storageRef.downloadURL { (url, error) in
                guard let downloadURL = url else { return }
                let cleanurl = "https://storage.googleapis.com/dotwallet.appspot.com/\(fileName)"
                self.addItemToAPI(fileURL: cleanurl)
            }
        }
        
    }
    
    func addItemToAPI(fileURL:String){
        
        var ref: DatabaseReference!
        let package:[String:Any] = [
            "atrributes":[
                "tags":[
                    "Tag", "Tag"
                ]],
            "background_color":"FFFFFF",
            "image":fileURL,
            "type":"png",
            "name":"Some Name",
            "description":"Some Description",
            "creation_timestamp":self.getCurrentDate()
        ]
        ref = Database.database().reference()
        let key = ref.child("collectibles").childByAutoId()
        key.updateChildValues(package) { (error, reference) in
            //
            if error != nil {
                self.showAlert(title:"Oops", message: (error?.localizedDescription)!)
            }
            self.showAlert(title:"Complete", message: reference.description())
        }
    }
    
    func showAlert(title: String, message:String){
        
        let alertView = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        
        alertView.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        alertView.addAction(UIAlertAction(title: "View JSON", style: .default, handler: { (action) in
            
            let url = URL(string: "\(message).json")
            let vc = SFSafariViewController(url: url!)
            self.navigationController?.pushViewController(vc, animated: true)
            
        }))
        self.present(alertView, animated: true, completion: nil)
    
    }
    
    func getCurrentDate() -> (String){
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy"
        let result = formatter.string(from: date)
        return result
    }
}
