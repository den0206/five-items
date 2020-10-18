//
//  Item.swift
//  five-items
//
//  Created by 酒井ゆうき on 2020/10/18.
//

import Foundation

struct Item : Identifiable{
    
    var id = UUID().uuidString
    
    var name : String
    var imageUrl : URL
    var relationUrl : URL?
    var description : String?
    var userId : String
    
}
