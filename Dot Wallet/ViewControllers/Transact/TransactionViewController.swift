//
//  TransactionViewController.swift
//  Dot Wallet
//
//  Created by Franky Aguilar on 7/24/18.
//  Copyright © 2018 Ninth Industries. All rights reserved.
//

import Foundation
import UIKit
import web3swift
import BigInt

class TransactionViewController: UIViewController, UITabBarDelegate, UITableViewDataSource {
    
    var contractAddress:String!
    var transactions = [GeneralTransactionData]()
    
    @IBOutlet var ibo_tokenImage:UIImageView!
    @IBOutlet var ibo_tokenName:UILabel!
    @IBOutlet var ibo_tokenSymbol:UILabel!
    
    @IBOutlet var ibo_tableView:UITableView!
    
    
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
                self.buildTransactionItem(transaction: generalTransaction!)
            }
        }
    }
    
    func buildTransactionItem(transaction:String) {
        let data = transaction.data(using: .utf8)!
        do {
            let generalTransaction = try JSONDecoder().decode(GeneralTransactionData.self, from: data)
            self.transactions.append(generalTransaction)
            print(generalTransaction)
            self.ibo_tableView.reloadData()
        } catch {
            print("FAILED")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.transactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TransactionTableCell
        cell.setupCell(transaction:self.transactions[indexPath.row])
        return cell
    }
}

class TransactionTableCell:UITableViewCell {
    
    @IBOutlet var ibo_address:UILabel!
    @IBOutlet var ibo_value:UILabel!
    @IBOutlet var ibo_timestamp:UILabel!
    
    func setupCell(transaction:GeneralTransactionData!) {
        
        let value = BigInt.init(transaction.value)
        let amount = Web3.Utils.formatToPrecision(value!)
        let date = Date(timeIntervalSince1970: Double.init(transaction.timestamp)!)
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateFormat = "MMM dd YYYY hh:mm a"
        let dateString = dayTimePeriodFormatter.string(from: date)
        
        self.ibo_address.text = "to: " + transaction.to
        self.ibo_value.text = amount!
        self.ibo_timestamp.text = dateString
        
       
    }
    
}

