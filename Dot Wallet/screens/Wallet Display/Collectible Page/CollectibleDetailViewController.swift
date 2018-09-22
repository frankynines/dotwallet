//
//  CollectibleDetailViewController.swift
//  Dot Wallet
//
//  Created by Franky Aguilar on 8/30/18.
//  Copyright © 2018 Ninth Industries. All rights reserved.
//

import Foundation
import UIKit
import SafariServices

class CollectibleDetailViewController: UIViewController, UIScrollViewDelegate, ModalSlideOverViewcontrollerDelegate {

    var erc721Token:OErc721Token?
    
    @IBOutlet var ibo_previewImageView:UIImageView?
    @IBOutlet var ibo_name:UILabel?

    @IBOutlet var ibo_description:UILabel?
    @IBOutlet var ibo_scrollview:UIScrollView?
    
    var delegate:TokenDetailDelegate?
    var tokenImage:UIImage?
    
    @IBOutlet var ibo_bottomConstraint:NSLayoutConstraint?

    override func viewDidLoad() {
        
        self.ibo_scrollview?.delegate = self
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if erc721Token != nil {
            self.ibo_name?.text = erc721Token?.name
            self.ibo_description?.text = erc721Token?.description
            
            if tokenImage != nil {
                self.drawImage(url: erc721Token?.image_preview_url)
            } else {
                self.ibo_previewImageView!.image = tokenImage
            }
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
                print(error.localizedDescription)
            }
        }
    }
    
    @IBAction func iba_dismiss(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func iba_openAsset(){
        var openURL:String?
        if let url = self.erc721Token?.external_link {
            openURL = url
        } else {
            let assetID = self.erc721Token?.token_id
            let assetAddress = self.erc721Token?.asset_contract?.address
            let urlString = "https://opensea.io/assets/\(assetAddress!)/\(assetID!)"
            openURL = urlString
        }
        self.openURL(url: openURL!)
    }
    
    func openURL(url:String) {
        
        let tokenSmartContract = self.erc721Token?.asset_contract?.address!
        let tokenID = self.erc721Token?.token_id!
        let openSeaURL = "https://opensea.io/assets/" + tokenSmartContract! + "/" + tokenID!
        
        let vc = SFSafariViewController(url: URL(string: openSeaURL)!)
        self.present(vc, animated: true, completion: nil)
        
    }

    // MODAL FOR SEND
    lazy var sendVC: SendViewController = {
        return UIStoryboard(name: "Collectibles", bundle: nil).instantiateViewController(withIdentifier: "sb_SendViewController") as! SendViewController
    }()
    
    var slideModalController:ModalSlideOverViewcontroller!
    
    @IBAction func iba_sendToken(){
        
        guard slideModalController == nil else {
            return
        }
        
        self.animateCard(constant: 250)
        
        self.slideModalController = ModalSlideOverViewcontroller()
        self.slideModalController = (UIStoryboard(name: "ModalControllers", bundle: nil).instantiateViewController(withIdentifier: "sb_ModalSlideOverViewcontroller") as! ModalSlideOverViewcontroller)
        
        self.slideModalController.modalTitle = "Send"
        self.slideModalController.view.frame = self.ibo_scrollview!.frame
        self.slideModalController.delegate = self
        self.slideModalController.size = .Compact
        
        //Assign Child Class
        self.slideModalController.viewController = sendVC
        sendVC.collectible = self.erc721Token
        sendVC.delegate = self
        
        self.view.addSubview(self.slideModalController.view)
        
    }
    func modalSlideDismiss() {
        self.animateCard(constant: 0)
        
        self.slideModalController.animateModalOut {
            self.slideModalController.view.removeFromSuperview()
            self.slideModalController.removeFromParentViewController()
            self.slideModalController = nil
        }
    }
    
    func animateCard(constant:CGFloat) {
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: CGFloat(0.85),
            initialSpringVelocity: CGFloat(1.3),
            options: UIViewAnimationOptions.allowUserInteraction,
            animations: {
                self.ibo_bottomConstraint?.constant = constant
        })
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
//        if scrollView.contentOffset.y > 50 {
//            iba_sendToken()
//        }
    
    }
    
}
