//
//  RootView.swift
//  five-items
//
//  Created by 酒井ゆうき on 2020/10/17.
//

import SwiftUI

struct RootView: View {
    
    @EnvironmentObject var userInfo : UserInfo

    var body: some View {
        
        Group {
            if userInfo.isUserAuthenticated == .undefined {
                ProgressView("Loading...")
                    .foregroundColor(.gray)
            }  else if userInfo.isUserAuthenticated == .signedOut {
                LoginView()
            } else {
                MainTabView()
            }
        }
        .onAppear{
            userInfo.configureStateDidchange()
        }
    }
}

