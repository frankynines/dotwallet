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

class WalletHomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, WalletHeaderDelegate {
    
    @IBOutlet var ibo_tableView:UITableView!
    @IBOutlet var ibo_walletHeader:WalletHeaderViewController!
    
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
        ibo_tableView.contentInset = UIEdgeInsetsMake(self.ibo_walletHeader.view.frame.height - 50, 0, 0, 0)
        super.viewWillAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.ibo_tableView.reloadData()
    }

    @IBAction func displaySendViewController(){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "sb_SendViewController")
        present(vc!, animated: true) {
        }
    }
    
    func iba_presentReceiveModal() {
        let simpleVC = self.storyboard?.instantiateViewController(withIdentifier: "sb_ReceiveViewController") as! ReceiveViewController
        
        //Set the delegate in order to dismiss the modal
        //        simpleVC?.delegate = self
        
        //Set configuration settings to customize how the modal presents
        let config = JModalConfig(transitionDirection: .bottom, animationOptions: UIViewAnimationOptions.curveEaseInOut, animationDuration: 0.2, backgroundTransformPercentage: 0.95, backgroundTransform: true, tapOverlayDismiss: true, swipeDirections: [UISwipeGestureRecognizerDirection.down] )
        
        //Present the modal!
        //`self` if no navigation or tabBar controllers are present!
        presentModal(self, modalViewController: simpleVC, config: config) {
            print("Presented Simple Modal")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //TABLE VIEW
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tokens.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "token") as! WalletTokenCell
        cell.alpha = 0;
            DispatchQueue.global(qos: .background).async {
                // Call your background task
                DispatchQueue.main.async {
                    cell.setupCell(_tokenAddress: self.tokens[indexPath.row])
                }
            }
        
        
            return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = 250 - (scrollView.contentOffset.y + 200)
        let height = min(max(y, 265), 800)
        self.ibo_walletHeader.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: height)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        if let walletHeaderContainer = destination as? WalletHeaderViewController {
            ibo_walletHeader = walletHeaderContainer
            ibo_walletHeader.delegate = self
        }
    }
}

class WalletTokenCell:UITableViewCell {
    
    @IBOutlet var iboTokenImage:UIImageView!
    @IBOutlet var iboTokenName:UILabel!
    @IBOutlet var iboTokenSymbol:UILabel!
    @IBOutlet var iboTokenBalance:UILabel!
    @IBOutlet var iboTokenFiat:UILabel!
    
    var tokenImageAddress = "https://raw.githubusercontent.com/trustwallet/tokens/master/images/"
    
    func setupCell(_tokenAddress:String!){
        
        let imageURL = tokenImageAddress + _tokenAddress + ".png"
        do {
            let imgdata = try Data(contentsOf: URL(string: imageURL)!)
            self.iboTokenImage.image = UIImage(data: imgdata)
        } catch {
            print("Failed to load token image")
        }
        
        self.syncTokenBalance(_tokenAddress: _tokenAddress)
        
    }
    
    func syncTokenBalance(_tokenAddress:String!){
        EtherWallet.balance.tokenBalance(contractAddress: _tokenAddress) { (balance) in
            self.iboTokenBalance.text = balance
        }
        
        EtherWallet.tokens.getTokenMetaData(contractAddress: _tokenAddress, param: "name") { (result) in
            self.iboTokenName.text = result
        }
        
        EtherWallet.tokens.getTokenMetaData(contractAddress: _tokenAddress, param: "symbol") { (symbol) in
            self.iboTokenSymbol.text = symbol
        }
        
        self.alpha = 1

    }
}

