//
//  ERC20TokenDetailViewController.swift
//  Dot Wallet
//
//  Created by Franky Aguilar on 8/2/18.
//  Copyright © 2018 Ninth Industries. All rights reserved.
//
import Foundation
import UIKit
import SafariServices
import QRCode

class ERC20TokenDetailViewController:UIViewController, UIScrollViewDelegate, ModalSlideOverViewcontrollerDelegate {
    
    var erc20Token:OERC20Token?
    
    @IBOutlet var ibo_name:UILabel?
    @IBOutlet var ibo_symbol:UILabel?
    @IBOutlet var ibo_balance:UILabel?
    @IBOutlet var ibo_walletAddress:UILabel?
    
    @IBOutlet var ibo_tokenImage:UIImageView?
    @IBOutlet var ibo_tokenBackground:UIImageView?
    
    @IBOutlet var ibo_qrCode:UIImageView?
    
    let impact = UIImpactFeedbackGenerator()
    var impactDetected = false
    
    @IBOutlet var ibo_scrollview:UIScrollView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ibo_scrollview?.delegate = self
        
        EtherWallet.tokens.getTokenImage(contractAddress: (erc20Token!.address?.lowercased())!) { (image) in
            self.ibo_tokenImage?.image = image
        }
    }
    
    override func viewWillLayoutSubviews() {
        self.ibo_name?.text = self.erc20Token?.name
        self.ibo_symbol?.text = self.erc20Token?.symbol
        
        self.syncTokenBalance()
        
        let qrCode = QRCode(EtherWallet.account.address!)
        ibo_qrCode?.image = qrCode?.image
        ibo_qrCode?.layer.borderColor = UIColor.white.cgColor
        ibo_qrCode?.layer.shadowColor = UIColor.black.cgColor
        ibo_qrCode?.layer.shadowRadius = 4
        ibo_qrCode?.layer.shadowOffset = CGSize(width: 0, height: 2)
        ibo_qrCode?.layer.shadowOpacity = 0.25
        
        self.ibo_walletAddress?.text = EtherWallet.account.address!
        
        let image = self.ibo_tokenImage?.image
        self.ibo_tokenBackground!.backgroundColor = UIColor(patternImage: image!)
        self.ibo_tokenBackground?.alpha = 1
        
    }
    
    func syncTokenBalance(){
        
        DispatchQueue.main.async {
            EtherWallet.balance.tokenBalance(contractAddress: self.erc20Token!.address!) { (result) in
                if let balance = result {
                    self.ibo_balance?.text = EtherWallet.balance.WeiToValue(wei: balance, dec: (self.erc20Token!.decimals)!)
                }
            }
        }
        
    }
    
    @IBAction func iba_dismiss(){
        self.dismiss(animated: true, completion: nil)
    }
    
    // MODAL FOR SEND
    lazy var sendVC: SendViewController = {
        return UIStoryboard(name: "SendView", bundle: nil).instantiateViewController(withIdentifier: "sb_SendViewController") as! SendViewController
    }()
    
    var slideModalController:ModalSlideOverViewcontroller!
    
    @IBAction func iba_sendToken(){
        
        guard slideModalController == nil else {
            return
        }
        
        self.slideModalController = ModalSlideOverViewcontroller()
        self.slideModalController = (UIStoryboard(name: "ModalControllers", bundle: nil).instantiateViewController(withIdentifier: "sb_ModalSlideOverViewcontroller") as! ModalSlideOverViewcontroller)
        let balance = self.ibo_balance?.text
        
        self.slideModalController.modalTitle = balance!.appending(" " + (self.erc20Token?.symbol)!)
        self.slideModalController.view.frame = self.ibo_scrollview!.frame
        self.slideModalController.delegate = self
        
        //Assign Child Class
        self.slideModalController.viewController = sendVC
        sendVC.token = self.erc20Token
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.contentOffset.y > 50 {
            if impactDetected == false {
                impact.impactOccurred()
                iba_sendToken()
            }
            self.impactDetected = true
        }
        
        if scrollView.contentOffset.y < -50 {
            if impactDetected == false {
                impact.impactOccurred()
                self.iba_dismiss()
            }
            self.impactDetected = true
        }
        
        if scrollView.contentOffset.y <= 50 && scrollView.contentOffset.y >= -50 {
            self.impactDetected = false;
        }
        
    }
    
    
}
