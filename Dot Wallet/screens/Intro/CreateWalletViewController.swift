//
//  CreateWalletViewController.swift
//  Dot Wallet
//
//  Created by Franky Aguilar on 7/24/18.
//  Copyright © 2018 Ninth Industries. All rights reserved.
//

import Foundation
import UIKit

class CreateWalletViewController: UIViewController {
    
    var testPKeys = ["8037f8912d60c7813ba0144da9598e183e523c29912c940a36b29ce94e9fe511",
                     "5298699e698f9f6b5f5a385a4f99299b511e0b2457ad5c6094b62e32ff9dec08",
                     "f308cae045da27517efe44275ad23c44cce8d523cc9a3ad9e7aaba678dec52f2",
                     "1b5c152c59aa3b08ea070191d3396e169e66206782ac7be89c9a1bc91f68ee07"
                     ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        
        if (EtherWallet.account.hasAccount == true) {
            if  UserDefaults.standard.bool(forKey: "ISLIVE") == true {
                EtherWallet.shared.setToMainNet()
            }

            self.pushWalletHomeScreen()
        }
        
        do {
           let pKEY = try EtherWallet.account.privateKey(password: "")
        } catch {
            
        }
        
    }
    
    @IBAction func iba_createNewWallet(){
        
        let alertView = UIAlertController.init(title: "New Wallet", message: "Enter Pincode to secure wallet", preferredStyle: .alert)
        
        alertView.addTextField { (inputField) in
            inputField.tag = 0
            inputField.placeholder = "Pincode"
        }
        
        alertView.addAction(UIAlertAction(title: "Enter", style: .default, handler: { (action) in

            var pass = String()
            
            for inputField in alertView.textFields! {
                let field = inputField

                switch field.tag {
                case 0:
                    pass = field.text!
                default: break
                }
            }
            self.createWallet(pass: pass)
        }))
        
        alertView.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        
        self.present(alertView, animated: true, completion: nil)

    }
    @IBAction func iba_useTestWallet(button:UIButton) {
        
        let pkey = self.testPKeys[button.tag]
        self.importWallet(pKey: pkey, pass: "")
        
    }
    
    @IBAction func iba_importWallet(){
        
        let alertView = UIAlertController.init(title: "Import Wallet", message: "This will import your wallet onto the MAIN-NET. Use caution as this is not secure. Use at your own risk!", preferredStyle: .alert)
        
        alertView.addTextField { (inputField) in
            inputField.tag = 0
            inputField.placeholder = "Private Key"
        }
        
        alertView.addAction(UIAlertAction(title: "Import Wallet", style: .default, handler: { (action) in
            
            var pKey = String()
            var pass = String()
            
            for inputField in alertView.textFields! {
                let field = inputField
            
                switch field.tag {
                    case 0:
                        pKey = field.text!
                    case 1:
                        pass = field.text!
                default: break
                }
            }
            self.importWalletLive(pKey: pKey, pass: pass)
            
        }))
        
        alertView.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        self.present(alertView, animated: true, completion: nil)
    
    }
    
    func createWallet(pass:String){
        do {
            try EtherWallet.account.generateAccount(password: pass)
            let pKey = try EtherWallet.account.privateKey(password: pass)
            self.pushWalletHomeScreen();
            
        } catch {
            self.alertError(error: error)
        }
    }
    
    func importWalletLive(pKey:String, pass:String) {
        
        
        do {
            try EtherWallet.account.importAccount(privateKey: pKey, password: pass)
            UserDefaults.standard.set(true, forKey: "ISLIVE")
            EtherWallet.shared.setToMainNet()
            self.pushWalletHomeScreen()
            
        } catch {
            self.alertError(error: error)
        }
        
        

    }
    
    func importWallet(pKey:String, pass:String){
        
        do {
            try EtherWallet.account.importAccount(privateKey: pKey, password: pass)
            UserDefaults.standard.set(false, forKey: "ISLIVE")
            EtherWallet.shared.setToRopsten()
            self.pushWalletHomeScreen()
            
        } catch {
            self.alertError(error: error)
        }
        
    }
    
    func pushWalletHomeScreen(){
        print("WALLET \(WalletManagerShared.shared.isLive)")
        EtherWallet.balance.etherBalance { balance in
            UserDefaults.standard.set(balance, forKey: "ETHBalance")
        }
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "sb_WalletHomeViewController")
        self.navigationController?.setViewControllers([vc!], animated: true)
       
    
    }
    
    func alertError(error:Error){
        
        let alertView = UIAlertController.init(title: "Oops", message: error.localizedDescription, preferredStyle: .alert)
        
        alertView.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        
        self.present(alertView, animated: true, completion: nil)
        
    }
       
    
}
