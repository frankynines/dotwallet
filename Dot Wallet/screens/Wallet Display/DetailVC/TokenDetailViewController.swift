//
//  TokenDetailViewController.swift
//  Dot Wallet
//
//  Created by Franky Aguilar on 8/2/18.
//  Copyright © 2018 Ninth Industries. All rights reserved.
//

import Foundation
import UIKit

class TokenDetailViewController:UIViewController {
    
    var erc20Token:ERC20Token?
    var erc721Token:OErc721Token?
    
    @IBOutlet var ibo_name:UILabel?
    @IBOutlet var ibo_webview:UIWebView?
    @IBOutlet var ibo_description:UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        if erc721Token != nil {
            self.ibo_name?.text = erc721Token?.name
            self.ibo_description?.text = erc721Token?.description
            self.drawImage(url: erc721Token?.image_url)
        }
        ibo_webview?.backgroundColor = UIColor.clear
        ibo_webview?.scrollView.backgroundColor = UIColor.clear
        ibo_webview?.isOpaque = false
        
    }
    override func viewDidAppear(_ animated: Bool) {
        
        self.ibo_webview?.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        
        UIView.animate(withDuration: 1,
                       delay: 0,
                       usingSpringWithDamping: CGFloat(0.60),
                       initialSpringVelocity: CGFloat(1.2),
                       options: UIViewAnimationOptions.allowUserInteraction,
                       animations: {
                        self.ibo_webview?.transform = CGAffineTransform.identity
        },
                       completion: { Void in()  }
        )
        
    }
    func drawImage(url:String?) {
        if (url?.isEmpty)! {
            return
        }
        let displayURL = URL(string: url!)!
        
        let request: NSURLRequest = NSURLRequest(url: displayURL)
        ibo_webview?.loadRequest(request as URLRequest)
        ibo_webview?.isHidden = false
    }
    
    
    @IBAction func iba_share(){
        
    }
    
    @IBAction func iba_openAsset(){
        
    }
    
    
}
