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
//            WebImage(url: item.imageLinks[0])
//                .resizable()
//                .renderingMode(.original)
//                .ignoresSafeArea(.all, edges: .top)
//
//
            /// Z2
            LinearGradient(gradient: .init(colors: [Color.black.opacity(0),Color.black.opacity(0.8)]), startPoint: .center, endPoint: .top)
            
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
                
                Parallel_ImagesView(item: item)
                
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
        }
        .padding(.vertical)
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

struct Parallel_ImagesView : View {
    
    @State private var current_Index : Int = 0
    @State private var currentDrag : CGFloat = 0
    var objectWidth = UIScreen.main.bounds.width - 90
    var objecgPadding : CGFloat = 10
    var parallelMargintude : CGFloat = 80
    
    var item : Item
    
    var body: some View {
        
        ZStack {
            ForEach(0 ..< self.item.imageLinks.count) { i in
                
                ZStack {
                    WebImage(url: item.imageLinks[i])
                    .resizable()
                    .scaledToFill()
                    .frame(width : self.objectWidth + (2 * parallelMargintude), height : 500)
                    .overlay(Color.black.opacity(self.isCurrentIndex(i: i) ? 0 : 0.3))
                    .offset(x: (CGFloat(i - self.current_Index) * (self.parallelMargintude)) + ((self.currentDrag / ((self.objectWidth + self.objecgPadding))) * self.parallelMargintude))
                    .animation(.easeIn(duration : 0.3))
                }
                .shadow(radius: 3)
                .frame(width: self.objectWidth, height: 500)
                .background(Color.gray)
                .cornerRadius(10)
                .offset(x: (CGFloat(i - self.current_Index) * (self.objectWidth + self.objecgPadding)) + self.currentDrag)
                .animation(.easeInOut(duration: 0.1))
                .gesture(DragGesture().onChanged({ (value) in
                    self.currentDrag = value.translation.width
                }).onEnded({ (value) in
                    if self.currentDrag > self.objectWidth / 2 {
                        if self.current_Index > 0 {
                            self.current_Index = self.current_Index - 1
                        }
                    } else if self.currentDrag < -self.objectWidth / 2 {
                        if self.current_Index < self.item.imageLinks.count - 1 {
                            self.current_Index = self.current_Index + 1
                        }
                    }
                    self.currentDrag = 0
                })
                )
                
            }
        }
    }
    
    func isCurrentIndex(i : Int) -> Bool {
        
        return current_Index == i
    }
}

