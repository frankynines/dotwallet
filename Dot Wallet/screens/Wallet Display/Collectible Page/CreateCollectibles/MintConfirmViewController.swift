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
import Toast_Swift
import SafariServices
import KeychainAccess


class MintConfirmViewController : UIViewController, PasswordLoginDelegate {
    
    @IBOutlet weak var ibo_selectedImage:UIImageView!
    var userImage:UIImage?
    
    @IBOutlet weak var ibo_itemName:UILabel?
    @IBOutlet weak var ibo_itemDescription:UILabel?
    
    @IBOutlet weak var ibo_gasFee:UILabel?
    
    var package = [String:Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let rightButton = UIBarButtonItem(title: "Mint", style: .done, target: self, action: #selector(iba_mintItem))
        self.navigationItem.rightBarButtonItem = rightButton
        
        EtherWallet.balance.etherBalance { (balance) in
            self.title = "Balance: \(balance!)"
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.ibo_selectedImage.image = userImage
        
        self.ibo_itemName?.text = self.package["name"] as? String
        self.ibo_itemDescription?.text = self.package["description"] as? String
        
        self.updateGas()
    }
    
    func updateGas(){
        
        let params = [EtherWallet.account.address!, "https://storage.googleapis.com/dotwallet.appspot.com/o12345DotWalletCollectibleI.png", "12345DotWalletCollectibleI"] as [Any]
        
        var gas:String?
        
        do {
             gas = try EtherWallet.gas.gasForContractMethod(contractAddress: "0xa12d5111cb7fd6c285faa81530eb5c4dfcea51e7", methodName: "mintCollectible", methodParams: params)
            
        } catch {
            gas = "1000000"
        }
        gas = EtherWallet.balance.WeiToValue(wei: gas!, dec: 9)
        ibo_gasFee!.text = "Gas Estimate: \(gas!)"
    }
    
    var passcodeVC:PasswordLoginViewController!

    
    @objc func iba_mintItem(){
        
        //SECURITY CHECK
        let publicAddress = EtherWallet.account.address?.lowercased()
        let keychain = Keychain(service: publicAddress!)
        do {
            
            let pass = try keychain.get(publicAddress!)
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            self.passcodeVC = (storyboard.instantiateViewController(withIdentifier: "PasswordLoginViewController") as! PasswordLoginViewController)
            self.passcodeVC!.modalPresentationStyle = .overFullScreen
            self.passcodeVC!.delegate = self
            self.passcodeVC!.passState = .Unlock
            self.passcodeVC!.modalTitle = "Enter Passcode"
            self.passcodeVC!.kPass = pass
            present(passcodeVC!, animated: false, completion: nil)
            
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    func passcodeVerified(pass:String?) {
        
        self.view.makeToastActivity(.center)
        
        let storage = Storage.storage()
        var storageRef = storage.reference()
        
        let timestamp = Date().timeIntervalSince1970
        let fileName = "dwc\(timestamp)image.png"
        let storagePath = "gs://dotwallet.appspot.com/\(fileName)"
        
        storageRef = storage.reference(forURL: storagePath)
        
        let imagedata = UIImagePNGRepresentation(userImage!)
        
        storageRef.putData(imagedata!, metadata: nil) { (metadata, error) in
            
            storageRef.downloadURL { (url, error) in
                let cleanurl = "https://storage.googleapis.com/dotwallet.appspot.com/\(fileName)"
                self.addItemToAPI(fileURL: cleanurl, pass:pass!)
            }
        }
        
    }
    
    func addItemToAPI(fileURL:String, pass:String){
        
        var ref: DatabaseReference!
        let _package:[String:Any] = [
            "background_color":"FFFFFF",
            "image":fileURL,
            "type":"png",
            "creation_timestamp":self.getCurrentDate()
        ]
        
        self.package.merge(_package) { (_, some) -> Any in
            some
        }
        
        ref = Database.database().reference()
        let key = ref.child("collectibles").childByAutoId()
        key.updateChildValues(self.package) { (error, reference) in
            
            if error != nil {
                self.showAlert(title:"Oops", message: (error?.localizedDescription)!)
                return
            }
            let blobURL = "\(reference).json"
            self.updateBlock(tokenURI: blobURL, key:reference.key, pass:pass)
        }
    }
    
    func updateBlock(tokenURI:String, key:String, pass:String){
        
        let params = [EtherWallet.account.address, tokenURI, key]
        
        EtherWallet.transaction.sendContractMethod(methodName: "mintCollectible", methodParams: params, pass: pass) { (completion, result) in
            self.showAlert(title: "Completed", message: result!)
        }
        
    }
    
    func showAlert(title: String, message:String){
        
        let alertView = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        
        alertView.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
        }))
      
        self.view.hideToastActivity()
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


//BEGIN EDITOR CLASS
class InputScreenPageViewController: UIViewController {
    
    @IBOutlet weak var ibo_inputLabel:UILabel?
    @IBOutlet weak var ibo_inputField:UITextView?
    
    var tag:Int!
    
    var package = [String:Any]()
    
    var key:String?
    var inputLabel:String?
    
    var userImage:UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let rightButton = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(iba_nextItem))
        self.navigationItem.rightBarButtonItem = rightButton
        
        ibo_inputField?.becomeFirstResponder()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.ibo_inputLabel?.text = inputLabel
    }
    
    @objc func iba_nextItem() {
        
        self.package[key!] = ibo_inputField?.text
        
        if (self.tag == 0){
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "sb_InputScreenPageViewController") as! InputScreenPageViewController
            vc.userImage = self.userImage
            vc.package = self.package
            vc.key = "description"
            vc.inputLabel = "Add a Description"
            vc.tag = 1
            self.navigationController?.pushViewController(vc, animated: true)
        
        }
        
        if (self.tag == 1){
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "sb_MintConfirmViewController") as! MintConfirmViewController
            vc.userImage = self.userImage
            vc.package = self.package
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
}
