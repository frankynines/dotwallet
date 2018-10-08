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
import EFCountingLabel
import Toast_Swift

import Firebase

class WalletCardViewController:UIViewController, UIScrollViewDelegate, ModalSlideOverViewcontrollerDelegate{
    
    //HEADER
    @IBOutlet var ibo_scrollview:UIScrollView?
    
    @IBOutlet var iboPublicKey: UIButton?
    @IBOutlet var iboBalance: UILabel?
    @IBOutlet var qrCodeView:UIImageView?
    @IBOutlet var iboCardView:UIView?
    
    @IBOutlet var ibo_dot:UIView?

    let impact = UIImpactFeedbackGenerator()
    var impactDetected = false
    
    var repeatableTimer:RepeatingTimer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ibo_scrollview?.delegate = self
        self.ibo_scrollview?.canCancelContentTouches = true
        
        self.setupHeaderView()
        
        Auth.auth().signInAnonymously() { (authResult, error) in
            let userID = authResult?.user.uid
            DotAPI.shared.userID = userID
            DotAPI.users.updateUserValue(userID: userID!,
                                         key: "public_address",
                                         value: EtherWallet.account.address!)
        }
        
        let userBalanceKey = "balance:\(EtherWallet.account.address!)"
        
        if let balance = UserDefaults.standard.value(forKey: userBalanceKey) {
            self.iboBalance?.text = balance as? String
        }
        
         self.refreshBalance()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.repeatableTimer = RepeatingTimer(timeInterval: 5)
        self.repeatableTimer.eventHandler = {
            self.refreshBalance()
        }
        self.repeatableTimer.resume()
        self.ibo_dot?.backgroundColor = UIColor.green
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.repeatableTimer.suspend()
    }
    
    func setupHeaderView(){
        
        if (EtherWallet.account.hasAccount == true) {
            self.iboPublicKey?.setTitle(EtherWallet.account.address, for: .normal)
            let qrCode = QRCode(EtherWallet.account.address!)
            qrCodeView?.image = qrCode?.image
            qrCodeView?.layer.borderColor = UIColor.white.cgColor
            qrCodeView?.layer.shadowColor = UIColor.black.cgColor
            qrCodeView?.layer.shadowRadius = 4
            qrCodeView?.layer.shadowOffset = CGSize(width: 0, height: 2)
            qrCodeView?.layer.shadowOpacity = 0.25
        }
    }
    
    @IBAction func iba_copyPublicAddress(){
        UIPasteboard.general.string = EtherWallet.account.address
        self.view.makeToast("Copied to clipboard!")
    }
    
    @IBAction func iba_showWalletDetails(){
        let vc = UIStoryboard(name: "WalletDetail", bundle: nil).instantiateViewController(withIdentifier: "sb_WalletDisplayViewController") as! WalletDisplayViewController
        self.present(vc, animated: true) {}
    }

    func refreshBalance(){
        
        EtherWallet.balance.etherBalance { balance in
            guard let networkbalance = balance else {
                return
            }
            let userBalanceKey = "balance:\(EtherWallet.account.address!)"
            UserDefaults.standard.set(networkbalance, forKey: userBalanceKey) // SET
            self.iboBalance?.text = networkbalance
//            if let nformat = NumberFormatter().number(from: balance!) {
//                self.iboBalance?.countFromCurrentValueTo( CGFloat(truncating: nformat) )
//            }
        }
        
    }
    
    @IBAction func iba_walletSettings(){
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sb_WalletSettingViewController") as! WalletSettingViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func iba_shareAddress(){

        let textToShare = [EtherWallet.account.address ]
        let activityViewController = UIActivityViewController(activityItems: textToShare as [Any], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook ]
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
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
    var sendVC: SendViewController!
    var slideModalController:ModalSlideOverViewcontroller!
    
    @IBAction func iba_presentSendView(){
       
        guard slideModalController == nil else {
            return
        }

        self.slideModalController = ModalSlideOverViewcontroller()
        self.slideModalController = (UIStoryboard(name: "ModalControllers", bundle: nil).instantiateViewController(withIdentifier: "sb_ModalSlideOverViewcontroller") as! ModalSlideOverViewcontroller)
        self.slideModalController.size = .Full
        self.slideModalController.modalTitle = self.iboBalance?.text?.appending(" ETH")
        self.slideModalController.view.frame = self.view.frame
        self.slideModalController.delegate = self
        
        //Assign Child Class
         self.sendVC = (UIStoryboard(name: "SendView", bundle: nil).instantiateViewController(withIdentifier: "sb_SendViewController") as! SendViewController)
        sendVC.delegate = self
        
        self.slideModalController.viewController = sendVC
        self.view.addSubview(self.slideModalController.view)
    }
    
    func modalSlideDismiss() {
        self.slideModalController.animateModalOut {
            self.slideModalController.view.removeFromSuperview()
            self.slideModalController.removeFromParentViewController()
            self.slideModalController = nil
            self.sendVC = nil
        }
    }
    
}

