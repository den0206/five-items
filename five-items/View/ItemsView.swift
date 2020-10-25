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
    @State private var exampleArray : [Item] = randomItemArray(count: 30)
    
    private var colums = Array(repeating: GridItem(spacing : 12), count: 3)
    
    var body: some View {
        
        ScrollView {
            
            Spacer().frame(width: UIScreen.main.bounds.width, height: 30)
            
            LazyVGrid(columns: colums, spacing: 12) {
                
                ForEach(vm.items) { item in
                    
                    Button(action: {
                        vm.selectedItem = item
                        vm.showDetail = true
                    }) {
                        
                        ItemCell(item: item)
                            .onAppear {
                                if vm.items.last!.id == item.id {
                                    if !vm.reachLast{
                                        vm.fetchMoreItems(userID: userInfo.user.uid, lastDoc: vm.lastDoc)
                                    }
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
            
            vm.fetchItem(userId: userInfo.user.uid)

            
        }
        .alert(isPresented: $vm.showAlert) {
            Alert(title: Text("Error"), message: Text(vm.errorMessage), dismissButton: .default(Text("OK")))
        }
        .fullScreenCover(isPresented: $vm.showDetail, content: {
            
            if let selectedItem = vm.selectedItem  {
                ItemDetailView(item: selectedItem)
            }
        })
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

