//
//  EtherWallet+GasEstimates.swift
//  Dot Wallet
//
//  Created by Franky Aguilar on 9/22/18.
//  Copyright © 2018 Ninth Industries. All rights reserved.
//

import Foundation

import web3swift
import BigInt

public protocol GasService {
    
    func gasForSendingEth(to address: String, amount: String) throws -> String
    func gasForContractMethod(contractAddress:String, methodName:String, methodParams:[Any?], completion: @escaping(ContractError?, Int?, Int?) -> ())
    
    func currentGasEstimate(completion: @escaping(Int) -> ())
}

extension EtherWallet: GasService {
    
    public func gasForSendingEth(to address: String, amount: String) throws -> String{
        
        guard let toAddress = EthereumAddress(address) else { throw WalletError.invalidAddress }
        let keystore = try loadKeystore()
        
        let keystoreManager = KeystoreManager([keystore])
        web3Main.addKeystoreManager(keystoreManager)
        
//        options.gasPrice = 2
        options.value = BigUInt(defaultGasLimitForTokenTransfer)
//        options.value = Web3.Utils.parseToBigUInt(amount, units: .eth)
        
        let intermediateSend = web3Main.contract(Web3.Utils.coldWalletABI, at: toAddress, abiVersion: 2)!.method(options: options)!
        
        let gas = intermediateSend.estimateGas(options: options)
        switch gas {
        case .success(let result):
            return String(result)
        case .failure(_):
            return "1000000"
        }
        
    }
    
    public func currentGasEstimate(completion: @escaping(Int) -> ()) {
        print(options)
        let intermediateSend = web3Main.eth.getGasPrice()
        switch intermediateSend {
        case .success(let result):
            completion(Int(result))
        case .failure(_):
            completion(Int(0))
            return
        }
    }

    public func gasForContractMethod(contractAddress:String, methodName:String, methodParams:[Any?], completion: @escaping(ContractError?, Int?, Int?) -> ()) {
        
        guard let contract = try! self.getEthereumContract(contractAddress: contractAddress, methodName: methodName, methodParams: methodParams) else {
            completion(ContractError.contractFailure, nil, nil)
            return
        }
        
        options.gasPrice = 2
        
        print(web3Main.eth.getTransactionCount(address: EthereumAddress(EtherWallet.account.address!)!))
        
        guard let contractMethod = contract.method(methodName, parameters: methodParams as [AnyObject], extraData: Data(), options: options) else {
            completion(ContractError.contractFailure, nil, nil)
            return
        }
        
        let gasEstimate = contractMethod.estimateGas(options: options, onBlock: "pending")
        switch gasEstimate {
        case .success(let result):
            completion(nil, 2, Int(result))
        case .failure(_):
            completion(nil, 2, Int(600000))
            return
        }
    }
    
}
