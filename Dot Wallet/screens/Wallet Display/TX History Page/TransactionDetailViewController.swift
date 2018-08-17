//
//  TransactionDetailViewController.swift
//  Dot Wallet
//
//  Created by Franky Aguilar on 8/16/18.
//  Copyright © 2018 Ninth Industries. All rights reserved.
//

import Foundation
import UIKit
import SafariServices
import BigInt
import web3swift

class TransactionDetailViewController:UIViewController {
    
    var delegate:TokenDetailDelegate?
    
    var transaction:GeneralTransactionData?
    
    @IBOutlet var ibo_date:UILabel?
    @IBOutlet var ibo_direction:UILabel?
    @IBOutlet var ibo_directionLabel:UILabel?
    @IBOutlet var ibo_amount:UILabel?
    
    @IBOutlet var ibo_address:UILabel?
    @IBOutlet var ibo_networkFee:UILabel?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("View will disapeear")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.ibo_networkFee?.text = EtherWallet.balance.WeiToValue(wei: (transaction?.cumulativeGasUsed)!, dec: 12)
        
        let date = Date(timeIntervalSince1970: Double.init(transaction!.timestamp)!)
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateFormat = "MMM dd, YYYY - hh:mm"
        let dateString = dayTimePeriodFormatter.string(from: date)
        self.ibo_date?.text = dateString

        let wei = BigInt(transaction!.value)
        var amount = Web3.Utils.formatToEthereumUnits(wei!)
        
        if isSent(to: transaction!.to) {
            self.ibo_address?.text = transaction!.to
            amount = "- " + amount!
            self.ibo_direction?.text = "☝️"
            self.ibo_directionLabel?.text = "Sent"
            self.ibo_amount?.textColor = UIColor.black
            
        } else {
            amount = "+ " + amount!
            self.ibo_address?.text = transaction!.from
            self.ibo_direction?.text = "📥"
            self.ibo_directionLabel?.text = "Received"
            self.ibo_amount?.textColor = UIColor(hexString: "40E252")
        }
        
        self.ibo_amount?.text = amount
        
    }
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    @IBAction func iba_viewOnEtherscan(){
        
        self.delegate?.openURL(url: "https://ropsten.etherscan.io/tx/\(transaction!.hash)")
    }
    
    func isSent(to:String) -> Bool {
        if to.lowercased() == EtherWallet.account.address?.lowercased() {
            return false
        } else {
            return true
        }
    }
    
    
}
