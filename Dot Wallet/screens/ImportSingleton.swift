//
//  ImportSingleton.swift
//  Dot Wallet
//
//  Created by Franky Aguilar on 8/7/18.
//  Copyright © 2018 Ninth Industries. All rights reserved.
//

import Foundation

class WalletManagerShared {

    static let shared = WalletManagerShared(isLiveNet: false)
    
    var isLive: Bool

    private init(isLiveNet: Bool) {
        self.isLive = isLiveNet
    }

    
}
