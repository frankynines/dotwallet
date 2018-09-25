//
//  DotAPI.swift
//  Dot Wallet
//
//  Created by Franky Aguilar on 9/25/18.
//  Copyright © 2018 Ninth Industries. All rights reserved.
//

import Firebase
public class DotAPI {
    
    public static let shared = DotAPI()
    public static let users: DotAPIUserService = DotAPI.shared
    public var userID:String!
    
    private init() { }
    
}

//USER API SERVICE
public protocol DotAPIUserService {
    
    func updateUserValue(userID:String, key:String, value:String)
}

extension DotAPI: DotAPIUserService {
    
    public func updateUserValue(userID:String, key:String, value:String){
       
        let userValueWithKey = [key: value]
        var ref: DatabaseReference!
        
        ref = Database.database().reference()
        let key = ref.child("users").child(userID)
        key.updateChildValues(userValueWithKey as [String : Any]) { (error, reference) in
            if error != nil {
                print(error?.localizedDescription ?? String.self)
            }
        }
        
    }
}
