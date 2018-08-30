//
//  PopOverViewcontroller.swift
//  Dot Wallet
//
//  Created by Franky Aguilar on 7/31/18.
//  Copyright © 2018 Ninth Industries. All rights reserved.
//

import Foundation
import UIKit

protocol PopOverViewcontrollerDelegate {
    func popOverDismiss()
}

class PopOverViewcontroller: UIViewController, UIScrollViewDelegate  {
    
    @IBOutlet var ibo_modalTitle:UILabel?
    
    //Containers
    @IBOutlet weak var ibo_containerScrollView:UIScrollView?
    @IBOutlet weak var ibo_containerView:UIView?
    @IBOutlet weak var ibo_contentView:UIView?
    

    var modalTitle:String?
    var viewController:UIViewController?
    
    let impact = UIImpactFeedbackGenerator()
    var impactDetected = false
    
    var delegate:PopOverViewcontrollerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ibo_containerScrollView?.delegate = self
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.ibo_containerScrollView?.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: CGFloat(0.50),
                       initialSpringVelocity: CGFloat(1.2),
                       options: UIViewAnimationOptions.allowUserInteraction,
                       animations: {
                        self.ibo_containerScrollView?.transform = CGAffineTransform.identity
        },
                       completion: { Void in()  }
        )
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.ibo_modalTitle?.text = self.modalTitle
        
        if viewController != nil {
            
            viewController?.view.frame = (self.ibo_contentView?.frame)!
            self.ibo_containerView?.addSubview((viewController?.view)!)
        }
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    override  func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    // CHILD VIEW DELEGATES
    
    func modalCompleteAction(result: Bool) {
        self.iba_dismissModal()
    }
    
    @IBAction func iba_dismissModal(){
        self.delegate?.popOverDismiss()
    }
    
    func animateModalOut( completion: @escaping() ->()){
        
        UIView.animate(withDuration: 0.35, delay: 0.1, options: .curveEaseInOut, animations: {
            self.ibo_containerScrollView?.frame = CGRect(origin: CGPoint(x: 0, y: self.view.frame.size.height), size: self.view.frame.size)
        }) { (complete) in
            if complete {
                completion()
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -100 {
            
            if impactDetected == false {
                impact.impactOccurred()
                self.ibo_containerScrollView?.delegate = nil
                self.iba_dismissModal()
            }
            self.impactDetected = true
        }
    }
    
    
}
