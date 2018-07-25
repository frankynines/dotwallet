//
//  SendViewController.swift
//  FuyuWallet
//
//  Created by Franky Aguilar on 7/23/18.
//  Copyright © 2018 Ninth Industries. All rights reserved.
//

import Foundation
import UIKit

class SendViewController: UIViewController {
    
    @IBOutlet var ibo_balance:UILabel!
    
    @IBOutlet var ibo_sendAmount:UITextField!
    @IBOutlet var ibo_addressField:UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        do {
            let balance = try EtherWallet.balance.etherBalanceSync()

            self.ibo_balance.text = balance

        } catch {
            self.ibo_balance.text = "0.00"
        }
    }
    
    @IBAction func iba_dismissView(){
        self.dismiss(animated: true) {
            //
        }
    }
    
    @IBAction func iba_sendTransaction () {
        
        let receiptAddress = ibo_addressField.text!
        let amount = ibo_sendAmount.text!
        
        let alertView = UIAlertController.init(title: "Confirm Send", message: "Sign your transaction using your Pincode", preferredStyle: .alert)
        
        alertView.addTextField { (inputField) in
            inputField.tag = 0
            inputField.placeholder = "Pincode"
        }
        
        alertView.addAction(UIAlertAction(title: "Enter", style: .default, handler: { (action) in
            
            var pass = String()
            
            for inputField in alertView.textFields! {
                let field = inputField
                if (field.text?.isEmpty)! {
                    return
                }
                switch field.tag {
                case 0:
                    pass = field.text!
                default: break
                }
            }
            
            EtherWallet.transaction.sendEther(to: receiptAddress, amount: amount, password: pass) { (status) in
                //status is transaction hash
                if status != nil {
                    print("Success Send")
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }))
        
        alertView.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        
        self.present(alertView, animated: true, completion: nil)
        
       
       
        
    }
    
    @IBAction func iba_pasteAddress () {
        
        if let myString = UIPasteboard.general.string {
            self.ibo_addressField.text = myString
        }
        
    }

}
