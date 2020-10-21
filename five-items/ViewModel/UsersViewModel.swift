//
//  UsersViewModel.swift
//  five-items
//
//  Created by 酒井ゆうき on 2020/10/21.
//

import Foundation


class UsersViewModel : ObservableObject{
    
    @Published var users = [FBUser]()
    
    @Published var isSearchng = false
    @Published var searchText = ""
    
    func fetchUsers(currentUser : FBUser) {
        FBUserSearvice.fetchUsers(currentUser: currentUser) { (result) in
            
            switch result {
            
            case .success(let users):
                self.users = users
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    
}
