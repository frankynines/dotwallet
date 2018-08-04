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


class TokenListViewController:UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var delegate:WalletPageViewControllerDelegate?
    
    @IBOutlet var ibo_tableHeader:UILabel?

    
    var tokensContracts = ["0xe3818504c1b32bf1557b16c238b2e01fd3149c17",
                  "0xf230b790e05390fc8295f4d3f60332c93bed42e2",
                  "0x4156D3342D5c385a87D264F90653733592000581",
                  "0x744d70fdbe2ba4cf95131626614a1763df805b9e",
                  "0xc5bbae50781be1669306b9e001eff57a2957b09d",
                  "0x42d6622dece394b54999fbd73d108123806f6a18",
                  "0xa74476443119A942dE498590Fe1f2454d7D4aC0d",
                  "0xd0a4b8946cb52f0661273bfbc6fd0e0c75fc6433",
                  "0x558ec3152e2eb2174905cd19aea4e34a23de9ad6",
                  "0xd850942ef8811f2a866692a623011bde52a462c1",
                  "0xe41d2489571d322189246dafa5ebde1f4699f498",
                  "0x9366605f6758727ad0fbce0d1a2a6c1cd197f2a3"
    ]
    
    var tokens = [ERC20Token]()
    
    @IBOutlet var ibo_tokenTableView:UITableView!
    
    let storage = try? Storage(
        diskConfig: DiskConfig(name: "Tokens"),
        memoryConfig: MemoryConfig(expiry: .never, countLimit: 10, totalCostLimit: 10),
        transformer: TransformerFactory.forCodable(ofType: ERC20Token.self) // Storage<User>
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
        //DispatchQueue.global(qos: .background).async {
            // Call your background task
            
            //UPDATE UI
            DispatchQueue.main.async {
               self.loadToken(index: 0)
            }
        //}
        
        
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
    

    func loadToken(index:Int){
        
        let tokenAddress = self.tokensContracts[index]
        
        do {
            let token = try storage?.object(forKey: tokenAddress)
            self.append([token!])
            if index < self.tokensContracts.count - 1 {
                self.loadToken(index: index + 1)
            }
        } catch {
            
            EtherWallet.tokens.getTokenMetaData(contractAddress: tokenAddress) { (token) in
                DispatchQueue.global(qos: .background).async {
                    try? self.storage?.setObject(token, forKey: token.contractAddress!)
                }
                self.append([token])
                if index < self.tokensContracts.count - 1 {
                    self.loadToken(index: index + 1)
                }
            }

        }
        
        
    }
    
     func append(_ objectsToAdd: [ERC20Token]) {
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
        self.delegate?.tokenDidSelectERC20(token: self.tokens[indexPath.row])
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    }
}



class WalletTokenCell:UITableViewCell {
    
    @IBOutlet var iboTokenImage:UIImageView!
    @IBOutlet var iboTokenName:UILabel!
    @IBOutlet var iboTokenSymbol:UILabel!
    @IBOutlet var iboTokenBalance:UILabel!
    @IBOutlet var iboTokenFiat:UILabel!
    
    
    func setupCell(token:ERC20Token){
    
        self.iboTokenName.text = token.name
        self.iboTokenSymbol.text = token.symbol
        
        EtherWallet.tokens.getTokenImage(contractAddress: token.contractAddress!) { (image) in
            self.iboTokenImage.image = image
        }
    }

    func syncTokenBalance(_tokenAddress:String!){
        EtherWallet.balance.tokenBalance(contractAddress: _tokenAddress) { (balance) in
            self.iboTokenBalance.text = balance
        }
    }
}


