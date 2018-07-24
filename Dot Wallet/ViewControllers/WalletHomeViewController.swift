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
import QRCode
class WalletHomeViewController: UIViewController {
    
    @IBOutlet var iboPrivateKey: UILabel!
    @IBOutlet var iboPublicKey: UILabel!
    
    @IBOutlet var iboBalance: UIButton!

    @IBOutlet var iboQRCode: UIImageView!
    public var pass:String!
    
    var publicAddress: String!
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true

        if (EtherWallet.account.hasAccount == true) {
            publicAddress = EtherWallet.account.address
            iboPublicKey.text = publicAddress
            let qrCode = QRCode(publicAddress)
            iboQRCode.image = qrCode?.image
            
            self.getBalance()
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
        UIPasteboard.general.string = EtherWallet.account.address
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func iba_killwallet(){
        do {
            try EtherWallet.account.killKeystore()
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "sb_CreateWalletViewController")
            self.navigationController?.setViewControllers([vc!], animated: true)
        } catch {
            print(error.localizedDescription)
        }
    }


}

