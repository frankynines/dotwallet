//
//  AddTokenViewController.swift
//  Dot Wallet
//
//  Created by Franky Aguilar on 8/5/18.
//  Copyright © 2018 Ninth Industries. All rights reserved.
//

import Foundation
import UIKit
import Cache

protocol AddTokenViewControllerDelegate {
    func tokenManagementControllerSaved(vc:AddTokenViewController)
}

class AddTokenViewController:UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet var ibo_tableView:UITableView?
    
    //LIST OF ERC20 TOKENS
    var erc20TokenListURL = "https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/tokens/tokens-eth.json"
    
    var delegate:AddTokenViewControllerDelegate?
    var tokens = [OERC20Token]()
    var allTokens: [OERC20Token] = []
    var searchFilter: [OERC20Token] = []
    
    var searchActive:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func iba_dismiss(){
        self.delegate?.tokenManagementControllerSaved(vc:self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadCacheTokens()
        
        EtherWallet.tokens.getERC20TokenList(url: erc20TokenListURL) { (result) in
            for token in result! {
                self.buildTokenObject(element: token.rawString()!)
            }
        }
    }
    
    func loadCacheTokens(){
        
        self.tokens.removeAll()
        self.tokens = TokenCacheManager.shared.loadCachedTokens()
        self.ibo_tableView?.reloadData()
        
    }
    
    func buildTokenObject(element:String) {
        let data = element.data(using: .utf8)!
        do {
            let element = try JSONDecoder().decode(OERC20Token.self, from: data)
            self.allTokens.append(element)
        } catch {
            return
        }
        self.ibo_tableView?.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 && !searchActive {
            return self.tokens.count
        }
        return self.searchFilter.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if !searchActive {
        return 2
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 && !searchActive{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TokenListCell
            cell.setupCell(token: self.tokens[indexPath.row])
            cell.iboSwitch?.isOn = true
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TokenListCell
        cell.setupCell(token: self.searchFilter[indexPath.row])
        cell.iboSwitch?.isOn = false
        return cell
    }
    
    // SEARCH BAR
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchText == ""){
            
            self.searchActive = false;
            self.searchFilter.removeAll()
            loadCacheTokens()
            
        } else {
            self.ibo_tableView?.reloadData()
            self.searchFilter = self.allTokens.filter({ (ercToken:OERC20Token) -> Bool in
            return (ercToken.name?.lowercased().contains(searchText.lowercased()))!
            })
            searchActive = true;
            self.ibo_tableView?.reloadData()
            
        }
    }
    
}

class TokenListCell:UITableViewCell {
    
    @IBOutlet var iboTokenImage:UIImageView?
    @IBOutlet var iboTokenName:UILabel?
    @IBOutlet var iboTokenSymbol:UILabel?
    @IBOutlet var iboTokenAddress:UILabel?
    @IBOutlet var iboSwitch:UISwitch?
    
    var tokenAddress:String!
    var _token:OERC20Token!
    
    func setupCell(token:OERC20Token){
        
        self.iboTokenName?.text = token.name
        self.iboTokenSymbol?.text = token.symbol
        self.iboTokenImage?.image = nil
        self.iboTokenAddress?.text = token.address
        self.tokenAddress = token.address
        
        iboSwitch?.isOn = false
        
        _token = token
        
        DispatchQueue.global(qos: .background).async {
            
            EtherWallet.tokens.getTokenImage(contractAddress: (token.address?.lowercased())!) { (image) in
            
                DispatchQueue.main.async {
                    self.iboTokenImage?.image = image
                }
            }
        }
    
    }
    
    @IBAction func switchToken(swtch:UISwitch) {
        
        if swtch.isOn {
            TokenCacheManager.shared.saveTokenToCache(token: self._token)
        } else {
            TokenCacheManager.shared.removeTokenToCache(tokenAddress: self._token.address!)
        }

    }
   
    
    

}


