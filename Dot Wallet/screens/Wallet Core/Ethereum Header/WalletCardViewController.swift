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
class WalletCardViewController:UIViewController, UIScrollViewDelegate, ModalSlideOverViewcontrollerDelegate, PopOverViewcontrollerDelegate{
    
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
            } else {
                self.refreshBalance()
            }
           
            let qrCode = QRCode(EtherWallet.account.address!)
            qrCodeView?.image = qrCode?.image
        }
    }
    
    @IBAction func iba_copyPublicAddress(){
        UIPasteboard.general.string = EtherWallet.account.address
    }
    
    @IBAction func iba_showWalletDetails(){
        let vc = storyboard?.instantiateViewController(withIdentifier: "sb_WalletDisplayViewController") as! WalletDisplayViewController
        self.present(vc, animated: true) {}
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
    
    @IBAction func refreshBalance(){
        
        EtherWallet.balance.etherBalance { balance in
            guard let networkbalance = balance else {
                return
            }
            UserDefaults.standard.set(networkbalance, forKey: "ETHBalance")
            self.iboBalance?.text = balance
        }
    }
    
    @IBAction func iba_shareAddress(){
        
        // set up activity view controller
        let textToShare = [ "Send me some Eth: ", EtherWallet.account.address ]
        let activityViewController = UIActivityViewController(activityItems: textToShare as [Any], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook ]
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        //VERTICLE SCROLLING EDGES
        if scrollView.contentOffset.y > 50 {
            if impactDetected == false {
                impact.impactOccurred()
                iba_presentSendView()
            }
            self.impactDetected = true
        }
        
        if scrollView.contentOffset.y < -50 {
            if impactDetected == false {
                impact.impactOccurred()
                self.iba_showWalletDetails()
            }
            self.impactDetected = true
        }

        if scrollView.contentOffset.y <= 50 && scrollView.contentOffset.y >= -50 {
            self.impactDetected = false;
        }

    }
    
    // MODAL FOR SEND
    lazy var sendVC: SendViewController = {
        return storyboard?.instantiateViewController(withIdentifier: "sb_SendViewController") as! SendViewController
    }()
    
    var slideModalController:ModalSlideOverViewcontroller!
    
    @IBAction func iba_presentSendView(){
       
        guard slideModalController == nil else {
            return
        }
       
        self.slideModalController = ModalSlideOverViewcontroller()
        self.slideModalController = self.storyboard?.instantiateViewController(withIdentifier: "sb_ModalSlideOverViewcontroller") as! ModalSlideOverViewcontroller
        self.slideModalController.modalTitle = "Send Ethereum"
        self.slideModalController.view.frame = self.view.frame
        self.slideModalController.delegate = self
        
        //Assign Child Class
        self.slideModalController.viewController = sendVC
        sendVC.delegate = self
        
        self.view.addSubview(self.slideModalController.view)
        
    }
    func modalSlideDismiss() {
        self.slideModalController.animateModalOut {
            self.slideModalController.view.removeFromSuperview()
            self.slideModalController.removeFromParentViewController()
            self.slideModalController = nil
        }
    }
    
    

    
    var popModalController:PopOverViewcontroller!
    
    @IBAction func iba_presentPopView(){
        
        guard popModalController == nil else {
            return
        }
        
        self.popModalController = PopOverViewcontroller()
        self.popModalController = self.storyboard?.instantiateViewController(withIdentifier: "sb_PopOverViewcontroller") as! PopOverViewcontroller
        self.popModalController.modalTitle = "Send Ethereum"
        self.popModalController.view.frame = self.view.frame
        self.popModalController.delegate = self
        
        //Assign Child Class
        self.popModalController.viewController = sendVC
        
        self.view.addSubview(self.popModalController.view)
        
    }
    func popOverDismiss() {
        self.popModalController.animateModalOut {
            self.popModalController.view.removeFromSuperview()
            self.popModalController.removeFromParentViewController()
            self.popModalController = nil
        }
    }
    
    
    
    
    

    
}

