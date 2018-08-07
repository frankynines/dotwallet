//
//  TransactionTableViewCell.swift
//  Dot Wallet
//
//  Created by Franky Aguilar on 7/27/18.
//  Copyright © 2018 Ninth Industries. All rights reserved.
//
import Foundation
import UIKit
import BigInt
import web3swift

class TransactionTableCell:UITableViewCell {
    
    @IBOutlet var ibo_address:UILabel?
    @IBOutlet var ibo_value:UILabel?
    @IBOutlet var ibo_timestamp:UILabel?
    @IBOutlet var ibo_direction:UILabel?
    
    public var transaction:GeneralTransactionData!
    
    func setupCell(transaction:GeneralTransactionData!) {
        self.transaction = transaction
        
        var amount = EtherWallet.balance.WeiToValue(wei: transaction.value, dec: 16)

        let date = Date(timeIntervalSince1970: Double.init(transaction.timestamp)!)
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateFormat = "MMM dd YYYY"
        //dayTimePeriodFormatter.dateFormat = "MMM dd YYYY hh:mm a"

        let dateString = dayTimePeriodFormatter.string(from: date)
        
        
        if isSent(to: transaction.to) {
            self.ibo_address?.text = "to: " + transaction.to
            amount = "- " + amount!
            self.ibo_direction?.text = "⇡"
        } else {
            amount = "+ " + amount!
            self.ibo_address?.text = "from: " + transaction.to
            self.ibo_direction?.text = "⇣"
        }
        
        self.ibo_value?.text = amount!
        self.ibo_timestamp?.text = dateString
        
    }
    
    func isSent(to:String) -> Bool {
        if to.lowercased() == EtherWallet.account.address?.lowercased() {
            print("TO")
            return true
        } else {
            print("FROM")
            return false
        }
    }
}

