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
    case Verify
    case Unlock
    case Reset
}

protocol PasswordLoginDelegate {
    func setLoginPasscode(pass:String?)
    func unlockWalletWithPasscode(pass:String?)
    func setLoginSuccess()
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
        passwordContainerView.highlightedColor = UIColor.purple
        
        self.ibo_passTitleView?.text = self.modalTitle
    }
    
}

extension PasswordLoginViewController: PasswordInputCompleteProtocol {
    func passwordInputComplete(_ passwordContainerView: PasswordContainerView, input: String) {
        
        if passState == .Create {
            passwordContainerView.clearInput()

            self.delegate?.setLoginPasscode(pass: input)

            self.ibo_passTitleView?.text = "Verify Password"
            self.passState = .Verify
            
            return
        }
        
        if passState == .Reset {
            
            passwordContainerView.clearInput()
            
            self.delegate?.unlockWalletWithPasscode(pass: input)
            
            self.ibo_passTitleView?.text = "Verify Password"
            self.passState = .Verify
            
            return
        }
        
        if validation(input) {
            
            if passState == .Verify {
                validationSuccess()
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
    
    func validationSuccess() {
        dismiss(animated: false) {
            self.delegate?.setLoginSuccess()
        }
    }
    
    func validationFail() {
        passwordContainerView.wrongPassword()
    }
}
