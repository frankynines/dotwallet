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
class WalletHomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    
    @IBOutlet var ibo_tableView:UITableView!
    
    var tokens = ["0xe3818504c1b32bf1557b16c238b2e01fd3149c17",
                  "0x0abdace70d3790235af448c88547603b945604ea",
                  "0xf230b790e05390fc8295f4d3f60332c93bed42e2",
                  "0x0d8775f648430679a709e98d2b0cb6250d2887ef",
                  "0xe3818504c1b32bf1557b16c238b2e01fd3149c17"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true

        
        self.getTransactions()
        
    }
    
    func getTransactions(){
        EtherWallet.transaction.getTransactionHistory(address: EtherWallet.account.address!)
    }
    
   
    
    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.ibo_tableView.reloadData()

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
    
    //TABLE VIEW
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tokens.count + 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "main") as! WalletTokenMain
            cell.setupCell()
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "token") as! WalletTokenCell
            cell.setupCell(_tokenAddress: self.tokens[indexPath.row - 1])
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }
    
}

class WalletTokenMain:UITableViewCell {
    
    @IBOutlet var iboPrivateKey: UILabel!
    @IBOutlet var iboPublicKey: UILabel!
    @IBOutlet var iboBalance: UIButton!
    @IBOutlet var iboQRCode: UIImageView!
    
    func setupCell(){
        
        if (EtherWallet.account.hasAccount == true) {
            self.iboPublicKey.text = EtherWallet.account.address
            self.iboBalance.setTitle("0.00", for: .normal)
            
            let qrCode = QRCode(EtherWallet.account.address!)
            iboQRCode.image = qrCode?.image
            
            self.refreshBalance()
        }
    }
    
    @IBAction func refreshBalance(){
        
        EtherWallet.balance.etherBalance { balance in
            self.iboBalance.setTitle(balance, for: .normal)
            print("Balance:", balance ?? String())
        }
        
        
        
    }
    
    
    
}

class WalletTokenCell:UITableViewCell {
    
    @IBOutlet var iboTokenImage:UIImageView!
    @IBOutlet var iboTokenName:UILabel!
    @IBOutlet var iboTokenSymbol:UILabel!
    @IBOutlet var iboTokenBalance:UILabel!
    @IBOutlet var iboTokenFiat:UILabel!
    
    var tokenImageAddress = "https://raw.githubusercontent.com/trustwallet/tokens/master/images/"
    
    func setupCell(_tokenAddress:String!){
        
        let imageURL = tokenImageAddress + _tokenAddress + ".png"
        do {
            let imgdata = try Data(contentsOf: URL(string: imageURL)!)
            self.iboTokenImage.image = UIImage(data: imgdata)
        } catch {
            print("Failed to load token image")
        }
        
        self.syncTokenBalance(_tokenAddress: _tokenAddress)
        
    }
    
    func syncTokenBalance(_tokenAddress:String!){
        EtherWallet.balance.tokenBalance(contractAddress: _tokenAddress) { (balance) in
            self.iboTokenBalance.text = balance
        }
        
        EtherWallet.tokens.getTokenMetaData(contractAddress: _tokenAddress, param: "name") { (result) in
            self.iboTokenName.text = result
        }
        
        EtherWallet.tokens.getTokenMetaData(contractAddress: _tokenAddress, param: "symbol") { (symbol) in
            self.iboTokenSymbol.text = symbol
        }

        
        
        
        
       
    }
}

