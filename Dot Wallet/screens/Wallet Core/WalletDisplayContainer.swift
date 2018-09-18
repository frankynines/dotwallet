//
//  TokenDisplayContainerViewController.swift
//  Dot Wallet
//
//  Created by Franky Aguilar on 7/28/18.
//  Copyright © 2018 Ninth Industries. All rights reserved.
//

import Foundation
import UIKit
import SafariServices

enum PageViews:Int {
    case TokenPage = 0
    case CollectiblePage = 1
    case TXHistory = 2
}
class WalletDisplayViewController:UIViewController, UIPageViewControllerDelegate, UIScrollViewDelegate, WalletPageViewControllerDelegate, PopOverViewcontrollerDelegate, TokenDetailDelegate, ModalSlideOverViewcontrollerDelegate{
    
    @IBOutlet weak var ibo_walletName:UILabel?
    @IBOutlet weak var iboBalance: UILabel?
    @IBOutlet weak var ibo_walletAddress:UILabel?
    @IBOutlet weak var ibo_walletCardScrollView:UIScrollView!
    
    var ibo_walletPageController:WalletPageViewController!
    
    public var pageIndex:Int!
    var pages = [UIViewController]()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        ibo_walletName?.text = "Ethereum Wallet"
        ibo_walletAddress?.text = EtherWallet.account.address
        self.ibo_walletCardScrollView.delegate = self
        
        self.syncBalance()
        
        TXHistoryCacheManager.shared.loadTXHistory { (results) in
        }
    }
    
    @IBAction func iba_dismiss(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func walletPageCurrentPage(index: Int) {
        self.pageIndex = index
    }
    
    func syncBalance(){
        
        if (EtherWallet.account.hasAccount == true) {
            
            if let cacheBalance = UserDefaults.standard.value(forKey: "balance:\(EtherWallet.account.address!)") {
                self.iboBalance?.text = cacheBalance as? String
            } else {
                self.refreshBalance()
            }

        }
    }
    
    func refreshBalance(){
        
        EtherWallet.balance.etherBalance { balance in
            guard let networkbalance = balance else {
                return
            }
            let userBalanceKey = "balance:\(EtherWallet.account.address!)"
            UserDefaults.standard.set(networkbalance, forKey: userBalanceKey)
            self.iboBalance?.text = balance
        }
    }
    //NEW TOKEN
    func userCreateNewCollectible(){
        
        let storyboard = UIStoryboard(name: "CreateCollectible", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "UINavController")
        
        self.present(vc, animated: true) {
            //
        }
        
    }
    
    //TABBAR
    @IBAction func gotoPage(button:UIButton){
        button.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        
        UIView.animate(withDuration: 1.0,
                       delay: 0,
                       usingSpringWithDamping: CGFloat(0.20),
                       initialSpringVelocity: CGFloat(6.0),
                       options: UIViewAnimationOptions.allowUserInteraction,
                       animations: {
                        button.transform = CGAffineTransform.identity
        },
                       completion: { Void in()  }
        )
        
        if button.tag < self.pageIndex {
            self.ibo_walletPageController.setViewControllers([pages[button.tag]],
                                                             direction: .reverse,
                                                             animated: true,
                                                             completion: nil)
            self.pageIndex = button.tag
            return
        }
        if button.tag > self.pageIndex {
            self.ibo_walletPageController.setViewControllers([pages[button.tag]],
                                                             direction: .forward,
                                                             animated: true,
                                                             completion: nil)
            self.pageIndex = button.tag
            return
        }

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        
        if let pageController = destination as? WalletPageViewController {
            
            for i in 0..<pages.count {
                self.pages[i].view.tag = i
            }
            self.pageIndex = 0
            self.ibo_walletPageController = pageController
            self.pages = self.ibo_walletPageController.pages
            self.ibo_walletPageController.childDelegate = self
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -40 {
            self.iba_dismiss()
        }
    }
    
    // DISPLAY POPUP
    var popModalController:PopOverViewcontroller!
    //var tokenDetail: TokenDetailViewController!
    var transactionDetail: TransactionDetailViewController!
    
    //TOKEN SELECT
    func tokenDidSelectERC721(token: OErc721Token, tokenImage: UIImage?) {
 
        
        let vc = (UIStoryboard(name: "Collectibles", bundle: nil).instantiateViewController(withIdentifier: "sb_CollectibleDetailViewController") as! CollectibleDetailViewController)
        vc.erc721Token = token
        vc.tokenImage = tokenImage
        present(vc, animated: true) { }
    }
    
    func didSelectTXItem(transaction: GeneralTransactionData) {
        self.transactionDetail = (UIStoryboard(name: "TransactionHistory", bundle: nil).instantiateViewController(withIdentifier: "sb_TransactionDetailViewController") as! TransactionDetailViewController)
        self.transactionDetail.transaction = transaction
         self.transactionDetail.delegate = self
        self.presentSlideView(vc: self.transactionDetail, title: "Completed", size: .Compact)

    }
    
    func presentPopView(vc:UIViewController?, title:String){
        
        guard popModalController == nil else {
            return
        }
        
        self.popModalController = PopOverViewcontroller()
        self.popModalController = (UIStoryboard(name: "ModalControllers", bundle: nil).instantiateViewController(withIdentifier: "sb_PopOverViewcontroller") as! PopOverViewcontroller)
        self.popModalController.modalTitle = title
        self.popModalController.view.frame = self.view.frame
        self.popModalController.delegate = self
        
        self.popModalController.viewController = vc
        self.view.addSubview(self.popModalController.view)
        
    }
    
    func openURL(url: String) {
        let vc = SFSafariViewController(url: URL(string: url)!)
        self.present(vc, animated: true, completion: nil)
    }
    
    func popOverDismiss() {
        
        self.popModalController.animateModalOut {
            self.popModalController.view.removeFromSuperview()
            self.popModalController.removeFromParentViewController()
            self.popModalController = nil
            self.transactionDetail = nil
        }
    }
    
    // MODAL FOR SEND
    var slideModalController:ModalSlideOverViewcontroller!
    
    func presentSlideView(vc:UIViewController?, title:String, size:SlideSize){
        
        guard slideModalController == nil else {
            return
        }
        
        self.slideModalController = ModalSlideOverViewcontroller()
        self.slideModalController = (UIStoryboard(name: "ModalControllers", bundle: nil).instantiateViewController(withIdentifier: "sb_ModalSlideOverViewcontroller") as! ModalSlideOverViewcontroller)
        self.slideModalController.size = size
        self.slideModalController.modalTitle = title
        self.slideModalController.view.frame = self.view.frame
        self.slideModalController.delegate = self
        self.slideModalController.viewController = vc
        self.view.addSubview(self.slideModalController.view)
        
    }
    
    func modalSlideDismiss() {
        self.slideModalController.animateModalOut {
            self.slideModalController.view.removeFromSuperview()
            self.slideModalController.removeFromParentViewController()
            self.slideModalController = nil
        }
    }
    
}
