//
//  ViewController.swift
//  FuyuWallet
//
//  Created by Franky Aguilar on 7/22/18.
//  Copyright © 2018 Ninth Industries. All rights reserved.
//

import UIKit
import Foundation
import web3swift
import BigInt
import QRCode
import BLTNBoard

class WalletHomeViewController: UIViewController {
    
    @IBOutlet var ibo_walletHeader:WalletHeaderViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        super.viewWillAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    @IBAction func iba_displayTokenViewController(){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "sb_SendViewController")
        present(vc!, animated: true) {
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        
        if let headerView = destination as? WalletHeaderViewController {
            self.ibo_walletHeader = headerView
        }
     
//        if let tokenListView = destination as? TransactionViewController {
//            ibo_transactionHistory = tokenListView
//            ibo_transactionHistory?.delegate = self
//        }
    }
    
    @IBAction func iba_showTokens(){
//        let vc = self.storyboard?.instantiateViewController(withIdentifier: "sb_WalletTokenViewController") as? WalletTokenViewController
//        vc?.hero.isEnabled = true
//
//
//        // this configures the built in animation
//        //    vc2.hero.modalAnimationType = .zoom
//        //    vc2.hero.modalAnimationType = .pageIn(direction: .left)
//        //    vc2.hero.modalAnimationType = .pull(direction: .left)
//        //    vc2.hero.modalAnimationType = .autoReverse(presenting: .pageIn(direction: .left))
//        vc?.hero.modalAnimationType = .selectBy(presenting: .pull(direction: .left), dismissing: .slide(direction: .right))
//
//        // lastly, present the view controller like normal
//        present(vc!, animated: true, completion: nil)
        
    }
    
//    func tableViewScroll(rect:CGRect) {
//        self.ibo_walletHeader?.view.frame = rect
//    }
//
//    func txRowSelected(row:Int, transaction:GeneralTransactionData) {
//
//        let bmanager = BLTNItemManager(rootItem: self.setupBLTNItem(transaction: transaction))
//        bmanager.cardCornerRadius = 20
//        bmanager.showBulletin(above: self)
//    }
    
    
//    func setupBLTNItem(transaction:GeneralTransactionData) -> BLTNPageItem {
//
//        let value = BigInt.init(transaction.value)
//        let amount = Web3.Utils.formatToPrecision(value!)
//
//        let page = BLTNPageItem(title: amount!)
//
//        page.descriptionText = transaction.from
//        page.appearance.descriptionFontSize = 10
//
//
//        let DotPurp = UIColor(hexString: "C0B9FF")
//        page.appearance.actionButtonColor = DotPurp
//        page.appearance.actionButtonTitleColor = .white
//
//        page.actionButtonTitle = "View on Etherscan"
//
//        page.actionHandler = { (item: BLTNActionItem) in
//            //UIPasteboard.general.string = EtherWallet.account.address
//        }
//        page.isDismissable = true
//
//        return page
//    }
    
}



