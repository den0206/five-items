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
            WebImage(url: item.imageLinks[0])
                .resizable()
                .renderingMode(.original)
                .ignoresSafeArea(.all, edges: .top)
            
            
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
                            .background(BlurView(style: .light).clipShape(Circle()))
                            .padding(.trailing, 10)
                    }
                }
                
                Spacer()
                
                ZStack {
                    BlurView(style: .light)
                    
                    VStack {
                        VStack(alignment: .leading) {
                            
                            HStack {
                                Text(item.name).font(.title)
                                    .foregroundColor(.black)
                                
                                Spacer()
                            }
                            .padding()
                            
                            
                            if item.description != nil{
                                Text(item.description!)
                                    .foregroundColor(.black)
                                    .padding()
                            }
                            
                        }
                        
                    }
                }
                .cornerRadius(8)
                .frame(width: UIScreen.main.bounds.width - 50, height: 200)
            }
            .padding(.bottom,35)
        }
        .navigationBarHidden(true)
        
    }
    
 

}

struct BlurView: UIViewRepresentable {

    let style: UIBlurEffect.Style

    func makeUIView(context: UIViewRepresentableContext<BlurView>) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        let blurEffect = UIBlurEffect(style: style)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(blurView, at: 0)
        NSLayoutConstraint.activate([
            blurView.heightAnchor.constraint(equalTo: view.heightAnchor),
            blurView.widthAnchor.constraint(equalTo: view.widthAnchor),
        ])
        return view
    }

    func updateUIView(_ uiView: UIView,
                      context: UIViewRepresentableContext<BlurView>) {

    }

}



