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


class WalletHeaderViewController:UIViewController, UIScrollViewDelegate{
    
    //HEADER
    @IBOutlet var ibo_scrollview:UIScrollView?
    
    @IBOutlet var iboPublicKey: UILabel?
    @IBOutlet var iboBalance: UILabel?
    @IBOutlet var qrCodeView:UIImageView?
    @IBOutlet var iboCardView:UIView?

    let impact = UIImpactFeedbackGenerator()
    var impactDetected = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupHeaderView()
        self.ibo_scrollview?.delegate = self
        self.ibo_scrollview?.canCancelContentTouches = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.refreshBalance()
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
    
    @IBAction func iba_showTransactionHistory(){
        
        let vc2 = self.storyboard?.instantiateViewController(withIdentifier: "sb_TransactionViewController") as! TransactionViewController
        present(vc2, animated: true, completion: nil)
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        print(scrollView.contentOffset.y)
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
                iba_showTokenList()
            }
            self.impactDetected = true
        }
//
        if scrollView.contentOffset.y <= 50 && scrollView.contentOffset.y >= -50 {
            self.impactDetected = false;
        }
//
//        if scrollView.contentOffset.y >= -50 {
//            self.impactDetected = false;
//        }
        
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
//
    @IBAction func iba_copyPublicAddress(){
        UIPasteboard.general.string = EtherWallet.account.address
    }
    
    @IBAction func iba_shareAddress(){
        //UIPasteboard.general.string = EtherWallet.account.address
    }
    
    @IBAction func iba_showTokenList(){
        let vc = storyboard?.instantiateViewController(withIdentifier: "sb_TokenDisplayContainerViewController") as! TokenDisplayContainerViewController
        self.present(vc, animated: true) {
            //
        }
    }

    @IBAction func iba_presentSendView(){
        let vc = storyboard?.instantiateViewController(withIdentifier: "sb_SendViewController") as! SendViewController
        self.present(vc, animated: true) {
            //
        }
    }
    @IBAction func setIsTouched(){
        
        let transform = CGAffineTransform.identity.scaledBy(x: 0.96, y: 0.96)
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
            self.iboCardView?.transform = transform
        }, completion: nil)
    }
    @IBAction func setIsTouchedFalsed(){
        let transform = CGAffineTransform.identity.scaledBy(x: 1, y: 1)
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
            self.iboCardView?.transform = transform
        }, completion: nil)
    }
    
  
    
    
}

