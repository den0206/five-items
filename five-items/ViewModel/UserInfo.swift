//
//  UserInfo.swift
//  five-items
//
//  Created by 酒井ゆうき on 2020/10/17.
//

import Foundation
import FirebaseAuth

final class UserInfo : ObservableObject {

    enum AuthState {
        case undefined,signedOut, signIn
    }
    
    @Published var isUserAuthenticated : AuthState = .undefined
    @Published var user : FBUser = .init(uid : "", name : "", email : "")
    
    @Published var setCurrentUser = false
    
    var listnerHandle : AuthStateDidChangeListenerHandle?
    
    func configureStateDidchange() {
        
        listnerHandle = Auth.auth().addStateDidChangeListener({ (_, user) in
            
            guard let user = user else {
                self.isUserAuthenticated = .signedOut
                return
            }
            
            self.isUserAuthenticated = .signIn
        })
    }
    
    
}
