//
//  EtherWallet+Tokens.swift
//  Dot Wallet
//
//  Created by Franky Aguilar on 7/25/18.
//  Copyright © 2018 Ninth Industries. All rights reserved.
//

import web3swift

public protocol TokenService {
    func getTokenMetaData(contractAddress: String, param:String, completion: @escaping (String?) -> ())

}

extension EtherWallet: TokenService {


    public func getTokenMetaData(contractAddress: String, param:String, completion: @escaping (String?) -> ()) {
        DispatchQueue.global().async {
            let data = try? self.tokenMetaData(contractAddress: contractAddress, param: param)
            DispatchQueue.main.async {
                completion(data)
            }
        }
    }
    
    public func tokenMetaData(contractAddress: String, param:String) throws -> String {
        let contractEthreumAddress = EthereumAddress(contractAddress)
        
        let web3Main = Web3.InfuraMainnetWeb3() // USED TO GET MAIN NET TOKEN INFO
        guard let contract = web3Main.contract(Web3.Utils.erc20ABI, at: contractEthreumAddress) else { throw
            WalletError.invalidAddress
        }
        
        let contractMethod = contract.method(param, extraData: Data(), options: options)
        let callResult = contractMethod?.call(options: nil)
        guard case .success(let package)? = callResult, let data = package["0"] as? String else { throw WalletError.networkFailure
        }
        print(data)
        return data
    }
}
