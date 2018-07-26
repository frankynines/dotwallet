//
//  WalletTokenListViewController.swift
//  Dot Wallet
//
//  Created by Franky Aguilar on 7/25/18.
//  Copyright © 2018 Ninth Industries. All rights reserved.
//

import Foundation
import UIKit

protocol WalletTokenViewControllerDelegate {
    func walletTokenSelected(row:Int)
    func walletTokenStretchHeader(rect:CGRect)
}

class WalletTokenViewController:UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var delegate: WalletTokenViewControllerDelegate?
    
    var tokens = [String]()
    @IBOutlet var ibo_tokenTableView:UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.ibo_tokenTableView.contentInset = UIEdgeInsets(top: 250, left: 0, bottom: 50, right: 0)
        super.viewWillAppear(animated)
    }
    
    //TABLE VIEW
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tokens.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "token") as! WalletTokenCell
        cell.alpha = 0;
        DispatchQueue.global(qos: .background).async {
            // Call your background task
            DispatchQueue.main.async {
                cell.setupCell(_tokenAddress: self.tokens[indexPath.row])
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.walletTokenSelected(row: indexPath.row)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = 1 - (scrollView.contentOffset.y + 1)
        let height = min(max(y, 250), 800)
        self.delegate?.walletTokenStretchHeader(rect: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: height))
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
            self.iboTokenImage.image = UIImage(named: "icon_token_erc20.png")
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
        
        self.alpha = 1
        
    }
}
