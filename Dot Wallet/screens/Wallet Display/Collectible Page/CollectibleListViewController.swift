//
//  CollectibleListViewController.swift
//  Dot Wallet
//
//  Created by Franky Aguilar on 7/28/18.
//  Copyright © 2018 Ninth Industries. All rights reserved.
//

import Foundation
import UIKit
import SafariServices
class CollectibleListViewController:UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    
    @IBOutlet var ibo_collectionView:UICollectionView?
    @IBOutlet var ibo_tableHeader:UILabel?
    
    var delegate:WalletPageViewControllerDelegate?

    var tokens = [OErc721Token]()

    var blackListContracts = [ "Decentraland" : "0xf87e31492faf9a91b02ee0deaad50d51d56d5d4d"
                               ]
    var pageIndex = 0
    var isWating = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadTokens(page: String(pageIndex))
        
        self.ibo_collectionView?.backgroundColor = UIColor(patternImage: UIImage(named: "bg_transparent")!)
        self.ibo_collectionView?.contentInset = UIEdgeInsetsMake(20, 0, 40, 0)
        
        //
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let padding:CGFloat = 5
        let width = (self.ibo_collectionView?.frame.size.width)! / 2
        layout.itemSize = CGSize(width: width - (padding * 2), height: width)
        layout.sectionInset = UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding)
        layout.minimumLineSpacing = padding
        layout.minimumInteritemSpacing = padding
        self.ibo_collectionView?.setCollectionViewLayout(layout, animated: false)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if self.tokens.count > 0 {
            self.ibo_collectionView?.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    func loadTokens(page:String){
        var testAddress:String?
        var token:String?
        if  UserDefaults.standard.bool(forKey: "ISLIVE") == true {
            testAddress = EtherWallet.account.address
            token = nil
        } else {
            testAddress = "0xef07a57c4cf84eed6739cf3ffd5edf40237431da"
        }
        EtherWallet.tokens.getERC721Tokens(address: testAddress!, tokenAddress:token, page: page) { (jsonResult) in
            if jsonResult == nil {
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
            
            if (element.image_url?.isEmpty)! {
                return
            }
            if (element.asset_contract?.address == "0xf87e31492faf9a91b02ee0deaad50d51d56d5d4d") {
                return
            }
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
        
        if let imageURL = self.tokens[indexPath.row].image_preview_url {
            DispatchQueue.global(qos: .background).async {
                // Call your background task
                DispatchQueue.main.async {
                   cell.setupCell(url: imageURL)
                }
            }
            
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {

        let width = ((self.ibo_collectionView?.frame.size.width)!/2)
        return CGSize(width: width, height: width)

    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//            if indexPath.item == self.tokens.count - 2 && !isWating {
//                isWating = true
//                self.pageIndex += 1
//                self.loadTokens(page: String(self.pageIndex))
//            }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate?.tokenDidSelectERC721(token: self.tokens[indexPath.item])
        print(self.tokens[indexPath.item])
    }
    
}

class CollectableViewCell:UICollectionViewCell {
    @IBOutlet var ibo_previewImage:UIImageView?
    @IBOutlet var ibo_activityView:UIActivityIndicatorView?
    
    func setupCell(url:String?) {
        self.ibo_previewImage!.image = nil
        self.ibo_activityView?.startAnimating()
        
        guard let imageURL = url?.replacingOccurrences(of: "'\'", with: "") else {return}
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let image = try UIImage(data: Data(contentsOf: URL(string: imageURL)!))
                DispatchQueue.main.async {
                    self.ibo_previewImage?.image = image
                    self.ibo_activityView?.stopAnimating()
                }
            } catch {
            }
        }
    }

}
