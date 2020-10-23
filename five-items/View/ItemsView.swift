//
//  ItemsView.swift
//  five-items
//
//  Created by 酒井ゆうき on 2020/10/21.
//

import SwiftUI
import SDWebImageSwiftUI

struct ItemsView: View {
    
    @EnvironmentObject var userInfo : UserInfo
    
    @StateObject var vm = ItemsViewModel()
    
    private var colums = Array(repeating: GridItem(spacing : 12), count: 3)
    
    var body: some View {
        
        ScrollView {
            
            Spacer().frame(width: UIScreen.main.bounds.width, height: 20)
            
            LazyVGrid(columns: colums, spacing: 12) {
                
                ForEach(vm.items, id : \.id) { item in
                    
                    Button(action: {print(item.id)}) {
                        
                        ItemCell(item: item)
                            .onAppear {
                                
                                if vm.isLastItem(item: item) {
                                    vm.fetchMoreItems(userID: userInfo.user.uid, lastDoc: vm.lastDoc)
                                }
                            }
                    }
                    .transition(.move(edge: .leading))
                    .animation(.spring())
                   
                }
                
            }
            .padding(.horizontal, 6)
            
        }
        .onAppear {
            
//            guard vm.finelDoc != nil else {return}
//            print(vm.finelDoc)
            vm.fetchItem(userId: userInfo.user.uid)
            
            
            
        }
        .alert(isPresented: $vm.showAlert) {
            Alert(title: Text("Error"), message: Text(vm.errorMessage), dismissButton: .default(Text("OK")))
        }
    }
}

struct ItemCell : View {
    
    var item : Item
    
    var body: some View {
        VStack {
            
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
                .frame(width: 100, height: 100)
                .scaledToFill()
                .cornerRadius(10)
                .shadow(radius: 5)
            
        }
    }
}

