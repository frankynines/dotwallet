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
    
    @IBOutlet weak var ibo_walletName:UILabel!
    @IBOutlet weak var ibo_walletAddress:UILabel!
    @IBOutlet weak var ibo_walletCardScrollView:UIScrollView!
    
    var ibo_walletPageController:WalletPageViewController!
    
    fileprivate lazy var pages: [UIViewController] = {
        return [
            self.getViewController(withIdentifier: "sb_TokenListViewController"),
            self.getViewController(withIdentifier: "sb_CollectableListViewController"),
            self.getViewController(withIdentifier: "sb_TransactionViewController")
        ]
    }()
    
    public var pageIndex:Int!
    
    fileprivate func getViewController(withIdentifier identifier: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: identifier)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ibo_walletName.text = "Ethereum Wallet"
        ibo_walletAddress.text = EtherWallet.account.address
        self.ibo_walletCardScrollView.delegate = self
    }
    
    @IBAction func iba_dismiss(){

        self.dismiss(animated: true, completion: nil)
    }
    
    func walletPageCurrentPage(index: Int) {
        self.pageIndex = index
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
        
        if let headerView = destination as? WalletPageViewController {
            
            for i in 0..<pages.count {
                self.pages[i].view.tag = i
            }
            self.pageIndex = 0
            self.ibo_walletPageController = headerView
            self.ibo_walletPageController.pages = self.pages
            self.ibo_walletPageController.childDelegate = self
        }
       
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -40 {
            self.iba_dismiss()
        }
    }
    
}
