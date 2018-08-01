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
    func getTokenMetaData(contractAddress: String, completion: @escaping (ERC20Token) -> ())
    func getERC721Tokens(address:String, completion: @escaping ([JSON]?) -> ())
    func getTokenImage(contractAddress:String, completion: @escaping (UIImage) -> ())
}

extension EtherWallet: TokenService {
 
    public func getTokenMetaData(contractAddress: String, completion: @escaping (ERC20Token) -> ()) {
        DispatchQueue.global().async {

            
            let name = try? self.tokenMetaData(contractAddress: contractAddress, param: "name")
            let symbol = try? self.tokenMetaData(contractAddress: contractAddress, param: "symbol")
            let decimal = try? self.tokenMetaData(contractAddress: contractAddress, param: "decimals")
            
            let token = ERC20Token.init(name: name,
                                        symbol: symbol,
                                        contractAddress: contractAddress,
                                        decimal: decimal,
                                        imageURL:self.getTokenImageURL(contractAddress: contractAddress),
                                        balance: "0")
            
            DispatchQueue.main.async {
                completion(token)
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
    
    public func getTokenImageURL(contractAddress:String) -> String {
        return tokenImageSrcURL + contractAddress + ".png"
    }
    
    public func getTokenImage(contractAddress:String, completion: @escaping (UIImage) -> ()) {
        let imageURL = self.getTokenImageURL(contractAddress: contractAddress)
        
        var image = UIImage()
        
        do {
            let imgdata = try Data(contentsOf: URL(string: imageURL)!)
            image =  UIImage(data: imgdata)!
        } catch {
            image = UIImage(named: "icon_token_erc20.png")!
        }
        
        DispatchQueue.main.async {
            completion(image)
        }
    }
    
    public func getERC721Tokens(address:String, completion: @escaping ([JSON]?) -> ()){
        var url = URLComponents(string: "https://api.rarebits.io/v1/addresses/"+"0xe307c2d3236be4706e5d7601ee39f16d796d8195"+"/token_items")
        
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




