//
//  EditViewModel.swift
//  five-items
//
//  Created by 酒井ゆうき on 2020/10/18.
//

import Foundation
import UIKit

class AddItemViewModel : ObservableObject {
    
    @Published var name = ""
    @Published var url = ""
    @Published var imageData : Data = .init(count : 0)
    @Published var description = ""
    
    @Published var editItem : Item?
    
    @Published var showPL = true
    @Published var showPicker = false
    
    var isComplete : Bool {
        
        if !selectedImage() || isEmpty(_field: name) {
            return false
        }
        
        return true
    }
    
    var didChangeStatus : Bool {
        
        guard let editItem = editItem else {return false}
        
        if editItem.name != name ||  editItem.description != description  || !(self.imageData == .init(count :0)){
            return true
        }
        
        return false
    }
    
    //MARK: - Validation func
    func selectedImage() -> Bool {
        return !(imageData == .init(count: 0))
    }
    
    var validImageText : String {
        
        if selectedImage() {
            return ""
        } else {
            return "画像を選択してください"
        }
    }
    
    var validNameText : String {
        
        if !isEmpty(_field: name) {
            return ""
        } else {
            return "名前を入力してください"
        }
    }
    
    func velidUrl (urlString: String?) -> Bool {
       if let urlString = urlString {
           if let url = NSURL(string: urlString) {
               return UIApplication.shared.canOpenURL(url as URL)
           }
       }
       return false
   }
    
    
    
}
