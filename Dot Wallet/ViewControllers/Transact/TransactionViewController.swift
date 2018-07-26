//
//  TransactionViewController.swift
//  Dot Wallet
//
//  Created by Franky Aguilar on 7/24/18.
//  Copyright © 2018 Ninth Industries. All rights reserved.
//

import Foundation
import UIKit



class TransactionViewController: UIViewController {
    
    var contractAddress:String!
    
    @IBOutlet var ibo_tokenImage:UIImageView!
    @IBOutlet var ibo_tokenName:UILabel!
    @IBOutlet var ibo_tokenSymbol:UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = false

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(self.contractAddress)
        
        EtherWallet.transaction.getTransactionHistory(address: EtherWallet.account.address!) { (jsonResult) in
            
            for transaction in jsonResult! {
                let generalTransaction = transaction.rawString()
                //print(generalTransaction)
                self.buildTransactionItem(transaction: generalTransaction!)
            }
            
        }
    }
    
    func buildTransactionItem(transaction:String) {
        let data = transaction.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            let myStruct = try JSONDecoder().decode(GeneralTransactionData.self, from: data)
            print(myStruct)

        } catch {
            print("FAILED")
        }
    }
}

