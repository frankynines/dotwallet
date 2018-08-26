//
//  TokenDetailViewController.swift
//  Dot Wallet
//
//  Created by Franky Aguilar on 8/2/18.
//  Copyright © 2018 Ninth Industries. All rights reserved.
//

import Foundation
import UIKit
import SafariServices

protocol TokenDetailDelegate {
    func openURL(url:String)
}

class TokenDetailViewController:UIViewController {
    
    var erc20Token:ERC20Token?
    var erc721Token:OErc721Token?
    
    @IBOutlet var ibo_name:UILabel?
    @IBOutlet var ibo_previewImageView:UIImageView?
    @IBOutlet var ibo_description:UILabel?
    
    var delegate:TokenDetailDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("View will disapeear")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        if erc721Token != nil {
            self.ibo_name?.text = erc721Token?.name
            self.ibo_description?.text = erc721Token?.description
            self.drawImage(url: erc721Token?.image_preview_url)
        }
        
    }
    override func viewDidAppear(_ animated: Bool) {
        
        self.ibo_previewImageView?.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        
        UIView.animate(withDuration: 1,
                       delay: 0,
                       usingSpringWithDamping: CGFloat(0.60),
                       initialSpringVelocity: CGFloat(1.2),
                       options: UIViewAnimationOptions.allowUserInteraction,
                       animations: {
                        self.ibo_previewImageView?.transform = CGAffineTransform.identity
        },
                       completion: { Void in()  }
        )
        
    }
    func drawImage(url:String?) {
        
        guard let imageURL = url?.replacingOccurrences(of: "'\'", with: "") else {return}
        
        DispatchQueue.global(qos: .background).async {
            do {
                let image = try UIImage(data: Data(contentsOf: URL(string: imageURL)!))
                DispatchQueue.main.async {
                    self.ibo_previewImageView?.image = image
                }
            } catch {
                
            }
            
        }
        
       
    }
    
    
    @IBAction func iba_share(){
        
    }
    
    @IBAction func iba_openAsset(){
        var openURL:String?
        if let url = self.erc721Token?.external_link {
            openURL = url
        } else {
            let assetID = self.erc721Token?.token_id
            let assetAddress = self.erc721Token?.asset_contract?.address
            let urlString = "https://opensea.io/assets/\(assetAddress)/\(assetID)"
            openURL = urlString
        }
        self.openURL(url: openURL!)
    }
    
    func openURL(url:String) {
        let tokenSmartContract = self.erc721Token?.asset_contract?.address!
        let tokenID = self.erc721Token?.token_id!
        let openSeaURL = "https://opensea.io/assets/" + tokenSmartContract! + "/" + tokenID!
        self.delegate?.openURL(url: openSeaURL)
    }
    
}
