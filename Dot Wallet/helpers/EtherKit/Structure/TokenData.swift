//
//  TokenData.swift
//  Dot Wallet
//
//  Created by Franky Aguilar on 7/28/18.
//  Copyright © 2018 Ninth Industries. All rights reserved.
//

struct Erc721Token: Decodable {
    let id:Int?
    let token_id:String?
    let token_contract_address:String?
    let token_owner_address:String?
    let name:String?
    let description:String?
    let url:String?
    let image_url:String?
    let home_url:String?
    let color:String?
    let tags:Array<String>?
    let token_created_timestamp:Int?
    let last_sold_timestamp:Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case token_id
        case token_contract_address
        case token_owner_address
        case name
        case description
        case url
        case image_url
        case home_url
        case color
        case tags
        case token_created_timestamp
        case last_sold_timestamp
    }
}
