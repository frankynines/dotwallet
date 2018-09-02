//
//  CreateWalletViewController.swift
//  Dot Wallet
//
//  Created by Franky Aguilar on 7/24/18.
//  Copyright © 2018 Ninth Industries. All rights reserved.
//

import Foundation
import UIKit
import KeychainAccess

class CreateWalletViewController: UIViewController, PasswordLoginDelegate {
   
    var testPKeys = ["8037f8912d60c7813ba0144da9598e183e523c29912c940a36b29ce94e9fe511",
                     "5298699e698f9f6b5f5a385a4f99299b511e0b2457ad5c6094b62e32ff9dec08",
                     "f308cae045da27517efe44275ad23c44cce8d523cc9a3ad9e7aaba678dec52f2",
                     "1b5c152c59aa3b08ea070191d3396e169e66206782ac7be89c9a1bc91f68ee07"]
    
    var testColors = ["998AFF", "64E5FF", "0081FF", "FF5757", "FFB357", "DCF14A", "40E252",  "FF66C7",  "FFF100", "BD10E0", "7E3BA0", ]
    
    var loginVC:PasswordLoginViewController?
    var inView: Bool?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true

        if (EtherWallet.account.hasAccount == true) {

            let publicAddress = EtherWallet.account.address?.lowercased()
            let keychain = Keychain(service: publicAddress!)
            
            do {
                
                let pass = try keychain.get(publicAddress!)
                //If user has not setup a passcode
                if pass == nil {
                    self.showLoginView(state: .Reset)
                } else {
                    self.showLoginView(state: .Unlock)
                }
                
            } catch {
                print(error.localizedDescription)
            }
            
        } else {
            
            self.welcomeMessage()
            self.animateBG()

        }

    }
    
    func welcomeMessage(){
        
        let alertView = UIAlertController.init(title: "Welcome to Dot Wallet", message: "Wallet is now fully functional on the Main-Net. All test wallets have been switched over, and full send and receive functionality has been activated. Please only test with what you can afford to lose.", preferredStyle: .alert)
        
        alertView.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))

        
        alertView.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
        }))
        
        self.present(alertView, animated: true, completion: nil)
        
    }

    func animateBG() {
        
        if inView != true {
            return
        }
        
        UIView.animate(withDuration: 10, delay: 0, options: [.allowUserInteraction], animations: {
            self.view.backgroundColor = UIColor(hexString: self.randomColor())
        }) { (done) in
            self.animateBG()
        }
    }
    
    func randomColor() -> String {
        return self.testColors.randomElement()!
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.inView = true
        self.animateBG()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.inView = false
    }
    
    @IBAction func iba_createNewWallet(){
        self.showLoginView(state: .Create)
    }
    
    func showLoginView(state:PassState) {
        
        self.loginVC = (storyboard?.instantiateViewController(withIdentifier: "PasswordLoginViewController") as! PasswordLoginViewController)
        
        self.loginVC!.modalPresentationStyle = .overFullScreen
        self.loginVC!.delegate = self
        self.loginVC!.passState = state
        self.loginVC!.modalTitle = "Create Password"
        
        if state == .Unlock {
            self.loginVC!.modalTitle = "Enter Password"

            let publicAddress = EtherWallet.account.address?.lowercased()
            let keychain = Keychain(service: publicAddress!)
            do {
                let pass = try keychain.get(publicAddress!)
                self.loginVC?.kPass = pass
            } catch {
                print(error.localizedDescription)
            }
            
        }
        
        present(loginVC!, animated: false, completion: nil)
        
    }
    
    func setLoginPasscode(pass: String?) {
        if self.loginVC?.passState == .Create {
            self.createWallet(pass: pass!)
        }
    }
    
    func unlockWalletWithPasscode(pass: String?) {
        
        let publicAddress = EtherWallet.account.address?.lowercased()
        let keychain = Keychain(service: publicAddress!)
        do {
            try keychain.set(pass!, key: publicAddress!)
            self.loginVC?.kPass = pass
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    func setLoginSuccess() {
        self.pushWalletHomeScreen()
    }
    
    
    @IBAction func iba_useTestWallet(button:UIButton) {
        if button.tag == 0 {
            self.iba_createNewWallet()
            return
        }
        let pkey = self.testPKeys[button.tag - 1]
        self.importWalletLive(pKey: pkey, pass: "")
    }
    
    @IBAction func iba_importWallet(){

        let alertView = UIAlertController.init(title: "Import Wallet", message: "Provide your private key to import your wallet. This will import on the main-net. Note: we do not save, cache, or monitor your private key entry. Use wisely!", preferredStyle: .alert)
        
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
            try EtherWallet.account.generateAccount(password: "")
            UserPreferenceManager.shared.setKey(key: "walletColor", object: self.testColors[2])
            let publicAddress = EtherWallet.account.address?.lowercased()
            let keychain = Keychain(service: publicAddress!)
            
            do {
                try keychain.set(pass, key: publicAddress!)
                self.loginVC?.kPass = pass
            } catch let error {
                print(error)
            }

        } catch {
            self.alertError(error: error)
        }
    }
    
    func importWalletLive(pKey:String, pass:String) {
        
        do {
            try EtherWallet.account.importAccount(privateKey: pKey, password: "")
            self.pushWalletHomeScreen()
            UserPreferenceManager.shared.setKey(key: "walletColor", object: self.testColors[0])

        } catch {
            self.alertError(error: error)
        }
    }
    
    
    func pushWalletHomeScreen(){

        EtherWallet.balance.etherBalance { balance in
            UserDefaults.standard.set(balance, forKey: "ETHBalance")
        }
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "sb_WalletHomeViewController")
        
        self.loginVC = nil
        self.navigationController?.setViewControllers([vc!], animated: false)
       
    }
    
    func alertError(error:Error){
        
        let alertView = UIAlertController.init(title: "Oops", message: error.localizedDescription, preferredStyle: .alert)
        
        alertView.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        
        self.present(alertView, animated: true, completion: nil)
        
    }
       
    
}


