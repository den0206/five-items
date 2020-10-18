//
//  ProfileView.swift
//  five-items
//
//  Created by 酒井ゆうき on 2020/10/18.
//

import SwiftUI

struct EditView: View {
    
    @State private var showSheet = false
    @State private var selectedIndex = 1
    
    var body: some View {
        
        NavigationView {
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing : 40) {
                    
                    HStack {
                        AddRecButton(showSheet: $showSheet, selectedIndex: $selectedIndex, index: 1)
                    }
                    
                    HStack(spacing : 40) {
                        AddRecButton(showSheet: $showSheet, selectedIndex: $selectedIndex, index: 2)
                        AddRecButton(showSheet: $showSheet, selectedIndex: $selectedIndex,index: 3)
                    }
                    
                    HStack(spacing : 40) {
                        AddRecButton(showSheet: $showSheet, selectedIndex: $selectedIndex,index: 4)
                        AddRecButton(showSheet: $showSheet, selectedIndex: $selectedIndex,index: 5)
                    }
                    
                }
                .padding(.top,30)
                .frame(maxWidth: .infinity)
               
                
            }
            .navigationBarTitle("アイテム", displayMode: .inline)
            .sheet(isPresented: $showSheet) {
                AddItemView(index: selectedIndex)
            }
        }
    }
}

struct AddRecButton : View {
    
    @Binding var showSheet : Bool
    @Binding var selectedIndex : Int
    
    var index : Int
    
    var body: some View {
        
        Button(action: {
            showSheet = true
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

