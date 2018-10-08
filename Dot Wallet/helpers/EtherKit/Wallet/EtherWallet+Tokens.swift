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
    
    //ERC20
    func getERC20TokenList(url:String, completion: @escaping ([JSON]?) -> ())
    func getTokenMetaData(contractAddress: String, completion: @escaping (ERC20Token) -> ())
    
    //ERC721
    func getERC721Tokens(address:String, tokenAddress:String?, page:String, pageOffset:String, completion: @escaping (JSON?) -> ())
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

        do {
            image = (try storage.object(forKey: imageURL))
        } catch {

            do { // Create Image Cache
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
    
    public func getERC721Tokens(address:String, tokenAddress:String?, page:String, pageOffset:String, completion: @escaping (JSON?) -> ()){
        
        let request = self.openSeaURLRequest(address: address, page: page, pageOffset:pageOffset)

        URLSession.shared.dataTask(with: request, completionHandler: {(data, response, error) -> Void in
            if data == nil {
                return
            }
            if (try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary) != nil {
                
                let json = JSON(data!)
                DispatchQueue.main.async {
                    completion(json)
                }
            }
        }).resume()
    }
    
    internal func openSeaURLRequest(address:String, page:String, pageOffset:String) -> URLRequest{
        
        let urlString = "https://api.opensea.io/api/v1/assets/"
        let parameters = ["owner":address,
                          "order_by": "token_id",
                          "offset":page,
                          "limit":pageOffset
        ]
        
        let headers = ["X-API-KEY": _CONFIG_openSeaAPIKey]
        
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
        
        return request
    }
    
}




