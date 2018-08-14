//
//  SendViewController.swift
//  FuyuWallet
//
//  Created by Franky Aguilar on 7/23/18.
//  Copyright © 2018 Ninth Industries. All rights reserved.
//

import Foundation
import UIKit
import QRCodeReader
import AVFoundation

class SendViewController: UIViewController, QRCodeReaderViewControllerDelegate {
    
    
    @IBOutlet weak var ibo_balance:UILabel?
    @IBOutlet weak var ibo_walletName:UILabel?
    
    @IBOutlet weak var ibo_sendAmount:UITextField?
    @IBOutlet weak var ibo_addressField:UITextField?
    
    var token:OERC20Token?
    var balance:String!
    
    var delegate:ModalSlideOverViewcontrollerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.ibo_sendAmount?.text = ""
        self.ibo_addressField?.text = ""
        self.automaticallyAdjustsScrollViewInsets = false
       
        //CHECK IF ERC20 TOKEN
        if token == nil {
            self.ibo_walletName?.text = "ETH" + " Balance"
            self.syncEtherBalance()
        } else {
            self.ibo_walletName?.text = (token?.symbol)! + " Balance"
            self.syncTokenBalance()
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func syncEtherBalance(){
        var balance:String!
        
        DispatchQueue.global(qos: .background).async {
            // Call your background task
            do {
                balance = try EtherWallet.balance.etherBalanceSync()
            } catch {
                self.ibo_balance?.text = "0.00"
            }
            //UPDATE UI
            DispatchQueue.main.async {
                self.balance = balance
                self.ibo_balance?.text = balance
            }
        }
    }
    
    func syncTokenBalance(){
        var balance:String!
        let address = self.token?.address
        
        DispatchQueue.global(qos: .background).async {
            // Call your background task
            do {
                balance = try EtherWallet.balance.tokenBalanceSync(contractAddress: address!)
            } catch {
                self.ibo_balance?.text = "0.00"
            }
            //UPDATE UI
            DispatchQueue.main.async {
                self.balance = balance
                self.ibo_balance?.text = balance
            }
        }
    }
    
    @IBAction func iba_dismissView(){
        self.dismiss(animated: true, completion: { })
    }
    
    @IBAction func iba_sendTransaction () {
        
        if token == nil {
            self.sendEthereumTransaction()
        } else {
            self.sendTokenTransaction()
        }
    }
    
    func sendTokenTransaction(){
        if Float(balance)! <= Float(0.00) {
            self.showAlert(title: "Oops", message: "You do not have enough to send this transaction", completion: false)
            return
        }
        
        let receiptAddress = ibo_addressField?.text
        let amount = ibo_sendAmount?.text
        
        let alertView = UIAlertController.init(title: "Confirm Send ", message: "⚠️ NOTE THIS IS ONLY SENDING ROPSTEN NETWORK ETH. ", preferredStyle: .alert)
        
        
        alertView.addAction(UIAlertAction(title: "Enter", style: .default, handler: { (action) in
            
            EtherWallet.transaction.sendToken(to: receiptAddress!, contractAddress: (self.token?.address)!, amount: amount!, password: "", decimal: (self.token?.decimals)!, completion: { (status) in
                
                if status != nil {
                    self.showAlert(title: "Success", message: "Transaction has been sent!", completion: true)
                } else {
                    self.showAlert(title: "Oops", message: "Transaction Failed", completion: false)
                }
                
            })
            
        }))
        
        alertView.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        self.present(alertView, animated: true, completion: nil)
    }
    
    func sendEthereumTransaction(){
        if Float(balance)! <= Float(0.00) {
            self.showAlert(title: "Oops", message: "You do not have enough ETH to send this transaction", completion: false)
            return
        }
        
        let receiptAddress = ibo_addressField?.text
        let amount = ibo_sendAmount?.text
        
        let alertView = UIAlertController.init(title: "Confirm Send ", message: "⚠️ NOTE THIS IS ONLY SENDING ROPSTEN NETWORK ETH. ", preferredStyle: .alert)
        
        
        alertView.addAction(UIAlertAction(title: "Enter", style: .default, handler: { (action) in
            
            
            EtherWallet.transaction.sendEther(to: receiptAddress!, amount: amount!, password: "") { (status) in
                //status is transaction hash
                if status != nil {
                    self.showAlert(title: "Success", message: "Transaction has been sent!", completion: true)
                } else {
                    self.showAlert(title: "Oops", message: "Transaction Failed", completion: false)
                }
            }
        }))
        
        alertView.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        self.present(alertView, animated: true, completion: nil)
    }
    
    func showAlert(title:String, message:String, completion:Bool) {
        let alertView = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        
        alertView.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            if completion {
                if self.delegate != nil {
                    self.delegate?.modalSlideDismiss()
                } else {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }))
        
        self.present(alertView, animated: true)
    }
    
    @IBAction func iba_pasteAddress () {
        
        if let myString = UIPasteboard.general.string {
            self.ibo_addressField?.text = myString
        }
        
    }
    
    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
        }
        builder.showSwitchCameraButton = false
        return QRCodeReaderViewController(builder: builder)
    }()
    
    @IBAction func iba_scanAction(_ sender: AnyObject) {

        readerVC.delegate = self
        readerVC.view.frame = self.view.frame
        readerVC.completionBlock = { (result: QRCodeReaderResult?) in
            if result?.value == nil {
                return
            }
            let urlQuery = URL(string: (result?.value)!)
            print(result!)
            
            if let ethereumURL = urlQuery?.absoluteStringByTrimmingQuery(){
                print("SCAN:" + ethereumURL)
                self.ibo_addressField?.text = ethereumURL.replacingOccurrences(of: "ethereum:", with: "")
            }
            
           // guard (urlQuery?.queryParameters?.isEmpty)! else { return  }
            if let amount = urlQuery?.queryParameters?["amount"] {
//                let value = EtherWallet.balance.WeiToValue(wei: String(amount))!
                self.ibo_sendAmount?.text = amount
            }

        }
        
        readerVC.modalPresentationStyle = .overFullScreen
        present(readerVC, animated: true, completion: nil)
    }
    
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        
        dismiss(animated: true, completion: nil)
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        dismiss(animated: true, completion: nil)
    }

}
