//
//  CollectableListViewController.swift
//  Dot Wallet
//
//  Created by Franky Aguilar on 7/28/18.
//  Copyright © 2018 Ninth Industries. All rights reserved.
//

import Foundation
import UIKit
class CollectableListViewController:UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{
    
    @IBOutlet var ibo_collectionView:UICollectionView?
    @IBOutlet var ibo_tableHeader:UILabel?
    
    var delegate:WalletPageViewControllerDelegate?

    var tokens = [OErc721Token]()
    
    var whiteSmartContracts = ["CryptoKitties" : "0x06012c8cf97BEaD5deAe237070F9587f8E7A266d",
                               "CryptoPunks" : "0xb47e3cd837ddf8e4c57f05d70ab865de6e193bbb",
                               "CryptoCrystals" : "0xcfbc9103362aec4ce3089f155c2da2eea1cb7602",
                               "Etheremon" : "0xb2c0782ae4a299f7358758b2d15da9bf29e1dd99",
                               "CryptoBots" : "0xF7a6E15dfD5cdD9ef12711Bd757a9b6021ABf643",
                               "John Orion Young" : "0x96313f2c374f901e3831ea6de67b1165c4f39a54",
                               "Digital Art Chain" : "0x323a3e1693e7a0959f65972f3bf2dfcb93239dfe",
                               
                               ]
    
    var pageIndex = 0
    var isWating = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadTokens(page: String(pageIndex))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if self.tokens.count > 0 {
            self.ibo_collectionView?.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    func loadTokens(page:String){
        print("Load Tokens")
        EtherWallet.tokens.getERC721Tokens(address: ("0xe307C2d3236bE4706E5D7601eE39F16d796d8195"), tokenAddress:"0x06012c8cf97BEaD5deAe237070F9587f8E7A266d", page: page) { (jsonResult) in
            if jsonResult == nil {
                //print(jsonResult)
                return
            }
            for element in jsonResult! {
                self.buildTokenObject(element: element.rawString()!)
            }
        }
        isWating = false
    }
    
    func buildTokenObject(element:String) {
        let data = element.data(using: .utf8)!
        do {
            let element = try JSONDecoder().decode(OErc721Token.self, from: data)

            self.tokens.append(element)
            
        } catch {
            print(error.localizedDescription)
        }
        

        self.ibo_collectionView?.reloadData()
        self.ibo_tableHeader?.text = String(self.tokens.count) + " Collectibles"

    }
    
    private func append(_ objectsToAdd: [OErc721Token]) {
        for i in 0 ..< objectsToAdd.count {
            DispatchQueue.main.async {
                self.tokens.append(objectsToAdd[i])
                self.ibo_collectionView?.insertItems(at: [IndexPath(item: self.tokens.count - 1, section: 0)])
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.tokens.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectableViewCell
        
        if let imageURL = self.tokens[indexPath.row].image_url {
            DispatchQueue.global(qos: .background).async {
                // Call your background task
                DispatchQueue.main.async {
                   cell.setupCell(url: imageURL)
                }
            }
            
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
            if indexPath.item == self.tokens.count - 2 && !isWating {
                isWating = true
                self.pageIndex += 1
                self.loadTokens(page: String(self.pageIndex))
            }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate?.tokenDidSelectERC721(token: self.tokens[indexPath.item])
    }

    
    
}

class CollectableViewCell:UICollectionViewCell {
    @IBOutlet var ibo_webViewDisplay:UIWebView?
    
    func setupCell(url:String?){
        //print(url)
        self.ibo_webViewDisplay?.backgroundColor = UIColor.clear
        self.ibo_webViewDisplay?.scrollView.isScrollEnabled = false
        self.ibo_webViewDisplay?.contentMode = .scaleAspectFit
        self.ibo_webViewDisplay?.scalesPageToFit = true
       
        guard let imageURL = url?.replacingOccurrences(of: "'\'", with: "") else {return}
       
        self.drawImage(url:imageURL)
        
        if imageURL.range(of:"svg") != nil {
            self.ibo_webViewDisplay?.contentMode = .scaleAspectFit
            self.ibo_webViewDisplay?.scalesPageToFit = false
        }
//
//            for view in (self.ibo_webViewDisplay?.subviews)! {
//                if view.superclass == UIImageView.self {
//                    view.removeFromSuperview()
//                }
//            }
//
//            self.drawSVG(url:imageURL)
//
//        } else {
//
//
//
//        }
        
    }
    
    func drawImage(url:String?) {
        if (url?.isEmpty)! {
            return
        }
        let displayURL = URL(string: url!)!
        
        let request: NSURLRequest = NSURLRequest(url: displayURL)
        self.ibo_webViewDisplay?.loadRequest(request as URLRequest)
        self.ibo_webViewDisplay?.isHidden = false
    }
    
   
    
}
