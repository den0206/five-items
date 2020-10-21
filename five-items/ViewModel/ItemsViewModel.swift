//
//  ItemsViewModel.swift
//  five-items
//
//  Created by 酒井ゆうき on 2020/10/21.
//

import Foundation

final class ItemsViewModel : ObservableObject {
    
    @Published var items = [Item]()
    
    @Published var errorMessage = ""
    @Published var showAlert = false
    
    func fetchItem(userId : String) {
        
        FBItem.fetchAllitems(userId: userId) { (result) in
            
            switch result {
            
            case .success(let items):
                self.items = items
            case .failure(let error):
                print(error.localizedDescription)
                self.errorMessage = error.localizedDescription
                self.showAlert = true
            }
        }
    }
}
