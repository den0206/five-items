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
    @Published var showLoading = false
    
    func fetchUsers(currentUser : FBUser) {
        FBUserSearvice.fetchUsers(currentUser: currentUser) { (result) in
            
            switch result {
            
            case .success(let users):
                self.users = users
                self.showLoading = false
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    
}
