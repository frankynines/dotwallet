//
//  WalletHeaderViewController.swift
//  Dot Wallet
//
//  Created by Franky Aguilar on 7/25/18.
//  Copyright © 2018 Ninth Industries. All rights reserved.
//

import Foundation
import UIKit

protocol WalletHeaderDelegate {
    func iba_presentReceiveModal()
}

class WalletHeaderViewController:UIViewController{
    
    var delegate:WalletHeaderDelegate?
    //HEADER
    @IBOutlet var iboPublicKey: UILabel!
    @IBOutlet var iboBalance: UIButton!
    
    @IBOutlet var viewCard:UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewCard.layer.shadowRadius = 5
        viewCard.layer.shadowOpacity = 0.5
        viewCard.layer.shadowOffset = CGSize(width: 2, height: 2)
        viewCard.layer.shadowColor = UIColor.black.cgColor
        viewCard.layer.cornerRadius = 20
        self.setupHeaderView()
        super.viewWillAppear(animated)
    }
    
    func setupHeaderView(){
        
        if (EtherWallet.account.hasAccount == true) {
            self.iboPublicKey.text = EtherWallet.account.address
            self.iboBalance.setTitle("0.00", for: .normal)
            
            //            let qrCode = QRCode(EtherWallet.account.address!)
            //            iboQRCode.image = qrCode?.image
            
            self.refreshBalance()
        }
    }
    
    @IBAction func refreshBalance(){
        
        EtherWallet.balance.etherBalance { balance in
            self.iboBalance.setTitle(balance!, for: .normal)
        }
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
    
    @IBAction func iba_copyPublicAddress(){
        UIPasteboard.general.string = EtherWallet.account.address
    }
    
    @IBAction func iba_presentSendView(){
        let vc = storyboard?.instantiateViewController(withIdentifier: "sb_SendViewController") as! SendViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func iba_presentReceiveModal(){
        print("Show Receive")
        self.delegate?.iba_presentReceiveModal()
    }
    
    
    
}
