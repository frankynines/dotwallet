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
import SafariServices
class TransactionViewController: UIViewController, UITabBarDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var ibo_tokenImage:UIImageView?
    @IBOutlet var ibo_tokenName:UILabel?
    @IBOutlet var ibo_tokenSymbol:UILabel?
    @IBOutlet var ibo_value:UILabel?
    
    @IBOutlet var ibo_tableHeader:UILabel?
    
    @IBOutlet var ibo_tableView:UITableView!
    
    var contractAddress:String!
    var transactions = [GeneralTransactionData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.ibo_tableView.addSubview(self.refreshControl)
        self.ibo_tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        self.navigationController?.isNavigationBarHidden = false
        if let cacheBalance = UserDefaults.standard.value(forKey: "ETHBalance") as? String {
            self.ibo_value?.text = cacheBalance
        }
       
        
        self.requestTransactionHistory()
        self.refreshBalance()

    }
    
    @IBAction func iba_dismiss(){
        self.dismiss(animated: true) {}
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(self.contractAddress)
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func requestTransactionHistory(){
        
        EtherWallet.transaction.getTransactionHistory(address: EtherWallet.account.address!) { (jsonResult) in
            for transaction in jsonResult! {
                let generalTransaction = transaction.rawString()
                self.buildTransactionItem(transaction: generalTransaction!)
            }
            
            self.transactions.reverse()
            self.ibo_tableView.reloadData()
            self.ibo_tableHeader?.text = String(self.transactions.count) + " Transactions"
        }
    }
    
    func buildTransactionItem(transaction:String) {
        let data = transaction.data(using: .utf8)!
        do {
            let generalTransaction = try JSONDecoder().decode(GeneralTransactionData.self, from: data)
            self.transactions.append(generalTransaction)
            self.ibo_tableView.reloadData()
        } catch {
            print("Failed to Build Transaction Item")
        }
    }
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(self.handleRefresh(_:)),
                                 for: UIControlEvents.valueChanged)
        return refreshControl
        
    }()
    
    //REFRESH HANDLER
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.transactions.removeAll()
        self.ibo_tableView.reloadData()
        self.requestTransactionHistory()
        self.refreshBalance()
        refreshControl.endRefreshing()
    }
    
    func refreshBalance(){
        EtherWallet.balance.etherBalance { balance in
            UserDefaults.standard.set(balance, forKey: "ETHBalance")
            self.ibo_value?.text = balance
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! TransactionTableCell
        
        
        let alert = UIAlertController(title: "Transaction", message: cell.transaction.hash, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            //
        }))
        
        alert.addAction(UIAlertAction(title: "View on Etherscan", style: .default, handler: { (action) in
            let url = URL(string: "https://ropsten.etherscan.io/tx/\(cell.transaction.hash)")
            let vc = SFSafariViewController(url: url!)
            self.present(vc, animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
}




