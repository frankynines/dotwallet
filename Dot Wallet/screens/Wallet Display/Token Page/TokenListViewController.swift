//
//  WalletTokenListViewController.swift
//  Dot Wallet
//
//  Created by Franky Aguilar on 7/25/18.
//  Copyright © 2018 Ninth Industries. All rights reserved.
//

import Foundation
import UIKit
import Cache


class TokenListViewController:UIViewController, UITableViewDelegate, UITableViewDataSource, AddTokenViewControllerDelegate {
    
    var delegate:WalletPageViewControllerDelegate?
    
    @IBOutlet var ibo_tableHeader:UILabel?
    @IBOutlet var ibo_tokenTableView:UITableView!

    var tokens = [OERC20Token]()
    
    
    

    //Begin View
    override func viewDidLoad() {
        super.viewDidLoad()
    
        DispatchQueue.main.async {
            
            self.updateTokens()
        }
        self.ibo_tokenTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if self.tokens.count > 0 {
            self.ibo_tokenTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        }
    }
    
    @IBAction func iba_manageTokens(){
        let vc = UIStoryboard(name: "ERC20Tokens", bundle: nil).instantiateViewController(withIdentifier: "sb_AddTokenViewController") as! AddTokenViewController
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    func tokenManagementControllerSaved(vc:AddTokenViewController) {

        vc.dismiss(animated: true) {
            self.updateTokens()
        }
        
    }
    
    func updateTokens(){
        
        self.tokens.removeAll()
        
        let userStorage = try? Storage(
            diskConfig: DiskConfig(name: "userERC20"),
            memoryConfig: MemoryConfig(expiry: .never, countLimit: 10, totalCostLimit: 10),
            transformer: TransformerFactory.forCodable(ofType: [String : OERC20Token].self)
        )
        
        
        do {
            let key = EtherWallet.account.address?.lowercased()
            let tokenArray = try userStorage?.object(forKey:key!)
            for v in tokenArray! {
                self.tokens.append(v.value)
            }
            self.ibo_tableHeader?.text = "\(self.tokens.count) Tokens"
            
        } catch {
            print(error.localizedDescription)
        }
        
        self.ibo_tokenTableView.reloadData()

    
    }

    func loadToken(index:Int){
//        if self.tokensContracts.count == 0 {
//            return
//        }
//        let tokenAddress = self.tokensContracts[index]
//
//        do {
//            let token = try storage?.object(forKey: tokenAddress)
//            self.append([token!])
//            if index < self.tokensContracts.count - 1 {
//                self.loadToken(index: index + 1)
//            }
//        } catch {
//
//            EtherWallet.tokens.getTokenMetaData(contractAddress: tokenAddress) { (token) in
//                DispatchQueue.global(qos: .background).async {
//                    try? self.storage?.setObject(token, forKey: token.contractAddress!)
//                }
//                self.append([token])
//                if index < self.tokensContracts.count - 1 {
//                    self.loadToken(index: index + 1)
//                }
//            }
//
//        }
        
        
    }
    
     func append(_ objectsToAdd: [OERC20Token]) {
        for i in 0 ..< objectsToAdd.count {
                self.tokens.append(objectsToAdd[i])
                self.ibo_tokenTableView.insertRows(at: [IndexPath(item:self.tokens.count - 1, section:0)], with: UITableViewRowAnimation.automatic)
        }
        
        self.ibo_tableHeader?.text = String(self.tokens.count) + " Tokens"
    }
    
    //TABLE VIEW
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tokens.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "token") as! WalletTokenCell
        cell.alpha = 0;
        cell.setupCell(token: self.tokens[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Tap")
        self.presentAlert()
        
    }
    
    func presentAlert(){
        let alert = UIAlertController(title: "Some Token", message: "Need to build UI here...", preferredStyle: .alert)
    
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
        //
        })
    )
    
    self.present(alert, animated: true, completion: nil)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    }
}



class WalletTokenCell:UITableViewCell {
    
    @IBOutlet var iboTokenImage:UIImageView?
    @IBOutlet var iboTokenName:UILabel?
    @IBOutlet var iboTokenSymbol:UILabel?
    @IBOutlet var iboTokenBalance:UILabel?
    @IBOutlet var iboTokenFiat:UILabel?
    
    var  token:OERC20Token?
    
    func setupCell(token:OERC20Token){
    
        self.iboTokenName?.text = token.name
        self.iboTokenSymbol?.text = token.symbol
        
        self.token = token
        EtherWallet.tokens.getTokenImage(contractAddress: (token.address?.lowercased())!) { (image) in
            self.iboTokenImage?.image = image
        }
        
        self.syncTokenBalance(_tokenAddress: token.address)
        
    }

    func syncTokenBalance(_tokenAddress:String!){
        
            DispatchQueue.main.async {
                EtherWallet.balance.tokenBalance(contractAddress: _tokenAddress) { (balance) in
                    self.iboTokenBalance?.text = EtherWallet.balance.WeiToValue(wei: balance!, dec: (self.token?.decimals)!)
                }
            }

    }
}


