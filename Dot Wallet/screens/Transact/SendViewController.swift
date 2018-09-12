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
import Toast_Swift
import KeychainAccess

class SendViewController: UIViewController, QRCodeReaderViewControllerDelegate, UITextFieldDelegate, PasswordLoginDelegate {
    
    @IBOutlet weak var ibo_balance:UILabel?
    @IBOutlet weak var ibo_walletName:UILabel?
    @IBOutlet weak var ibo_tokenSymbol:UILabel?

    @IBOutlet weak var ibo_sendAmount:UITextField?
    @IBOutlet weak var ibo_addressField:UITextField?
    
    
    var collectible:OErc721Token?
    var token:OERC20Token?
    var balance:String!
    
    var delegate:ModalSlideOverViewcontrollerDelegate?
    var passcodeVC:PasswordLoginViewController!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ibo_sendAmount?.delegate = self
        self.ibo_addressField?.delegate = self
        
        let userBalanceKey = "balance:\(EtherWallet.account.address!)"
        
        if let balance = UserDefaults.standard.value(forKey: userBalanceKey) {
            self.ibo_balance?.text = (balance as! String)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
               
        //CHECK IF ERC20 TOKEN
        if self.token != nil {
            
            self.ibo_walletName?.text = (token?.symbol)! + " Balance"
            self.ibo_tokenSymbol?.text = (token?.symbol)!
            self.syncTokenBalance()
            
        } else {
            
            self.ibo_walletName?.text = "ETH" + " Balance"
            self.ibo_tokenSymbol?.text = "ETH"
            self.syncEtherBalance()
            
        }
        
    }

    func syncEtherBalance(){
         DispatchQueue.global(qos: .background).async {
            do {
                let balance = try EtherWallet.balance.etherBalanceSync()
                DispatchQueue.main.async {
                    self.balance = balance
                }
            } catch {
                self.balance = nil
            }
        }
    }
    
    func syncTokenBalance(){
        var balance:String!
        let address = self.token?.address
        
        DispatchQueue.global(qos: .background).async {
            do {
                balance = try EtherWallet.balance.tokenBalanceSync(contractAddress: address!)
            } catch {
                self.ibo_balance?.text = "0.00"
            }
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
        
        //SECURITY CHECK
        let publicAddress = EtherWallet.account.address?.lowercased()
        let keychain = Keychain(service: publicAddress!)
        do {
            
            let pass = try keychain.get(publicAddress!)
            self.passcodeVC = (storyboard?.instantiateViewController(withIdentifier: "PasswordLoginViewController") as! PasswordLoginViewController)
            self.passcodeVC!.modalPresentationStyle = .overFullScreen
            self.passcodeVC!.delegate = self
            self.passcodeVC!.passState = .Unlock
            self.passcodeVC!.modalTitle = "Enter Passcode"
            self.passcodeVC!.kPass = pass
            present(passcodeVC!, animated: false, completion: nil)
            
        } catch {
            print(error.localizedDescription)
        }
            
    }
    
    func passcodeVerified(pass:String?) {
        
        if self.collectible == nil {
            
            if balance == nil{
                self.showAlert(title: "Oops", message: "Seem to be offline", completion: false)
                return
            }
            if Float(balance)! <= Float(0.00) {
                self.showAlert(title: "Oops", message: "You do not have enough to send this transaction", completion: false)
                return
            }
            
        }
        
        let receiptAddress = ibo_addressField?.text?.lowercased()
        let amount = ibo_sendAmount?.text
        
        let alertView = UIAlertController.init(title: "Confirm Send", message: "Are you sure you would like to send this transaction.", preferredStyle: .alert)
        
        alertView.addAction(UIAlertAction(title: "Enter", style: .default, handler: { (action) in
            
            self.view.makeToastActivity(.center)
            
            DispatchQueue.main.async {
                
                if self.token != nil { // ETH TRANSACTION
                    self.sendTokenTransaction(to: receiptAddress!, amount: amount!, pass:pass!)
                } else if self.collectible != nil {
                    self.sendCollectible(to: receiptAddress!, pass:pass!)
                } else {
                    self.sendEthereumTransaction(to: receiptAddress!, amount: amount!, pass:pass!)
                }
            }
            
        }))
        
        alertView.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        self.present(alertView, animated: true, completion: nil)
        
        
    }
    
    func sendTokenTransaction(to: String, amount:String, pass:String){

        EtherWallet.transaction.sendToken(to: to, contractAddress: (self.token?.address)!, amount: amount, password: pass, decimal: (self.token?.decimals)!, completion: { (status) in
            
            self.view.hideToastActivity()

            DispatchQueue.main.async {
            
                if status != nil {
                    self.showAlert(title: "Success", message: "Transaction has been sent!", completion: true)
                } else {
                    self.showAlert(title: "Oops", message: "Transaction Failed", completion: false)
                }
            }
        })
        
    }
    
    func sendCollectible(to: String, pass:String){
        let contractAddy = self.collectible?.asset_contract?.address
        let tokenID = self.collectible?.token_id
        
        EtherWallet.transaction.sendERC721Token(toAddress: to, contractAddress: contractAddy!, tokenID: tokenID!, pass: pass) { (status, result) in
            
            self.view.hideToastActivity()
            
            if status == true {
                self.showAlert(title: "Success", message: "Transaction has been sent!", completion: true)
            } else {
                self.showAlert(title: "Oops", message: "Transaction Failed \(result)", completion: false)
            }
        }
        
    
    }
    
    func sendEthereumTransaction(to: String, amount:String, pass:String){
        
        EtherWallet.transaction.sendEther(to: to, amount: amount, password: pass) { (status) in
            
            self.view.hideToastActivity()
            if status != nil {
                self.showAlert(title: "Success", message: "Transaction has been sent!", completion: true)
            } else {
                self.showAlert(title: "Oops", message: "Transaction Failed", completion: false)
            }
        }
        
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
            
            if let ethereumURL = urlQuery?.absoluteStringByTrimmingQuery(){
                self.ibo_addressField?.text = ethereumURL.replacingOccurrences(of: "ethereum:", with: "")
            }
            
            if let amount = urlQuery?.queryParameters?["amount"] {
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
