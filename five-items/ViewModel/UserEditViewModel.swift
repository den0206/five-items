//
//  UserEditViewModel.swift
//  five-items
//
//  Created by 酒井ゆうき on 2020/10/25.
//

import Foundation

class UserEditViewModel : ObservableObject {
    
    @Published var user = UserViewModel()
    @Published var showPicker = false
    
    @Published var loading = false
    @Published var errorMessage = ""
    @Published var showAlert = false
}
