//
//  MainTabView.swift
//  five-items
//
//  Created by 酒井ゆうき on 2020/10/18.
//

import SwiftUI
import Firebase


struct MainTabView: View {
    
    //    init() {
    //        UITabBar.appearance().barTintColor = .gray
    //    }
    //
    
    @EnvironmentObject var userInfo : UserInfo
    @State private var loading = true
    @State private var firstLoad = true
    
    
    var body: some View {
        
        if loading {
            
            ProgressView("Loading...")
                .onAppear {
                    
                    if firstLoad {
                        guard let uid = Auth.auth().currentUser?.uid else {return}
                        
                        FBAuth.fecthFBUser(uid: uid) { (result) in
                            switch result {
                            
                            case .success(let user):
                                self.userInfo.user = user
                                
                                FBItem.fetchUserItems(user: user) { (result) in
                                    
                                    switch result {
                                    
                                    case .success(let items):
                                        
                                        self.userInfo.user.items = items
                                        loading = false
                                        print(userInfo.user)
                                    case .failure(let error):
                                        print(error.localizedDescription)
                                        self.userInfo.user.items = Array(repeating: nil, count: 5)
                                        loading = false
                                        
                                       
                                    }
                                }
                                
                            case .failure(let error):
                                print(error.localizedDescription)
                            }
                        }
                        
                        firstLoad = false
                    }
                }
            
        } else {
            TabView {
                
                HomeView()
                    .tabItem {
                        Image(systemName: "house")
                        Text("Home")
                    }
                
                EditView()
                    .tabItem {
                        Image(systemName: "person.circle")
                        Text("Profile")
                    }
                
                UsersView()
                    .tabItem {
                        Image(systemName: "person.3")
                        Text("Users")
                    }
                
                
                
            }
            /// selected Color
            .accentColor(Color.gray)
        }
        
        
        
    }
}

