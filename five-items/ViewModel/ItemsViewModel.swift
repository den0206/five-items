//
//  ItemsViewModel.swift
//  five-items
//
//  Created by 酒井ゆうき on 2020/10/21.
//

import Foundation
import FirebaseFirestore

final class ItemsViewModel : ObservableObject {
    
    @Published var items = [Item]()
    
    @Published var errorMessage = ""
    @Published var showAlert = false
    @Published var lastDoc : DocumentSnapshot?
    var finelDoc : DocumentSnapshot?
    
    @Published var reachLast = false
    
    func fetchItem(userId : String) {
        
        guard !reachLast else {return}
        
        FBItem.fetchAllitems(userId: userId) { (result) in
            
            switch result {
            
            case .success((let items, let lastDoc)):
                
                if items.count != 12 {
                    self.reachLast = true
                }
                self.items = items
                self.lastDoc = lastDoc
                
            case .failure(let error):
                print(error.localizedDescription)
                
                if error as? FirestoreError != FirestoreError.emptySnapshot {
                    print(error.localizedDescription)
                    self.errorMessage = error.localizedDescription
                } else {
                    self.reachLast = true
                    print("Reach last")
                    return
                }
               
                self.showAlert = true
            }
        }
    }
    
    func fetchMoreItems(userID : String, lastDoc : DocumentSnapshot?) {
        
        guard !reachLast else {return}
        FBItem.fetchAllitems(userId: userID, lastDoc: lastDoc) { (result) in
            switch result {
            
            case .success((let moreItems, let lastDoc)):
                if moreItems.count != 12 {

                    self.reachLast = true
                }
                self.items.append(contentsOf: moreItems)
                print(self.items.count)
                self.lastDoc = lastDoc
                
            case .failure(let error):
                print(error.localizedDescription)
                
                if error as? FirestoreError != FirestoreError.emptySnapshot {
                    self.errorMessage = error.localizedDescription
                } else {
                    self.reachLast = true
                    return
                }
               
                self.showAlert = true
            }
        }
    }
    
    func isLastItem(item : Item) -> Bool {
        if let last = self.items.last {
            return last == item
        }
        return false
    }
}
