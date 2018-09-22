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
    
    var loginVC:PasswordLoginViewController?
    var inView: Bool?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true

        if (EtherWallet.account.hasAccount == true) {

            let publicAddress = EtherWallet.account.address?.lowercased()
            print(publicAddress)
            
            self.pushWalletHomeScreen()
            
//            let keychain = Keychain(service: publicAddress!)
//
//            do {
//
//                let pass = try keychain.get(publicAddress!)
//                print(pass)
//                //If user has not setup a passcode
//                if pass == nil {
//                    self.showLoginView(state: .Reset)
//                } else {
//                    self.showLoginView(state: .Unlock)
//                }
//
//            } catch {
//                print(error.localizedDescription)
//            }
            
        } else {
            self.welcomeMessage()
            self.animateBG()
        }

    }
    
    func welcomeMessage(){
        
        let alertView = UIAlertController.init(title: "Welcome to Dot Wallet", message: "This version of the wallet has been modified for RINKEBY testnet. Please only test with what you can afford to lose.", preferredStyle: .alert)
        
        alertView.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))

        alertView.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        
        self.present(alertView, animated: true, completion: nil)
        
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
    
    @IBAction func iba_importWallet(){
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "sb_ImportWalletViewController") as! ImportWalletViewController
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func showLoginView(state:PassState) {
        
        self.loginVC = (storyboard?.instantiateViewController(withIdentifier: "PasswordLoginViewController") as! PasswordLoginViewController)
        self.loginVC!.modalPresentationStyle = .overFullScreen
        self.loginVC!.delegate = self
        self.loginVC!.passState = state
        self.loginVC!.modalTitle = "Create Password"
        present(loginVC!, animated: false, completion: nil)
    }
    
    func createWalletWithPasscode(pass: String?) {
        self.createWallet(pass: pass!)
    }
    
    
    //WALLET CORE
    func createWallet(pass:String){

        do {
            try EtherWallet.account.generateAccount(password: pass)
            UserPreferenceManager.shared.setKey(key: "walletColor", object: "C0B9FF")
            let publicAddress = EtherWallet.account.address?.lowercased()
            let keychain = Keychain(service: publicAddress!)
            
            do {
                try keychain.set(pass, key: publicAddress!)
                self.pushWalletHomeScreen()
            } catch {
                self.alertError(error: error)
            }

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
    
    var testColors = ["696B7A",
                      "998AFF",
                      "64E5FF",
                      "0081FF",
                      "FF5757",
                      "FFB357",
                      "DCF14A",
                      "40E252",
                      "CDE6FF",
                      "DDDDDD",
                      "FF66C7",
                      "24294E",
                      "FFF100",
                      "BD10E0",
                      "1D1D1D",
                      "B8773C",
                      "7E3BA0",
                      "BFBFBF"]
    
    func randomColor() -> String {
        return self.testColors.randomElement()!
    }
       
    
}


