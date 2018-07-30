//
//  WalletHeaderViewController.swift
//  Dot Wallet
//
//  Created by Franky Aguilar on 7/25/18.
//  Copyright © 2018 Ninth Industries. All rights reserved.
//

import Foundation
import UIKit
import QRCode
import Hero
import web3swift
class WalletHeaderViewController:UIViewController, UIScrollViewDelegate{
    
    //HEADER
    @IBOutlet var ibo_scrollview:UIScrollView?
    
    @IBOutlet var iboPublicKey: UILabel?
    @IBOutlet var iboBalance: UILabel?
    @IBOutlet var qrCodeView:UIImageView?
    @IBOutlet var iboCardView:UIView?

    let impact = UIImpactFeedbackGenerator()
    var impactDetected = false
    
    var repeatableTimer:RepeatingTimer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ibo_scrollview?.delegate = self
        self.ibo_scrollview?.canCancelContentTouches = true
        
        
        self.setupHeaderView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.refreshBalance()
        
        self.repeatableTimer = RepeatingTimer(timeInterval: 3)
        self.repeatableTimer.eventHandler = {
            self.refreshBalance()
        }
        self.repeatableTimer.resume()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.repeatableTimer.suspend()
    }
    
    func setupHeaderView(){
        
        if (EtherWallet.account.hasAccount == true) {
            self.iboPublicKey?.text = EtherWallet.account.address
            
            if let cacheBalance = UserDefaults.standard.value(forKey: "ETHBalance") {
                self.iboBalance?.text = cacheBalance as? String
            }
           
            let qrCode = QRCode(EtherWallet.account.address!)
            qrCodeView?.image = qrCode?.image
            
        }
    }
    
    @IBAction func refreshBalance(){
        
        EtherWallet.balance.etherBalance { balance in
            UserDefaults.standard.set(balance, forKey: "ETHBalance")
            self.iboBalance?.text = balance
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        //VERTICLE SCROLLING EDGES
        if scrollView.contentOffset.y > 100 {
            if impactDetected == false {
                impact.impactOccurred()
                iba_showTransactionHistory()
            }
            self.impactDetected = true
        }
        
        if scrollView.contentOffset.y < -100 {
            if impactDetected == false {
                impact.impactOccurred()
                iba_presentSendView()
            }
            self.impactDetected = true
        }

        if scrollView.contentOffset.y <= 50 && scrollView.contentOffset.y >= -50 {
            self.impactDetected = false;
        }

    }
    
    @IBAction func iba_presentSendView(){
        let vc = storyboard?.instantiateViewController(withIdentifier: "sb_SendViewController") as! SendViewController
        self.present(vc, animated: true) {}
    }
    
    @IBAction func iba_copyPublicAddress(){
        UIPasteboard.general.string = EtherWallet.account.address
    }
    
    
    @IBAction func iba_showTransactionHistory(){
        
        let vc2 = self.storyboard?.instantiateViewController(withIdentifier: "sb_TransactionViewController") as! TransactionViewController
        present(vc2, animated: true, completion: nil)
        
    }
    
    @IBAction func iba_killwallet(){
        do {
            try EtherWallet.account.killKeystore()
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "sb_CreateWalletViewController")
            self.navigationController?.setViewControllers([vc!], animated: true)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @IBAction func iba_showTokenList(){
        let vc = storyboard?.instantiateViewController(withIdentifier: "sb_TokenDisplayContainerViewController") as! TokenDisplayContainerViewController
        self.present(vc, animated: true) {}
    }
    
}

