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
}

class WalletPageViewController: UIPageViewController{
    var childDelegate:WalletPageViewControllerDelegate?
    
    lazy var pages: [UIViewController] = {
        return [
            self.getViewController(withIdentifier: "sb_TokenListViewController"),
            self.getViewController(withIdentifier: "sb_CollectableListViewController"),
            self.getViewController(withIdentifier: "sb_TransactionViewController")
        ]
    }()
    
    var pageIndex = 0
    var currentVC:UIViewController?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        self.delegate   = self
        
    }
    
    fileprivate func getViewController(withIdentifier identifier: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: identifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let firstVC = pages.first {
            setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
            pageIndex = 0
        }
    }
    func sayHello(){
        print("JELLO")
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

