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
    
    
    @IBOutlet var ibo_tableHeader:UILabel?
    
    @IBOutlet var ibo_tableView:UITableView!
    
    var delegate:WalletPageViewControllerDelegate?
    
    var contractAddress:String!
    var transactions = [GeneralTransactionData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.ibo_tableView.addSubview(self.refreshControl)
        self.ibo_tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        self.navigationController?.isNavigationBarHidden = false
      
        self.loadTXHistory()

    }
    
    @IBAction func iba_dismiss(){
        self.dismiss(animated: true) {}
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func loadTXHistory(){
        TXHistoryCacheManager.shared.getTXHistory { (tx) in
            self.transactions = tx.reversed()
            self.ibo_tableView.reloadData()
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
        refreshControl.endRefreshing()
        
        TXHistoryCacheManager.shared.loadTXHistory { (result) in
            if result.isEmpty == true {
                return
            }
            self.transactions.removeAll()
            self.transactions = result.reversed()
            self.ibo_tableView.reloadData()
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
        self.delegate!.didSelectTXItem(transaction: self.transactions[indexPath.row])
    }
    
}




