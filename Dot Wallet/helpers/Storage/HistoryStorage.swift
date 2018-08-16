//
//  HistoryStorage.swift
//  Dot Wallet
//
//  Created by Franky Aguilar on 8/16/18.
//  Copyright © 2018 Ninth Industries. All rights reserved.
//

import Foundation
import Cache

class TXHistoryCacheManager {
    
    static let shared = TXHistoryCacheManager()
    let storageKey:String = EtherWallet.account.address!.lowercased()
    
    func userStorage() -> Storage<[GeneralTransactionData?]>? {
        do  {
            let storage = try Storage(
                diskConfig: DiskConfig(name: "userTXHistory"),
                memoryConfig: MemoryConfig(expiry: .never, countLimit: 10, totalCostLimit: 10),
                transformer: TransformerFactory.forCodable(ofType: [ GeneralTransactionData?].self))
            return storage
        } catch {
            return nil
        }
        
    }
    
    func getTXHistory(completion: @escaping ([GeneralTransactionData]) -> ()){
        
        var tx = [GeneralTransactionData]()

        do {
            let storage = try self.userStorage()?.object(forKey: self.storageKey)
            tx = storage as! [GeneralTransactionData]
            completion(tx)
        } catch {
            print(error.localizedDescription)
        }
        
        if tx.isEmpty {
            self.loadTXHistory { (result) in
                tx = result
                completion(tx)
            }
        }
       
    }
    
    func loadTXHistory(completion: @escaping ([GeneralTransactionData]) -> ()) {
        self.requestHistory { (result) in
            
            self.saveTXHistoryCache(transactions: result!)
            DispatchQueue.main.async {
                completion(result!)
            }
        }
        
    }
    
    private func saveTXHistoryCache(transactions:[GeneralTransactionData]){
        do {
            try self.userStorage()?.setObject(transactions, forKey: self.storageKey)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func requestHistory(completion: @escaping ([GeneralTransactionData]?) -> ()) {
        
        var _transactions = [GeneralTransactionData]()
        
        EtherWallet.transaction.getTransactionHistory(address: self.storageKey) { (jsonResult) in
            //PARSE JSON REQUEST
            for tx in jsonResult! {
                let generalTransaction = tx.rawString()
                
                if let transaction = self.buildTransactionItem(transaction: generalTransaction!) {
                    _transactions.append(transaction)
                }
            }
            DispatchQueue.main.async {
                completion(_transactions)
            }
        }
    }
    
    //Function parses response into Codable GTXData object
    private func buildTransactionItem(transaction:String) -> GeneralTransactionData? {
        let data = transaction.data(using: .utf8)!
        do {
            let generalTransaction = try JSONDecoder().decode(GeneralTransactionData.self, from: data)
            return generalTransaction
        } catch {
            print("Failed to Build Transaction Item")
            return nil
        }
    }
    
    //KILL
    func killStorage(){
         try? self.userStorage()?.removeAll()
    }
    
    
}
