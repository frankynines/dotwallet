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
        
    }
    
    @IBAction func iba_pasteAddress () {
        
        if let myString = UIPasteboard.general.string {
            self.ibo_addressField.text = myString
        }
        
    }

}
