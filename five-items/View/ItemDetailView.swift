//
//  ItemDetailView.swift
//  five-items
//
//  Created by 酒井ゆうき on 2020/10/24.
//

import SwiftUI
import SDWebImageSwiftUI

struct ItemDetailView: View {
    
    var item : Item
    @Environment(\.presentationMode) var presentationMode

    
    var body: some View {
        
        ZStack {
            
            /// backgorund(Z1)
            WebImage(url: item.imageUrl)
                .resizable()
                .ignoresSafeArea(.all, edges: .top)
                .aspectRatio(contentMode: .fill)
            
            
            /// Z2
            LinearGradient(gradient: .init(colors: [Color.black.opacity(0),Color.black.opacity(0.8)]), startPoint: .center, endPoint: .bottom)
            
            /// Z3
            VStack {

                HStack {

                    Spacer()

                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark.circle")
                            .foregroundColor(.white)
                            .font(.system(size: 33))
                            .padding(.trailing, 10)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    
                    
                    Text(item.name).font(.title)
                        .foregroundColor(.white)
                    
                    if item.description != nil{
                        Text(item.description!)
                            .foregroundColor(.white)
                    }
                    
                }
                
            }
            
        }
       
    }
}


