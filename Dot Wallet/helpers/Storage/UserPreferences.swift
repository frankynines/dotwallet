//
//  UserPreferences.swift
//  Dot Wallet
//
//  Created by Franky Aguilar on 8/22/18.
//  Copyright © 2018 Ninth Industries. All rights reserved.
//

import Foundation
import Cache

class UserPreferenceManager {
    public var coreColor:String?
    
    static let shared = UserPreferenceManager()
    let storageKey:String = EtherWallet.account.address!.lowercased()
    
    func userStorage() -> Storage<String>?{
        do  {
            let storage = try Storage(
                diskConfig: DiskConfig(name: "userPreferences"),
                memoryConfig: MemoryConfig(expiry: .never, countLimit: 10, totalCostLimit: 10),
                transformer: TransformerFactory.forCodable(ofType: String.self))
            return storage
        } catch {
            return nil
        }
        
    }
    
    func setKey(key:String, object:String) {
        let keyName = self.storageKey.appending(key)
        self.coreColor = object
        do {
            try self.userStorage()?.setObject(object, forKey: keyName)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getKeyObject(key:String) throws -> String?{
        let keyName = self.storageKey.appending(key)
        do {
            let object = try self.userStorage()?.object(forKey: keyName)
            self.coreColor = object
            return object!
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }

    
    
}

