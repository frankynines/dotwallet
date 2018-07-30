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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        
        
        if (EtherWallet.account.hasAccount == true) {
            self.pushWalletHomeScreen()
        }
        
        do {
           let pKEY = try EtherWallet.account.privateKey(password: "")
            print(pKEY)
            print(EtherWallet.account.address!)
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
    
    @IBAction func iba_importWallet(){
        
        let alertView = UIAlertController.init(title: "Import Wallet", message: "Enter private key to restore wallet.", preferredStyle: .alert)
        
        alertView.addTextField { (inputField) in
            inputField.tag = 0
            inputField.placeholder = "Private Key"
        }
        
        alertView.addTextField { (inputField) in
            inputField.tag = 1
            inputField.placeholder = "Pincode"

        }
        
        alertView.addAction(UIAlertAction(title: "Enter", style: .default, handler: { (action) in
            
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
            
            self.importWallet(pKey: pKey, pass: pass)
            
        }))
        
        alertView.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        self.present(alertView, animated: true, completion: nil)
    
    }
    
    func createWallet(pass:String){
        do {
            try EtherWallet.account.generateAccount(password: pass)
            print(EtherWallet.account.address ?? String())
            let pKey = try EtherWallet.account.privateKey(password: pass)
            print(pKey)
            
            self.pushWalletHomeScreen();
            
        } catch {
            self.alertError(error: error)
        }
    }
    
    func importWallet(pKey:String, pass:String){
        
        do {
            try EtherWallet.account.importAccount(privateKey: pKey, password: pass)
            print(EtherWallet.account.address!)
            self.pushWalletHomeScreen()
        } catch {
            self.alertError(error: error)
        }
        
    }
    
    func pushWalletHomeScreen(){
        
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
