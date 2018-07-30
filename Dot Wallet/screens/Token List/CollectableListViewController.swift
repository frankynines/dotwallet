//
//  CollectableListViewController.swift
//  Dot Wallet
//
//  Created by Franky Aguilar on 7/28/18.
//  Copyright © 2018 Ninth Industries. All rights reserved.
//

import Foundation
import UIKit
import SwiftSVG

class CollectableListViewController:UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet var ibo_collectionView:UICollectionView?
    
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
    
    func buildTokenObject(element:String) {
        let data = element.data(using: .utf8)!
        do {
            let element = try JSONDecoder().decode(Erc721Token.self, from: data)
            
            self.tokens.append(element)
            self.ibo_collectionView?.reloadData()
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
    @IBOutlet var ibo_imageView:UIImageView?
    
    func setupCell(url:String){
       
        let imageURL = url.replacingOccurrences(of: "'\'", with: "")
        var image:UIImage?
        if imageURL.range(of:".svg") != nil {
            //need to draw SVG
            self.drawSVG(url:imageURL)
        } else {
            guard let imagefromurl = try? Data(contentsOf: URL(string: imageURL)!) else {
                image = UIImage(named: "icon_circledot.png")
                return
            }
            image = UIImage(data: imagefromurl)
        }
        
        self.ibo_imageView?.image = image
    }
    
    func drawSVG(url:String){
    
        let svgURL = URL(string: url)!
        
        let wevView = UIWebView(frame: (self.ibo_imageView?.frame)!)
        
        //Creating a page request which will load our URL (Which points to our path)
        let request: NSURLRequest = NSURLRequest(url: svgURL)
        wevView.loadRequest(request as URLRequest)  //Telling our webView to load our above request
        
        self.addSubview(wevView)
        
    }
}
