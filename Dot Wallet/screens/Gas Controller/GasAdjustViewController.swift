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
    
    func gasAdjustedWithValues(gasLimit:Int, gasPrice:Int, totalCost:String)
    
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
        
        gasPrice = 10
        gasLimit = 60000
        
    }
    
    @IBAction func iba_dimissView(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func iba_doneAjusting(){
        
    }

    
    override func viewDidAppear(_ animated: Bool) {
    
        super.viewDidAppear(animated)
        
        self.ibo_gasLimitSlider?.setValue(Float(self.gasLimit), animated: true)
        self.ibo_gasPriceSlider?.setValue(Float(self.gasPrice), animated: true)
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
        self.ibo_txValue!.text = EtherWallet.balance.WeiToValue(wei: String(total), dec: 9)
    }
    
}
