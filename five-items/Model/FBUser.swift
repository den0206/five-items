//
//  FBUser.swift
//  five-items
//
//  Created by 酒井ゆうき on 2020/10/17.
//

import Foundation

struct FBUser {
   
    let uid : String
    var name : String
    var email : String
    var avaterUrl : URL?
    
    var items : [Item?] = Array(repeating: nil, count: 5)
    
    
    init(uid : String, name : String, email : String) {
        self.uid = uid
        self.name = name
        self.email = email
    }
    
    init?(dic : [String : Any]) {
        
        let uid = dic[kUSERID] as? String ?? ""
        let name = dic[kNAME] as? String ?? ""
        let email = dic[kEMAIL] as? String ?? ""
        
        self.init(uid: uid, name: name, email: email)
        
        if let urlString = dic[kPROFILE_IMAGE] as? String  {
            
            self.avaterUrl = URL(string: urlString)
        }
        
       
    }
}
