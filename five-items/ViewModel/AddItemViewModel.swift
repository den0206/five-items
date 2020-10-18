//
//  EditViewModel.swift
//  five-items
//
//  Created by 酒井ゆうき on 2020/10/18.
//

import Foundation

class AddItemViewModel : ObservableObject {
    
    @Published var name = ""
    @Published var url = ""
    @Published var imageData : Data = .init(count : 0)
    @Published var description = ""
    
    @Published var showPL = true
    @Published var showPicker = false
    
    var isComplete : Bool {
        
        if !selectedImage() || isEmpty(_field: name) {
            return false
        }
        
        return true
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
    
    
    
}
