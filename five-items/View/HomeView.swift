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
    
    @State private var firstLoad = true
    
    var body: some View {
        
        NavigationView {
            VStack {
                
                Text(userInfo.user.name)
                
                
            }
            
            .navigationTitle("Home")
            .navigationBarItems(
                leading :  WebImage(url: userInfo.user.avaterUrl)
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
                    .transition(.fade),
                trailing:
                    Button(action: {FBAuth.logOut { (result) in
                        switch result {
                        
                        case .success(_):
                            self.userInfo.user = FBUser(uid: "", name: "", email: "")
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
                                    print(userInfo.user)
                                case .failure(let error):
                                    print(error.localizedDescription)
                                }
                            }
                           
                        case .failure(let error):
                            print(error.localizedDescription)
                        }
                    }
                
                firstLoad = false
            }
          
          
            
            
        }
       
    }
}

