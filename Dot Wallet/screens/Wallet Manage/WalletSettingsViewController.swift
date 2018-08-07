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

class WalletSettingViewController:UITableViewController {
    
    @IBOutlet var ibo_publicAddress:UILabel?
    @IBOutlet var ibo_network:UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Settings"
        self.navigationController?.isNavigationBarHidden = false
        
        if  UserDefaults.standard.bool(forKey: "ISLIVE") == true {
            self.ibo_network?.text = "Web3 Main Net"
        } else {
            self.ibo_network?.text = "Ropsten Test Net"
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        ibo_publicAddress?.text = EtherWallet.account.address
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
            alert.addAction(UIAlertAction(title: "Copy", style: .default, handler: { (action) in
                UIPasteboard.general.string = pKey

            }))
            
            alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: { (action) in
                
            }))
            self.present(alert, animated: true, completion: nil)
        } catch {
            print("No PKEY")
            
        }
    }
    
    @IBAction func iba_killCache(){
        UserDefaults.standard.removeObject(forKey: "ETHBalance")
        
        let userStorage = try? Storage(
            diskConfig: DiskConfig(name: "userERC20"),
            memoryConfig: MemoryConfig(expiry: .never, countLimit: 10, totalCostLimit: 10),
            transformer: TransformerFactory.forCodable(ofType: [OERC20Token].self)
        )
        
        print("Clear Cache")
        do {
            try? userStorage?.removeAll()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @IBAction func iba_killwallet(){
        
        self.iba_killCache()
        
        do {
            try EtherWallet.account.killKeystore()
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "sb_CreateWalletViewController")
            
            UserDefaults.standard.removeObject(forKey: "ISLIVE")

                
            self.navigationController?.setViewControllers([vc!], animated: true)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    
    
}
