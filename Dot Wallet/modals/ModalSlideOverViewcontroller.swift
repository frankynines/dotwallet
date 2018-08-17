//
//  ModalSlideOverViewcontroller.swift
//  Dot Wallet
//
//  Created by Franky Aguilar on 7/31/18.
//  Copyright © 2018 Ninth Industries. All rights reserved.
//

import Foundation
import UIKit

enum SlideSize {
    case Compact
    case Full
}

protocol ModalSlideOverViewcontrollerDelegate {
    func modalSlideDismiss()
}

class ModalSlideOverViewcontroller: UIViewController, UIScrollViewDelegate  {
    
    @IBOutlet var ibo_modalTitle:UILabel?
    @IBOutlet weak var ibo_topConstraint:NSLayoutConstraint?
    
    //Containers
    @IBOutlet weak var ibo_containerScrollView:UIScrollView?
    @IBOutlet weak var ibo_containerView:UIView?
    @IBOutlet weak var ibo_contentView:UIView?
    
    var delegate:ModalSlideOverViewcontrollerDelegate?
    
    var modalTitle:String?
    var viewController:UIViewController?
    
    private let impact = UIImpactFeedbackGenerator()
    private var impactDetected = false
    
    var size:SlideSize?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ibo_containerScrollView?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.ibo_modalTitle?.text = self.modalTitle
        if viewController != nil {
            viewController?.view.frame = (self.ibo_contentView?.frame)!
            self.ibo_containerView?.addSubview((viewController?.view)!)
        }
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if self.size == .Compact {
            self.ibo_topConstraint?.constant = self.view.frame.size.height - 450
        } else {
            self.ibo_topConstraint?.constant = 40
        }
        
        
        // SET INITIAL STATE
        self.ibo_containerScrollView?.frame = CGRect(origin: CGPoint(x: 0, y: self.view.frame.size.height), size: self.view.frame.size)
        
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: CGFloat(0.85),
            initialSpringVelocity: CGFloat(1.3),
            options: UIViewAnimationOptions.allowUserInteraction,
            animations: {
                self.ibo_containerScrollView?.frame = CGRect(origin:
                    CGPoint(x: 0, y: 0), size: self.view.frame.size)
        })

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
        self.delegate?.modalSlideDismiss()
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
