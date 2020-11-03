//
//  UserProfileView.swift
//  five-items
//
//  Created by 酒井ゆうき on 2020/10/24.
//

import SwiftUI
import SDWebImageSwiftUI

struct UserProfileView: View {
    
    var user : FBUser
    
    var body: some View {
        
        VStack {
          
            WebImage(url: user.avaterUrl)
                .resizable()
                .placeholder{
                    Circle()
                        .fill(Color.gray)
                        .overlay(ProgressView()
                                    .foregroundColor(.white))
     
                }
                .frame(width: 150, height: 150)
                .clipShape(Circle())
                .animation(.easeInOut(duration: 0.5))
                .transition(.fade)
                .padding(.vertical,30)
        
            
            HStack {
                if user.items.isEmpty {
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
                        
                        NavigationLink(destination: ItemDetailView(item: item)) {
                            WebImage(url: item.imageLinks[0])
                                .resizable()
                                .placeholder {
                                    Rectangle()
                                        .fill(Color(white: 0.95))
                                        .overlay(
                                            ProgressView()
                                                .foregroundColor(.black)
                                        )
                                    
                                    
                                }
                                .frame(width: 60, height: 60)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                            
                        }
                        
                    }
                    
                    
                }
            }
            .padding(.bottom,30)
         
            Divider()
            
            Text(user.name)
                .font(.title)
            
            Spacer()
        }
    }
}


