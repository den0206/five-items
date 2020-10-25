//
//  UsersViewModel.swift
//  five-items
//
//  Created by 酒井ゆうき on 2020/10/21.
//

import Foundation
import FirebaseFirestore



class UsersViewModel : ObservableObject{
    
    @Published var users = [FBUser]()
    
    @Published var lastDoc : DocumentSnapshot?
    @Published var reachLast = false
 
    
    @Published var isSearchng = false
    @Published var searchText = ""
    @Published var showLoading = false
    @Published var showAlert = false
    @Published var errorMessage = ""
    
    
    func fetchUsers(currentUser : FBUser) {
        
        guard !reachLast else {return}
        
        self.showLoading = true
        
        FBUserSearvice.fetchUsers(currentUser: currentUser) { (result) in
            
            switch result {
            
            case .success((let users, let lastDoc, let reachLast)):
                
                self.reachLast = reachLast
                print(reachLast)

                self.users = users
                self.showLoading = false
                self.lastDoc = lastDoc
                
            case .failure(let error):
                
                print(error.localizedDescription)
                
                if error as? FirestoreError != FirestoreError.emptySnapshot {
                    print(error.localizedDescription)
                    self.errorMessage = error.localizedDescription
                } else {
                    /// empty error
                    self.reachLast = true
                    print("Reach last")
                    return
                }
               
                self.showAlert = true
            }
        }
    }
    
    func fetchMoreUsers(currentUser : FBUser) {
                
        guard !reachLast && !showLoading else {return}
        
        showLoading = true
        print("More")
        
        FBUserSearvice.fetchUsers(currentUser: currentUser, lastDoc: lastDoc) { (result) in
            
            switch result {
            
            case .success((let moreUsers, let lastDoc, let reachLast )):
                
                self.reachLast = reachLast

                self.users.append(contentsOf: moreUsers)
                self.showLoading = false
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
    
    func isLastUser(user : FBUser) -> Bool {
        if let last = self.users.last {
            return last.uid == user.uid
        }
        return false
    }
    
}
