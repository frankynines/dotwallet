//
//  TokenDisplayContainerViewController.swift
//  Dot Wallet
//
//  Created by Franky Aguilar on 7/28/18.
//  Copyright © 2018 Ninth Industries. All rights reserved.
//

import Foundation
import UIKit
class WalletDisplayViewController:UIViewController, UIPageViewControllerDelegate, UIScrollViewDelegate, WalletPageViewControllerDelegate {
    
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
    }
    
    @IBAction func iba_dismiss(){

        self.dismiss(animated: true, completion: nil)
    }
    
    func walletPageCurrentPage(index: Int) {
        self.pageIndex = index
    }
    
    func syncBalance(){
        if (EtherWallet.account.hasAccount == true) {
            
            if let cacheBalance = UserDefaults.standard.value(forKey: "ETHBalance") {
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
            UserDefaults.standard.set(networkbalance, forKey: "ETHBalance")
            self.iboBalance?.text = balance
        }
    }
    
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
        
        //guard button.tag == self.pageIndex else {return}
        
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
    
}
