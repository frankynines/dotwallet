//
//  TokenDisplayPageViewController.swift
//  Dot Wallet
//
//  Created by Franky Aguilar on 7/28/18.
//  Copyright © 2018 Ninth Industries. All rights reserved.
//

import Foundation
import UIKit

protocol WalletPageViewControllerDelegate {
    func walletPageCurrentPage(index:Int)
    func tokenDidSelectERC721(token:OErc721Token)
    func tokenDidSelectERC20(token:OERC20Token)
    func tokenDidSelectTransaction(transaction:GeneralTransactionData)
}

class WalletPageViewController: UIPageViewController{
    
    var childDelegate:WalletPageViewControllerDelegate?
    
    lazy var pages: [UIViewController] = {
        return [
             UIStoryboard(name: "ERC20Tokens", bundle: nil).instantiateViewController(withIdentifier: "sb_TokenListViewController"),
            UIStoryboard(name: "Collectibles", bundle: nil).instantiateViewController(withIdentifier: "sb_CollectibleListViewController"),
            UIStoryboard(name: "TransactionHistory", bundle: nil).instantiateViewController(withIdentifier: "sb_TransactionViewController")
        ]
    }()
    
    var pageIndex = 0    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        self.delegate   = self
        
        if let firstVC = pages.first {
            setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
            pageIndex = 0
        }
    }
    
    fileprivate func getViewController(withIdentifier identifier: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: identifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // ASSIGN DELEGATES
        let tokenVC = self.pages[PageViews.TokenPage.rawValue] as! TokenListViewController
        tokenVC.delegate = childDelegate
        
        let collectionVC = self.pages[PageViews.CollectiblePage.rawValue] as! CollectibleListViewController
        collectionVC.delegate = childDelegate
        
        let transactionVC = self.pages[PageViews.TXHistory.rawValue] as! TransactionViewController
        transactionVC.delegate = childDelegate
    }
    
}

extension WalletPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = pages.index(of: viewController) else { return nil }

        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else { return nil }
        guard pages.count > previousIndex else { return nil }
        
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        //Next VC index
        guard let viewControllerIndex = pages.index(of: viewController) else { return nil }

        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < pages.count else { return nil } // Stop Repeat
        guard pages.count > nextIndex else { return nil }
        
        return pages[nextIndex]
        
    }
}

extension WalletPageViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {

        let index = pageViewController.viewControllers?.first?.view.tag
        self.childDelegate?.walletPageCurrentPage(index: index!)
    }
}

