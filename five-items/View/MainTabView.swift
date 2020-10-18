//
//  MainTabView.swift
//  five-items
//
//  Created by 酒井ゆうき on 2020/10/18.
//

import SwiftUI

struct MainTabView: View {
    
//    init() {
//        UITabBar.appearance().barTintColor = .gray
//    }
//
    var body: some View {
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
            
            
            
        }
        /// selected Color
        .accentColor(Color.gray)
    }
}

