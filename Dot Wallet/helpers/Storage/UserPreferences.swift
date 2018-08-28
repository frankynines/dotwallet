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
    
    
    func setKey(key:String, object:String) {
        let keyName = self.storageKey.appending(key)
        UserDefaults.standard.set(object, forKey: keyName)
    }
    
    func getKeyObject(key:String) -> String?{
        let keyName = self.storageKey.appending(key)
        if let color = UserDefaults.standard.object(forKey: keyName) as? String {
            return color
        } else {
            return nil
        }
        
    }

    
    
}

