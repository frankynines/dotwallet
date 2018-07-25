//
//  ReceiveViewController.swift
//  Dot Wallet
//
//  Created by Franky Aguilar on 7/25/18.
//  Copyright © 2018 Ninth Industries. All rights reserved.
//

import Foundation
import UIKit
import QRCode

class ReceiveViewController:UIViewController {
    
    @IBOutlet var ibo_publicAddress:UILabel!
    @IBOutlet var ibo_QRCode:UIImageView!
    
    var publicAddress:String!
    
    override func viewDidLoad() {
        
        self.publicAddress = EtherWallet.account.address
        super.viewDidLoad()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.ibo_publicAddress.text = EtherWallet.account.address
        
        let qrCode = QRCode(EtherWallet.account.address!)
        self.ibo_QRCode.image = qrCode?.image

        super.viewWillAppear(animated)
    }
    
    @IBAction func iba_sharePublicAddress(){
    
    }
    
    @IBAction func iba_copyAddress(){
        UIPasteboard.general.string = EtherWallet.account.address
    }
}
