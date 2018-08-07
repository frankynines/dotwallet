//
//  EtherWallet+Tokens.swift
//  Dot Wallet
//
//  Created by Franky Aguilar on 7/25/18.
//  Copyright © 2018 Ninth Industries. All rights reserved.
//

import web3swift
import SwiftyJSON
import Cache

public protocol TokenService {
    func getTokenMetaData(contractAddress: String, completion: @escaping (ERC20Token) -> ())
    func getERC721Tokens(address:String, tokenAddress:String?, page:String, completion: @escaping ([JSON]?) -> ())
    func getTokenImage(contractAddress:String, completion: @escaping (UIImage) -> ())
    
    func getERC20TokenList(url:String, completion: @escaping ([JSON]?) -> ())
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
    
    public func getERC20TokenList(url:String, completion: @escaping ([JSON]?) -> ()){
        
        let request = URLRequest(url: URL(string: url)!)
        URLSession.shared.dataTask(with: request, completionHandler: {(data, response, error) -> Void in
            if data == nil {
                return
            }
            if (try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary) != nil {
                let json = JSON(data!)
                let result = json.arrayValue
                
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        }).resume()
    }
    

    public func getTokenImage(contractAddress:String, completion: @escaping (UIImage) -> ()) {
        
        let imageURL = self.getTokenImageURL(contractAddress: contractAddress)
        
        var image = UIImage()
        //Check if Image has Cache
        do {
            image = (try storage.object(forKey: imageURL))
        } catch {
            //Create Image and Cache
            do {
                let imgdata = try Data(contentsOf: URL(string: imageURL)!)
                image =  UIImage(data: imgdata)!
                try storage.setObject(image, forKey: imageURL)
                
            } catch {
                image = UIImage(named: "icon_token_erc20.png")!
            }
        }
        

        
        DispatchQueue.main.async {
            completion(image)
        }
    }
    
    public func getERC721Tokens(address:String, tokenAddress:String?, page:String, completion: @escaping ([JSON]?) -> ()){
        
        let urlString = "https://api.opensea.io/api/v1/assets/"
        let parameters = ["owner":address,
                          "order_by": "token_id",
                          "asset_contract_address":tokenAddress,
                          "offset":page,
                          "limit":"20"]
        
       
        let headers = ["X-API-KEY": "1a4288c7a6114fcd85f3d88aa37af0cc"]

        var urlComponents = URLComponents(string: urlString)

        var queryItems = [URLQueryItem]()
        for (key, value) in parameters {
            queryItems.append(URLQueryItem(name: key, value: value))
        }

        urlComponents?.queryItems = queryItems

        var request = URLRequest(url: (urlComponents?.url)!)
        request.httpMethod = "GET"

        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        URLSession.shared.dataTask(with: request, completionHandler: {(data, response, error) -> Void in
            if data == nil {
                return
            }
            if (try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary) != nil {
                let json = JSON(data!)

                let result = json["assets"].arrayValue
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        }).resume()

        return
//
        // Code for Rarebits <3
        var url = URLComponents(string: "https://api.rarebits.io/v1/addresses/"+"0x482bf6B13e31E11f9FdA36e86e3B4Cd313F109CC"+"/token_items")
        
        url?.queryItems = [
            URLQueryItem(name: "api_key", value: "cc0a1c99-069c-4955-9ddd-a2f450aaa0f2"),
            URLQueryItem(name: "page-size", value: "20"),
            URLQueryItem(name: "page", value: page),
        ]
        

        URLSession.shared.dataTask(with: (url?.url as URL?)!, completionHandler: {(data, response, error) -> Void in
            if data == nil {
                return
            }
            if (try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary) != nil {
                let json = JSON(data!)
                print(json["total_entries"].numberValue)
                print()
                let result = json["entries"].arrayValue
                print(result.count)
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        }).resume()
    }
    
    
}




