//
//  TokenStorage.swift
//  Dot Wallet
//
//  Created by Franky Aguilar on 8/7/18.
//  Copyright © 2018 Ninth Industries. All rights reserved.
//

import Foundation
import Cache

class TokenCacheManager {
    
    static let shared = TokenCacheManager()
    let storageKey = EtherWallet.account.address?.lowercased()
        
    func userStorage() -> Storage<[String? :OERC20Token?]>? {
        do  {
            let storage = try Storage(
                diskConfig: DiskConfig(name: "userERC20"),
                memoryConfig: MemoryConfig(expiry: .never, countLimit: 10, totalCostLimit: 10),
                transformer: TransformerFactory.forCodable(ofType: [String? : OERC20Token?].self))
            return storage
        } catch {
            return nil
        }
       
    }
    
    func loadCachedTokens() -> [OERC20Token]{
        var tokens = [OERC20Token]()
        do {
            
            let cachedArray = try userStorage()!.object(forKey:storageKey!)
            for token in cachedArray {
                tokens.append(token.value!)
            }
            return tokens
        } catch {
            print(error.localizedDescription)
            return []
        }
    }
    
    func removeTokenToCache(tokenAddress:String){
        do {
            var _cachedTokens = try userStorage()?.object(forKey:storageKey!)
            _cachedTokens?.removeValue(forKey: (tokenAddress.lowercased()))
            try userStorage()?.setObject(_cachedTokens!, forKey:storageKey!)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func saveTokenToCache(token:OERC20Token){
        
        do {
            var _cachedTokens = try userStorage()!.object(forKey:storageKey!)
            _cachedTokens.updateValue(token, forKey: (token.address?.lowercased())!)
            try userStorage()!.setObject(_cachedTokens, forKey:storageKey!)
        } catch {
            print(error.localizedDescription)
            do {
                try userStorage()!.setObject([token.address! : token], forKey:storageKey!)
            } catch {
                print(error.localizedDescription)
            }
            
        }
        
    }

    //KILL
    func killStorage(){
         try? self.userStorage()?.removeAll()
    }
    
}
