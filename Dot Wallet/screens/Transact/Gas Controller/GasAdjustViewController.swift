//Aguilar//
//  File.swift
//  Dot Wallet
//
//  Created by Franky Aguilar on 9/28/18.
//  Copyright © 2018 Ninth Industries. All rights reserved.
//
import Foundation
import UIKit

protocol GasAdjustViewControllerDelegate {
    
    func gasAdjustedWithValues(vc:GasAdjustViewController, gasLimit:Int, gasPrice:Int, totalCost:String)
}

class GasAdjustViewController: UIViewController {
    
    var delegate:GasAdjustViewControllerDelegate?
    
    @IBOutlet weak var ibo_gasLimitSlider:UISlider?
    @IBOutlet weak var ibo_gasPriceSlider:UISlider?
    
    @IBOutlet weak var ibo_txValue:UILabel?
    
    @IBOutlet weak var ibo_gasLimitValue:UILabel?
    @IBOutlet weak var ibo_gasPriceValue:UILabel?

    var gasPrice:Int!
    var gasLimit:Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func iba_dimissView(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func iba_doneAjusting(){
        self.delegate?.gasAdjustedWithValues(vc:self, gasLimit: self.gasLimit, gasPrice: self.gasPrice, totalCost: (self.ibo_txValue?.text)!)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.ibo_gasPriceValue!.text = String(describing: gasPrice!)
        self.ibo_gasLimitValue!.text = String(describing: gasLimit!)
        
        self.ibo_gasLimitSlider?.setValue(Float(self.gasLimit), animated: false)
        self.ibo_gasPriceSlider?.setValue(Float(self.gasPrice), animated: false)
        
        self.calculatePrice()
    }
    
    @IBAction func sliderAdjusted(sender:UISlider){
        if sender.tag == 0 {
            self.gasPrice = Int(sender.value)
            self.ibo_gasPriceValue!.text = "\(Int(sender.value))"
        }
        
        if sender.tag == 1 {
            self.gasLimit = Int(sender.value)
            self.ibo_gasLimitValue!.text = "\(Int(sender.value))"
        }
        
        self.calculatePrice()
    }
    
    func calculatePrice(){
        let total = gasPrice * gasLimit
        self.ibo_txValue!.text = EtherWallet.balance.WeiToValue(wei: String(total), dec: 10)
    }
    
}
