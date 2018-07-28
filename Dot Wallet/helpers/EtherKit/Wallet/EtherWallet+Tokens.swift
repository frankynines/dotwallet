//
//  EtherWallet+Tokens.swift
//  Dot Wallet
//
//  Created by Franky Aguilar on 7/25/18.
//  Copyright © 2018 Ninth Industries. All rights reserved.
//

import web3swift
import SwiftyJSON

public protocol TokenService {
    func getTokenMetaData(contractAddress: String, param:String, completion: @escaping (String?) -> ())
    func getERC721Tokens(address:String, completion: @escaping ([JSON]?) -> ())
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
        return data
    }
  
    
    public func getERC721Tokens(address:String, completion: @escaping ([JSON]?) -> ()){
        let testAddress = "0xe307C2d3236bE4706E5D7601eE39F16d796d8195"
        var url = URLComponents(string: "https://api.rarebits.io/v1/addresses/"+testAddress+"/token_items")
        
        url?.queryItems = [
            URLQueryItem(name: "api_key", value: "cc0a1c99-069c-4955-9ddd-a2f450aaa0f2")
        ]
        
        URLSession.shared.dataTask(with: (url?.url as URL?)!, completionHandler: {(data, response, error) -> Void in
            if data == nil {
                return
            }
            if (try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary) != nil {
                let json = JSON(data!)
                let result = json["entries"].arrayValue
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        }).resume()
    }
    
    
}
