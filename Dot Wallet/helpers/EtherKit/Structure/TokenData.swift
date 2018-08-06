//
//  TokenData.swift
//  Dot Wallet
//
//  Created by Franky Aguilar on 7/28/18.
//  Copyright © 2018 Ninth Industries. All rights reserved.
//

struct OErc721Token: Decodable {
    let token_id:String?
    let image_url:String?
    let image_preview_url:String?
    let name:String?
    let description:String?
    let external_link:String?
    let asset_contract:ERC721Contract?
    
    enum CodingKeys: String, CodingKey {
        
        case token_id
        case image_url
        case image_preview_url
        case name
        case description
        case external_link
        case asset_contract
        
    }
}

struct ERC721Contract:Decodable {
    
    let address:String?
    let name:String?
    let symbol:String?
    let image_url:String?
    let featured_image_url:String?
    let description:String?
    let external_link:String?
    
    enum CodingKeys: String, CodingKey {
        case address
        case name
        case symbol
        case image_url
        case featured_image_url
        case description
        case external_link
    }
    
}
public struct ERC20Token:Codable {
    let name:String?
    let symbol:String?
    let contractAddress:String?
    let decimal:String?
    let imageURL:String?
    let balance:String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case symbol
        case contractAddress
        case decimal
        case imageURL
        case balance
    }
}

struct OERC20Token: Codable {
    let decimals:Int?
    let ens_address:String?
    let name: String?
    let website:String?
    let address:String?
    let symbol:String?
    
    enum CodingKeys:String, CodingKey {
        case decimals
        case ens_address
        case name
        case website
        case address
        case symbol
    }
}


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
