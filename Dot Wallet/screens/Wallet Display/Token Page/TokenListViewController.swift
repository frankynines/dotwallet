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
            
            let userStorage = try? Storage(
                diskConfig: DiskConfig(name: "userERC20"),
                memoryConfig: MemoryConfig(expiry: .never, countLimit: 10, totalCostLimit: 10),
                transformer: TransformerFactory.forCodable(ofType: [OERC20Token].self)
            )
            
            do {
                let tokenArray = try userStorage?.object(forKey:"UserTokens")
                
                self.tokens = tokenArray!
                print(self.tokens.count)
                self.ibo_tableHeader?.text = "\(self.tokens.count) Tokens"
                
            } catch {
                print("No Tokens")
                print(error.localizedDescription)
            }
            
            
            self.ibo_tokenTableView.reloadData()
        }
        print("view loaded")
        self.ibo_tokenTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("view")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if self.tokens.count > 0 {
            self.ibo_tokenTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        }
    }
    
    @IBAction func iba_manageTokens(){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "sb_AddTokenViewController") as! AddTokenViewController
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    
    
    func tokenManagementControllerSaved(vc:AddTokenViewController) {
        print("UPDATE TOKENS")
        print(self.tokens.count)
        
        let userStorage = try? Storage(
            diskConfig: DiskConfig(name: "userERC20"),
            memoryConfig: MemoryConfig(expiry: .never, countLimit: 10, totalCostLimit: 10),
            transformer: TransformerFactory.forCodable(ofType: [OERC20Token].self)
        )
    
        vc.dismiss(animated: true) {
            do {
                
                self.tokens = (try userStorage?.object(forKey:"UserTokens"))!
                print(self.tokens.count)
                self.ibo_tableHeader?.text = "\(self.tokens.count) Tokens"
                self.ibo_tokenTableView.reloadData()

            } catch {
                print(error.localizedDescription)
            }
            

        }
        
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
        //self.delegate?.tokenDidSelectERC20(token: self.tokens[indexPath.row])
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
    
    
    func setupCell(token:OERC20Token){
    
        self.iboTokenName?.text = token.name
        self.iboTokenSymbol?.text = token.symbol
        
        EtherWallet.tokens.getTokenImage(contractAddress: (token.address?.lowercased())!) { (image) in
            self.iboTokenImage?.image = image
        }
    }

    func syncTokenBalance(_tokenAddress:String!){
        EtherWallet.balance.tokenBalance(contractAddress: _tokenAddress) { (balance) in
            self.iboTokenBalance?.text = balance
        }
    }
}


