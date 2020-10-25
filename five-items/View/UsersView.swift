//
//  UsersView.swift
//  five-items
//
//  Created by 酒井ゆうき on 2020/10/21.
//

import SwiftUI
import SDWebImageSwiftUI

struct UsersView: View {
    
    @EnvironmentObject var userInfo : UserInfo
    @StateObject var vm = UsersViewModel()
    
    @State private var firstLoad = true

    
    var body: some View {
        
        NavigationView {
            
            VStack {
                /// searchVIew (not work right now)
                SearchView(isSearchng: $vm.isSearchng, searchText: $vm.searchText)
                   
                
                Divider()
                
                ScrollView {
                    
                    ForEach(vm.users.indices, id : \.self) { i in
                        
                        NavigationLink(destination: UserProfileView(user: vm.users[i])) {
                            UserCell(user: $vm.users[i])
                                .padding(4)
                                .onAppear {
                                    if vm.users.last!.uid == vm.users[i].uid {
                                        vm.fetchMoreUsers(currentUser: userInfo.user)
                                    }
                                }
                        }
                        
                    }
                }
                
                
                Spacer()

            }
            .padding(.vertical,8)
            .navigationBarTitle("Users", displayMode: .inline)
            .navigationViewStyle(StackNavigationViewStyle())
            
            
        
        }
        .onAppear {
            if firstLoad {
                print("Call")
                vm.showLoading = true
                vm.fetchUsers(currentUser: userInfo.user)
                firstLoad = false
            }
        }
        .loading(isShowing: $vm.showLoading)
 
    }
}

//MARK: - UserCell

struct UserCell : View {
    
    @Binding var user : FBUser
    
    var body: some View {
        
        VStack {
            
            HStack {
                
                if user.items.isEmpty{
                    Rectangle()
                        .fill(Color(white: 0.95))
                        .frame(width: 60, height: 60)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .overlay(
                            Text("No Items")
                                .font(.caption2)
                                .foregroundColor(.black)
                        )
                    
                } else {
                    ForEach(user.items.compactMap({$0})) { item in
                        
                        WebImage(url: item.imageUrl)
                            .resizable()
                            .placeholder {
                                Rectangle()
                                    .fill(Color(white: 0.95))
                                    .overlay(
                                        ProgressView()
                                            .foregroundColor(.black)
                                    )
                                
                            }
                            .frame(width: 45, height: 45)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                        
                    }
                    
                }
                
                Spacer()
                
                VStack(spacing : 5) {
                    
                    WebImage(url: user.avaterUrl)
                        .resizable()
                        .placeholder{
                            Circle()
                                .fill(Color.gray)
                                .overlay(ProgressView()
                                            .foregroundColor(.white))
                            
                        }
                        .frame(width: 55, height: 55)
                        .clipShape(Circle())
//                        .animation(.easeInOut(duration: 0.5))
//                        .transition(.fade)
                    
                    
                    Text(user.name).font(.caption2)
                        .foregroundColor(.black)
                }
                .padding(.trailing,5)
               
               
            }
            .onAppear {
                
                FBItem.fetchUserItems(user: user) { (result) in
                    
                    switch result {
                    
                    case .success(let items):
                        user.items = items
                    case .failure(let error):
                        if error as! FirestoreError != FirestoreError.emptySnapshot {
                            print(error.localizedDescription)
                        }
                        user.items = [Item?]()
                    }
                }
            }
            
            Divider()
        }
     
        
      
    }
}


//MARK: - SearchView



struct SearchView : View {
    
    @Binding var isSearchng : Bool
    @Binding var searchText : String
    
    var body: some View {
        
        HStack {
            /// search field
            HStack {
                TextField("Search Users", text: $searchText)
                    .padding(.leading,24)
                    .onTapGesture {
                        self.isSearchng = true
                    }
            }
            .padding()
            .background(Color(.systemGray3))
            .cornerRadius(12)
            .padding(.horizontal)
            .overlay(
                HStack {
                    Image(systemName: "magnifyingglass")
                        Spacer()
                    if isSearchng {
                        Button(action: {self.searchText = ""}) {
                            Image(systemName: "xmark.circle.fill")
                                .padding(.vertical)
                        }
                    }
                }
                .padding(.horizontal,32)
                .foregroundColor(.gray)
            )
            .transition(.move(edge: .trailing))
            .animation(.spring())
            
            if isSearchng {
                Button(action: {
                    isSearchng = false
                    searchText = ""
                    
                    hideKeyBord()
                }) {
                    Text("Cancel")
                }
                .padding(.trailing,24)
                .padding(.leading,0)
                .transition(.move(edge: .trailing))
                .animation(.spring())
            }
        }
    }
}
