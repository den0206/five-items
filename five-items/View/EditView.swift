//
//  ProfileView.swift
//  five-items
//
//  Created by 酒井ゆうき on 2020/10/18.
//

import SwiftUI
import SDWebImageSwiftUI


enum EditViewSheet : Identifiable {
    case new, edit
    
    var id : Int {
        hashValue
    }
}

struct EditView: View {
    
    @EnvironmentObject var userInfo : UserInfo

    @State private var selectedIndex = 0
    @State private var sheetType : EditViewSheet?
    
    
    var body: some View {
        
        NavigationView {
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing : 40) {
                    
                    HStack {
                        AddRecButton(selectedIndex: $selectedIndex, sheetType: $sheetType, index: 0)
                    }
                    
                    HStack(spacing : 40) {
                        AddRecButton(selectedIndex: $selectedIndex, sheetType: $sheetType, index: 1)
                        AddRecButton( selectedIndex: $selectedIndex,sheetType: $sheetType, index: 2)
                    }
                    
                    HStack(spacing : 40) {
                        AddRecButton(selectedIndex: $selectedIndex,sheetType: $sheetType, index: 3)
                        AddRecButton(selectedIndex: $selectedIndex,sheetType: $sheetType, index: 4)
                    }
                    
                }
                .padding(.top,30)
                .frame(maxWidth: .infinity)
               
                
            }
//            .background(Image("wood").resizable().scaledToFill())
            .navigationBarTitle("アイテム", displayMode: .inline)
            .sheet(item: $sheetType) { (item) in
                
                switch item {
                case .new :
                    AddItemView(index: $selectedIndex)
                case .edit :
                    
                    if let item = userInfo.user.items[selectedIndex] {
                        
                        EditItemView(item: item)
                    } else {
                        Text("No Item \(selectedIndex)")
                    }
                    
                }
            }
        }
       
        
    }
}

struct AddRecButton : View {
    
    @EnvironmentObject var userInfo : UserInfo
    
    @Binding var selectedIndex : Int
    @Binding var sheetType : EditViewSheet?
    
    var index : Int
    
    var item : Item? {
        return userInfo.user.items[index]
    }
    
    var body: some View {
        
        if item != nil {
            /// exists
            
            Button(action: {
                self.sheetType = .edit

                selectedIndex = index
                print(selectedIndex)
            }) {
                
                WebImage(url: item!.imageUrl)
                    .resizable()
                    .placeholder {
                        Rectangle()
                            .fill(Color(white: 0.95))
                            .frame(width: 90, height: 90)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                            .overlay(ProgressView()
                            .foregroundColor(.white))
                    }
                    .frame(width: 90, height: 90)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                   
            }
            
        } else {
            Button(action: {
                self.sheetType = .new
                
                selectedIndex = index
            }) {
                Rectangle()
                    .fill(Color(white: 0.95))
                    .frame(width: 90, height: 90)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .overlay(
                        Image(systemName: "plus")
                            .foregroundColor(.gray)
                            .frame(width: 30, height: 30)
                    )
            }
        }
        
      
        
    }
    
}

