//
//  ViewController.swift
//  FuyuWallet
//
//  Created by Franky Aguilar on 7/22/18.
//  Copyright © 2018 Ninth Industries. All rights reserved.
//

import UIKit
import Foundation
import web3swift

class WalletHomeViewController: UIViewController {
    
    @IBOutlet var iboPrivateKey: UILabel!
    @IBOutlet var iboPublicKey: UILabel!
    
    @IBOutlet var iboBalance: UIButton!

    public var pass:String!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (EtherWallet.account.hasAccount == true && pass.isEmpty == false) {
            do {
                
            } catch {
                
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    
    
    @IBAction func getBalance(){
        
        do {
            //SYNC BALANCE
            try EtherWallet.balance.etherBalanceSync()
            
            EtherWallet.balance.etherBalance { balance in
                self.iboBalance.setTitle(balance, for: .normal)
                print("Balance:", balance ?? String())
            }
            
        } catch {
            
        }
        
    }
    
    @IBAction func displaySendViewController(){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "sb_SendViewController")
        present(vc!, animated: true) {
            //
        }
    }
    
    @IBAction func iba_copyPublicAddress(){
        UIPasteboard.general.string = iboPublicKey.text
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

