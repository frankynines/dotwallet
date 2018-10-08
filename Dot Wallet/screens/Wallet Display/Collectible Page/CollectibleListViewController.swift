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
    
    @IBOutlet var ibo_emptyMessage:UILabel?
        
    var delegate:WalletPageViewControllerDelegate?

    var tokens = [OErc721Token]()

    var pageIndex = 0
    var pageOffset = 20
    
    var isWaiting = false
    var isOverLoad = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.ibo_collectionView?.addSubview(self.refreshControl)
        self.ibo_collectionView?.backgroundColor = UIColor(patternImage: UIImage(named: "bg_transparent")!)
        self.ibo_collectionView?.contentInset = UIEdgeInsetsMake(20, 0, 40, 0)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let padding:CGFloat = 5
        let width = (self.ibo_collectionView?.frame.size.width)! / 2
        layout.itemSize = CGSize(width: width - (padding * 2), height: width)
        layout.sectionInset = UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding)
        layout.minimumLineSpacing = padding
        layout.minimumInteritemSpacing = padding
        self.ibo_collectionView?.setCollectionViewLayout(layout, animated: false)
        self.loadTokens(page: "0")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    func loadTokens(page:String){

        let userAddress = EtherWallet.account.address!
        if self.isOverLoad {
            return
        }
        
        EtherWallet.tokens.getERC721Tokens(address: userAddress, tokenAddress:nil, page: page, pageOffset: String(self.pageOffset)) { (result) in
            let json = result?.dictionaryValue
            
            if (json!["assets"]?.arrayValue.count)! <= 0{
                self.isOverLoad = true
                return
            }
            
            for element in (json!["assets"]?.arrayValue)! {
                self.buildTokenObject(element: element.rawString()!)
            }
            self.isWaiting = false
        }
    }
    
    func buildTokenObject(element:String) {

        let data = element.data(using: .utf8)!
        do {
            let element = try JSONDecoder().decode(OErc721Token.self, from: data)
            if (element.image_url?.isEmpty)! {
                return
            }
            self.tokens.append(element)
            
        } catch {
            print(error.localizedDescription)
        }
        self.ibo_collectionView?.reloadData()
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
                DispatchQueue.main.async {
                   cell.setupCell(url: imageURL)
                }
            }
        } else {
            cell.ibo_previewImage!.image = nil
        }
        return cell
    }
    
    private func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {

        let width = ((self.ibo_collectionView?.frame.size.width)!/2)
        return CGSize(width: width, height: width)

    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (self.isWaiting){ return }
        
        if indexPath.item == self.tokens.count - 1 {
            self.isWaiting = true
            self.pageIndex += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.loadTokens(page: String(self.pageIndex * self.pageOffset))
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CollectableViewCell
        self.delegate?.tokenDidSelectERC721(token: self.tokens[indexPath.item], tokenImage: cell.tokenImage)
    }
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(self.handleRefresh(_:)),
                                 for: UIControlEvents.valueChanged)
        return refreshControl
        
    }()
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        
        self.tokens.removeAll()
        self.pageIndex = 0
        self.pageOffset = 20
        self.ibo_collectionView?.reloadData()
        
        self.isOverLoad = false
        self.loadTokens(page: "0")
        
        refreshControl.endRefreshing()
    }

    @IBAction func iba_newToken(){
        self.delegate?.userCreateNewCollectible()
    }
    
    @IBAction func iba_openOpenSea(){
        
        let url = URL(string: "https://rinkeby.opensea.io/assets/dottestcollectible")
        let vc = SFSafariViewController(url: url!)
        self.present(vc, animated: true) {
        }
    }
    
}

class CollectableViewCell:UICollectionViewCell {
    
    var tokenImage:UIImage?

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
                    self.tokenImage = image
                    self.ibo_activityView?.stopAnimating()
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    

}
