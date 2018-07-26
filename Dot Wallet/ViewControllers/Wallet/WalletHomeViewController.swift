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
import QRCode
import JModalController

class WalletHomeViewController: UIViewController, WalletHeaderDelegate, WalletTokenViewControllerDelegate {
    
    
    
    @IBOutlet var ibo_walletHeader:WalletHeaderViewController!
    @IBOutlet var ibo_tokenListView:WalletTokenViewController!
    
    var tokens = ["0xe3818504c1b32bf1557b16c238b2e01fd3149c17",
                  "0xf230b790e05390fc8295f4d3f60332c93bed42e2",
                  "0x4156D3342D5c385a87D264F90653733592000581",
                  "0x744d70fdbe2ba4cf95131626614a1763df805b9e",
                  "0xc5bbae50781be1669306b9e001eff57a2957b09d",
                  "0x42d6622dece394b54999fbd73d108123806f6a18",
                  "0xa74476443119A942dE498590Fe1f2454d7D4aC0d",
                  "0xd0a4b8946cb52f0661273bfbc6fd0e0c75fc6433",
                  "0x558ec3152e2eb2174905cd19aea4e34a23de9ad6",
                  "0xd850942ef8811f2a866692a623011bde52a462c1",
                  "0xe41d2489571d322189246dafa5ebde1f4699f498",
                  
                  ]
    
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
    
    func iba_presentReceiveModal() {
        let simpleVC = self.storyboard?.instantiateViewController(withIdentifier: "sb_ReceiveViewController") as! ReceiveViewController
   
        let config = JModalConfig(transitionDirection: .bottom, animationOptions: UIViewAnimationOptions.curveEaseInOut, animationDuration: 0.2, backgroundTransformPercentage: 0.95, backgroundTransform: true, tapOverlayDismiss: true, swipeDirections: [UISwipeGestureRecognizerDirection.down] )

        presentModal(self, modalViewController: simpleVC, config: config) {
            print("Presented Simple Modal")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        if let walletHeaderContainer = destination as? WalletHeaderViewController {
            ibo_walletHeader = walletHeaderContainer
            ibo_walletHeader.delegate = self
        }
        
        if let tokenListView = destination as? WalletTokenViewController {
            ibo_tokenListView = tokenListView
            ibo_tokenListView.tokens = self.tokens
            ibo_tokenListView.delegate = self
        }
    }
    
    //TABLE VIEW DELEGATES
    func walletTokenSelected(row: Int) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "sb_TransactionViewController") as! TransactionViewController
        vc.contractAddress = self.tokens[row]
        
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func walletTokenStretchHeader(rect: CGRect) {
        self.ibo_walletHeader.view.frame = rect
    }
}



