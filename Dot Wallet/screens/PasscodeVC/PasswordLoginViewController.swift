//
//  PasswordLoginViewController.swift
//  Dot Wallet
//
//  Created by Franky Aguilar on 8/26/18.
//  Copyright © 2018 Ninth Industries. All rights reserved.
//

import UIKit
import SmileLock
import KeychainAccess

enum PassState {
    case Create
    case Import
    case Verify
    case Unlock
    case Reset
}

@objc protocol PasswordLoginDelegate {
    @objc optional func createWalletWithPasscode(pass:String?)
    @objc optional func passcodeVerified(pass:String?)
}

class PasswordLoginViewController: UIViewController {
    
    @IBOutlet weak var ibo_passTitleView:UILabel?
    @IBOutlet weak var passwordStackView: UIStackView!
    
    var delegate:PasswordLoginDelegate?
    var modalTitle:String!
    var passState:PassState!
    
    //MARK: Property
    var passwordContainerView: PasswordContainerView!
    let kPasswordDigit = 4
    var kPass:String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        //create PasswordContainerView
        passwordContainerView = PasswordContainerView.create(in: passwordStackView, digit: kPasswordDigit)
        passwordContainerView.delegate = self
        passwordContainerView.deleteButtonLocalizedTitle = "Delete"
        
        //customize password UI
        passwordContainerView.tintColor = UIColor.gray
        
        var walletColor:String?
        if let color = UserPreferenceManager.shared.getKeyObject(key: "walletColor"){
            walletColor = color
        } else {
            walletColor = "333333"
        }
        
        passwordContainerView.highlightedColor = UIColor(hexString: walletColor!)
        
        self.ibo_passTitleView?.text = self.modalTitle
    }
    
    override func viewWillLayoutSubviews() {
        if passState == .Create || passState == .Verify || passState == .Reset{
            self.passwordContainerView.touchAuthenticationEnabled = false;
        } else {
            self.passwordContainerView.touchAuthenticationEnabled = true;
        }
    }
    
}

extension PasswordLoginViewController: PasswordInputCompleteProtocol {
    func passwordInputComplete(_ passwordContainerView: PasswordContainerView, input: String) {
        
        if passState == .Create {
            
            passwordContainerView.clearInput()
            self.ibo_passTitleView?.text = "Verify Password"
            self.kPass = input
            self.passState = .Verify
            return
        }
        
        if validation(input) {
            
            if passState == .Verify {
                newValidationSuccess()
            }
            
            if passState == .Unlock {
                validationSuccess()
            }
            
        } else {
            validationFail()
        }
    }
    
    func touchAuthenticationComplete(_ passwordContainerView: PasswordContainerView, success: Bool, error: Error?) {
        if success {
            self.validationSuccess()
        } else {
            passwordContainerView.clearInput()
        }
    }
    
}

private extension PasswordLoginViewController {
    
    func validation(_ input: String) -> Bool {
        return input == kPass
    }
    
    func validationFail() {
        passwordContainerView.wrongPassword()
    }
    
    func validationSuccess() {
        dismiss(animated: false) {
            self.delegate!.passcodeVerified!(pass: self.kPass)
        }
    }
    //CREATE NEW WALLET
    func newValidationSuccess(){
        dismiss(animated: false) {
            self.delegate!.createWalletWithPasscode!(pass: self.kPass)
        }
    }

}
