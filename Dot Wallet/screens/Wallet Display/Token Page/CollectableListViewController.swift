//
//  CollectableListViewController.swift
//  Dot Wallet
//
//  Created by Franky Aguilar on 7/28/18.
//  Copyright © 2018 Ninth Industries. All rights reserved.
//

import Foundation
import UIKit

class CollectableListViewController:UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet var ibo_collectionView:UICollectionView?
    @IBOutlet var ibo_tableHeader:UILabel?

    var tokens = [Erc721Token]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        EtherWallet.tokens.getERC721Tokens(address: (EtherWallet.account.address)!) { (jsonResult) in
            if jsonResult == nil {
                return
            }
            for element in jsonResult! {
                self.buildTokenObject(element: element.rawString()!)
            }
        }
        
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
    
    func buildTokenObject(element:String) {
        let data = element.data(using: .utf8)!
        do {
            let element = try JSONDecoder().decode(Erc721Token.self, from: data)
            
           // self.append([element])
            self.tokens.append(element)
            self.ibo_collectionView?.reloadData()
        } catch {
            //print(error.localizedDescription)
        }
        
        self.ibo_tableHeader?.text = String(self.tokens.count) + " Collectibles"

    }
    
    private func append(_ objectsToAdd: [Erc721Token]) {
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
    
}

class CollectableViewCell:UICollectionViewCell {
    @IBOutlet var ibo_webViewDisplay:UIWebView?
    
    func setupCell(url:String){
        //print(url)
        self.ibo_webViewDisplay?.isHidden = true
        self.ibo_webViewDisplay?.backgroundColor = UIColor.clear
        self.ibo_webViewDisplay?.scrollView.isScrollEnabled = false
       
        let imageURL = url.replacingOccurrences(of: "'\'", with: "")
        
        if imageURL.range(of:".svg") != nil {
            
            for view in (self.ibo_webViewDisplay?.subviews)! {
                if view.superclass == UIImageView.self {
                    view.removeFromSuperview()
                }
            }
            
            self.drawSVG(url:imageURL)
        
        } else {
            
            var image:UIImage?
            let imageView = UIImageView()
            imageView.frame = (self.ibo_webViewDisplay?.frame)!
            imageView.contentMode = .scaleAspectFit
            guard let imagefromurl = try? Data(contentsOf: URL(string: imageURL)!) else {
                image = UIImage(named: "icon_circledot.png")
                imageView.image = image
                return
            }
            imageView.image = UIImage(data: imagefromurl)
            self.ibo_webViewDisplay?.addSubview(imageView)
        
        }
        
    }
    
    func drawSVG(url:String){
    
        let svgURL = URL(string: url)!
        
        let request: NSURLRequest = NSURLRequest(url: svgURL)
        self.ibo_webViewDisplay?.loadRequest(request as URLRequest)
        self.ibo_webViewDisplay?.isHidden = false
    }
    
}
