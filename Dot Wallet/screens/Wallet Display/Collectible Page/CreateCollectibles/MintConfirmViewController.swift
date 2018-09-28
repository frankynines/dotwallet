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


class MintConfirmViewController : UIViewController, PasswordLoginDelegate, GasAdjustViewControllerDelegate {
   
    var package = [String:Any]()

    
    @IBOutlet weak var ibo_selectedImage:UIImageView!
    var userImage:UIImage?
    
    @IBOutlet weak var ibo_itemName:UILabel?
    @IBOutlet weak var ibo_itemDescription:UILabel?
    
    @IBOutlet weak var ibo_gasPrice:RoundButton?
    
    var gasPrice:Int?
    var gasLimit:Int?
    
    var passcodeVC:PasswordLoginViewController!
    
    var blobURL:String?
    var referenceKey:String?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let rightButton = UIBarButtonItem(title: "Mint", style: .done, target: self, action: #selector(iba_mintItem))
        self.navigationItem.rightBarButtonItem = rightButton
        
        EtherWallet.balance.etherBalance { (balance) in
            self.title = "Balance: \(balance!)"
        }
        
        self.updateGas()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.ibo_selectedImage.image = userImage
        
        self.ibo_itemName?.text = self.package["name"] as? String
        self.ibo_itemDescription?.text = self.package["description"] as? String
    }
    
    func updateGas(){
        
        let params = [EtherWallet.account.address!, "https://storage.googleapis.com/dotwallet.appspot.com/o12345DotWalletCollectibleI.png", "12345DotWalletCollectibleI"] as [Any]
        
        EtherWallet.gas.gasForContractMethod(contractAddress: "0xa12d5111cb7fd6c285faa81530eb5c4dfcea51e7", methodName: "mintCollectible", methodParams: params) { (error, gasPrice, gasLimit) in
            
            self.gasLimit = gasLimit
            self.gasPrice = gasPrice
            
            let total = gasLimit! * gasPrice!
            let totalFee = EtherWallet.balance.WeiToValue(wei: String(total), dec: 10)
            self.ibo_gasPrice?.setTitle(totalFee!, for: .normal)
        }
       
    }
    
    @IBAction func iba_adjustGas(){
        let storyboard = UIStoryboard(name: "GasAdjustment", bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! GasAdjustViewController
        vc.delegate = self
        vc.gasPrice = self.gasPrice
        vc.gasLimit = self.gasLimit
        self.present(vc, animated: true, completion: nil)
    }
    
    func gasAdjustedWithValues(vc: GasAdjustViewController, gasLimit: Int, gasPrice: Int, totalCost: String) {
        
        vc.dismiss(animated: true) {
            self.gasPrice = gasPrice
            self.gasLimit = gasLimit
            
            self.ibo_gasPrice?.setTitle(totalCost, for: .normal)
        }
    }
    
    @objc func iba_mintItem(){
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
    
    func passcodeVerified(vc: PasswordLoginViewController, pass:String?) {
        
        vc.dismiss(animated: false) {
            
            self.view.makeToastActivity(.center)
            
            if (self.blobURL?.isEmpty == false || self.referenceKey?.isEmpty == false) {
                self.updateBlock(tokenURI: self.blobURL!, key:self.referenceKey!, pass:pass!)
                return
            }
            
            let storage = Storage.storage()
            var storageRef = storage.reference()
            
            let timestamp = Date().timeIntervalSince1970
            let fileName = "dwc\(timestamp)image.png"
            let storagePath = "gs://dotwallet.appspot.com/\(fileName)"
            
            storageRef = storage.reference(forURL: storagePath)
            
            let imagedata = UIImagePNGRepresentation(self.userImage!)
            
            storageRef.putData(imagedata!, metadata: nil) { (metadata, error) in
                
                storageRef.downloadURL { (url, error) in
                    let cleanurl = "https://storage.googleapis.com/dotwallet.appspot.com/\(fileName)"
                    self.addItemToAPI(fileURL: cleanurl, pass:pass!)
                }
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
                self.showAlert(message: (error?.localizedDescription)!, success: false)
                return
            }
            self.blobURL = "\(reference).json"
            self.referenceKey = reference.key
            
            self.updateBlock(tokenURI: self.blobURL!, key:self.referenceKey!, pass:pass)
        }
    }
    
    func updateBlock(tokenURI:String, key:String, pass:String){
        let params = [EtherWallet.account.address, tokenURI, key]
        
        EtherWallet.transaction.sendContractMethod(methodName: "mintCollectible",
                                                   methodParams: params,
                                                   pass: pass,
                                                   gasPrice: self.gasPrice!,
                                                   gasLimit: self.gasLimit!) { (completion, result) in
                                                    
            self.showAlert(message: result!, success: completion!)
        }
        
    }
    
    func showAlert(message:String, success:Bool){
        
        var alertTitle = ""
        var alertMessage = ""
        
        if success == true {
            alertTitle = "Success"
            alertMessage = "Please allow 3-5 mins for your item to display. TX: \(message)"
        } else {
            alertTitle = "Failed"
            alertMessage = "Transaction Failed, try increasing gas. \(message)"
        }
        
        let alertView = UIAlertController.init(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        
        alertView.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            if success == true {
                self.dismiss(animated: true, completion: nil)
            }
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
