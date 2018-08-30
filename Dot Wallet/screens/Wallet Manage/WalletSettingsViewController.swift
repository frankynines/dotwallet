//
//  WalletSettingsViewController.swift
//  Dot Wallet
//
//  Created by Franky Aguilar on 8/7/18.
//  Copyright © 2018 Ninth Industries. All rights reserved.
//

import Foundation
import UIKit
import SafariServices
import Cache
import Toast_Swift
import KeychainAccess
import web3swift

class WalletSettingViewController:UITableViewController {
    
    @IBOutlet var ibo_publicAddress:UILabel?
    @IBOutlet var ibo_network:UILabel?
    
    @IBOutlet var ibo_colorView:UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Settings"
        self.navigationController?.isNavigationBarHidden = false
        
        self.ibo_network?.text = "Main Net"
        self.userColor()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        ibo_publicAddress?.text = EtherWallet.account.address
        
        self.userColor()
        
    }
    
    func userColor(){
        var walletColor:String?
        if let color = UserPreferenceManager.shared.getKeyObject(key: "walletColor"){
            walletColor = color
        } else {
            walletColor = "FFFFFF"
        }
        self.ibo_colorView?.backgroundColor = UIColor(hexString: walletColor!)
    }
    
    //community
    @IBAction func iba_joinTelegram(){
        let vc = SFSafariViewController(url: URL(string: "https://t.co/sSdJRf6ycb")!)
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func iba_presentPrivateKey(){
        
        do {
            let pKey = try EtherWallet.account.privateKey(password: "")
            let alert = UIAlertController(title: "Private Key", message: "This key is temporary for testing.\(pKey)", preferredStyle: .alert)
            
            print(pKey) // USED FOR DEBUGGING
            
            alert.addAction(UIAlertAction(title: "Copy", style: .default, handler: { (action) in
                UIPasteboard.general.string = pKey
            }))
            
            alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: { (action) in }))
            self.present(alert, animated: true, completion: nil)
        
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    @IBAction func iba_killCache(){
        self.view.makeToast("Cache has been cleared.")

        UserDefaults.standard.removeObject(forKey: "ETHBalance")
        TXHistoryCacheManager.shared.killStorage()
        TokenCacheManager.shared.killStorage()
        
        let publicAddress = EtherWallet.account.address?.lowercased()
        let keychain = Keychain(service: publicAddress!)
        keychain[publicAddress!] = nil
    }
    
    @IBAction func iba_killwallet(){
        
        self.iba_killCache()
        
        do {
            try EtherWallet.account.killKeystore()
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "sb_CreateWalletViewController")
            self.navigationController?.setViewControllers([vc!], animated: true)
        
        } catch {
            print(error.localizedDescription)
        }
    }
    
    var colorPicker:ColorViewController!
    
    @IBAction func iba_chooseColor(){
        
        self.colorPicker = (self.storyboard?.instantiateViewController(withIdentifier: "sb_ColorViewController") as! ColorViewController)
        self.navigationController?.pushViewController(self.colorPicker, animated: true)
    
    }
    
}
