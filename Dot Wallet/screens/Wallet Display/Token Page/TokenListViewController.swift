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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        DispatchQueue.main.async {
            self.loadTokens()
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
            self.loadTokens()
        }
    }
    
    func loadTokens(){
        self.tokens.removeAll()
        self.tokens = TokenCacheManager.shared.loadCachedTokens()
        self.ibo_tokenTableView.reloadData()
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
        cell.setupCell(token: self.tokens[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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


