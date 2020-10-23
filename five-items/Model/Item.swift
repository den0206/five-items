//
//  Item.swift
//  five-items
//
//  Created by 酒井ゆうき on 2020/10/18.
//

import Foundation

struct Item : Identifiable, Equatable{
    
    var id : String
    
    var name : String
    var imageUrl : URL
    var relationUrl : URL?
    var description : String?
    var userId : String
    
    var index : Int
    
    init(id : String, name : String, imageUrl : URL,userId : String, index : Int) {
        
        self.id = id
        self.name = name
        self.imageUrl = imageUrl
        self.userId = userId
        self.index = index
    }
    
    init?(dic : [String : Any]) {
        let id = dic[kITEMID] as? String ?? ""
        let name = dic[kITEMNAME] as? String ?? ""
        let userId = dic[kUSERID] as? String ?? ""
        let index = dic[kINDEX] as? Int ?? 0
        
        guard let imageUrl = URL(string: dic[kIMAGELINK] as! String ) else { return nil }
        
        self.init(id: id, name: name, imageUrl: imageUrl, userId: userId, index : index)
        
        if let relationUrl = dic[kRELATIONURL] as? String  {
            
            self.relationUrl = URL(string: relationUrl)
        }
         
        if let description = dic[kDESCRIPTION] as? String {
            self.description = description
        }
        
    }
}
