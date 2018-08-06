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
    
    var erc20TokenListURL = "https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/tokens/tokens-eth.json"
    
    var delegate:AddTokenViewControllerDelegate?
    var tokens = [OERC20Token]()
    var searched: [OERC20Token] = []
    
    var searchActive:Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func iba_dismiss(){
        self.delegate?.tokenManagementControllerSaved(vc:self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        EtherWallet.tokens.getERC20TokenList(url: erc20TokenListURL) { (result) in
            for token in result! {
                self.buildTokenObject(element: token.rawString()!)
            }
        }
    }
    
    
    
    @IBAction func iba_clearCache(){
        
        let userStorage = try? Storage(
            diskConfig: DiskConfig(name: "userERC20"),
            memoryConfig: MemoryConfig(expiry: .never, countLimit: 10, totalCostLimit: 10),
            transformer: TransformerFactory.forCodable(ofType: [OERC20Token].self)
        )
        
        print("Clear Cache")
        do {
            try? userStorage?.removeObject(forKey: "UserTokens")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func buildTokenObject(element:String) {
        let data = element.data(using: .utf8)!
        do {
            let element = try JSONDecoder().decode(OERC20Token.self, from: data)
            self.tokens.append(element)
        } catch {
            return
        }
        self.ibo_tableView?.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searched.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TokenListCell
            cell.setupCell(token: self.searched[indexPath.row])
        return cell
    }
    
    // SEARCH BAR
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        self.ibo_tableView?.reloadData()
        
        searched = self.tokens.filter({ (ercToken:OERC20Token) -> Bool in
            return (ercToken.name?.lowercased().contains(searchText.lowercased()))!
        })
        
        if(searched.count == 0){
            searchActive = false;
        } else {
            searchActive = true;
        }
        self.ibo_tableView?.reloadData()
    }
    
}

class TokenListCell:UITableViewCell {
    
    @IBOutlet var iboTokenImage:UIImageView?
    @IBOutlet var iboTokenName:UILabel?
    @IBOutlet var iboTokenSymbol:UILabel?
    @IBOutlet var iboSwitch:UISwitch?
    
    var tokenAddress:String!
    var _token:OERC20Token!
    
    

    func setupCell(token:OERC20Token){
        
        self.iboTokenName?.text = token.name
        self.iboTokenSymbol?.text = token.symbol
        self.iboTokenImage?.image = nil
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
        
        let userStorage = try? Storage(
            diskConfig: DiskConfig(name: "userERC20"),
            memoryConfig: MemoryConfig(expiry: .never, countLimit: 10, totalCostLimit: 10),
            transformer: TransformerFactory.forCodable(ofType: [OERC20Token].self)
        )
        
        print("Is On \(swtch.isOn)")
        
        var array = [OERC20Token]()
        
        do {
            let tokenArray = try userStorage?.object(forKey:"UserTokens")
            array = tokenArray!
        } catch { print(error.localizedDescription)}
        
        do {
            array.append(self._token)
            print("ADD TO STORAGE")
            try userStorage?.setObject(array, forKey:"UserTokens")
        } catch { }
        
    }
    
    

}


