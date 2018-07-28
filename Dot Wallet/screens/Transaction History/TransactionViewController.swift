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

protocol TransactionViewControllerDelegate {
    func txRowSelected(row:Int, transaction:GeneralTransactionData)
    func tableViewScroll(rect:CGRect)
}

class TransactionViewController: UIViewController, UITabBarDelegate, UITableViewDataSource, UITableViewDelegate {
    
    var delegate:TransactionViewControllerDelegate?
    
    var contractAddress:String!
    var transactions = [GeneralTransactionData]()
    
    @IBOutlet var ibo_tokenImage:UIImageView!
    @IBOutlet var ibo_tokenName:UILabel!
    @IBOutlet var ibo_tokenSymbol:UILabel!
    @IBOutlet var ibo_value:UILabel!
    
    @IBOutlet var ibo_tableView:UITableView!
    
    var stretchHeight:CGFloat?
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(self.handleRefresh(_:)),
                                 for: UIControlEvents.valueChanged)
        return refreshControl
        
    }()
    
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.requestTransactionHistory()
        self.refreshBalance()
        self.transactions.removeAll()
        refreshControl.endRefreshing()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.ibo_tableView.addSubview(self.refreshControl)
        self.ibo_tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        self.navigationController?.isNavigationBarHidden = false
        
        self.ibo_value.text = UserDefaults.standard.value(forKey: "ETHBalance") as! String
        
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
        }
    }
    
    func buildTransactionItem(transaction:String) {
        let data = transaction.data(using: .utf8)!
        do {
            let generalTransaction = try JSONDecoder().decode(GeneralTransactionData.self, from: data)
            self.transactions.append(generalTransaction)
            self.ibo_tableView.reloadData()
        } catch {
            print("FAILED")
        }
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
        self.delegate?.txRowSelected(row: indexPath.row, transaction: self.transactions[indexPath.row])
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let y = 200 - (scrollView.contentOffset.y + 200)
        let height = min(max(y, 200), 1000)
        self.delegate?.tableViewScroll(rect: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: height))
        stretchHeight = height
    }
    
}




