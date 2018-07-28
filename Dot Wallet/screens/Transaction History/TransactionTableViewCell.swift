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
    
    func setupCell(transaction:GeneralTransactionData!) {
        
        let value = BigInt.init(transaction.value)
        let amount = Web3.Utils.formatToPrecision(value!)
        let date = Date(timeIntervalSince1970: Double.init(transaction.timestamp)!)
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateFormat = "MMM dd YYYY hh:mm a"
        let dateString = dayTimePeriodFormatter.string(from: date)
        
        self.ibo_address?.text = "to: " + transaction.to
        self.ibo_value?.text = amount!
        self.ibo_timestamp?.text = dateString
        
        
    }
    
}
