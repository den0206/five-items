//
//  HomeView.swift
//  five-items
//
//  Created by 酒井ゆうき on 2020/10/17.
//

import SwiftUI
import Firebase
import SDWebImageSwiftUI

//MARK: - Set UserInfo this View

struct HomeView: View {
    
    @EnvironmentObject var userInfo : UserInfo
    @State private var showSheet = false
    
    var body: some View {
        
        NavigationView {
          
            ItemsView()
                .navigationBarTitle("アイテム", displayMode: .inline)
                .navigationBarItems(
                    leading :
                        
                        Button(action: {self.showSheet = true}, label: {
                            WebImage(url: userInfo.user.avaterUrl)
                            .resizable()
                            .placeholder{
                                Circle()
                                    .fill(Color.gray)
                                    .overlay(ProgressView()
                                                .foregroundColor(.white))
                            }
                            .frame(width: 30, height: 30)
                            .clipShape(Circle())
                            .animation(.easeInOut(duration: 0.5))
                            .transition(.fade)
                        })
                        .sheet(isPresented: $showSheet, content: {
                            UserEditView()
                        })
                       ,
                    trailing:
                        Button(action: {FBAuth.logOut { (result) in
                            switch result {
                            
                            case .success(_):
                                self.userInfo.user = FBUser(uid: "", name: "", email: "")
                                self.userInfo.setCurrentUser = false
                                self.userInfo.isUserAuthenticated = .signedOut
                            case .failure(let error):
                                print(error.localizedDescription)
                            }
                        }}) {
                            Text("Log Out")
                                .foregroundColor(.red)
                        }
                    
                )

        }
        
    }
    
}


