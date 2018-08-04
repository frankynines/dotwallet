//
//  TokenListDelegate.swift
//  Dot Wallet
//
//  Created by Franky Aguilar on 8/4/18.
//  Copyright © 2018 Ninth Industries. All rights reserved.
//

import Foundation

protocol TokenDelegate {
    func tokenDidSelectERC721(token:OErc721Token)
    func tokenDidSelectERC20(token:ERC20Token)
}
