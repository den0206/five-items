//
//  MainTabView.swift
//  five-items
//
//  Created by 酒井ゆうき on 2020/10/18.
//

import SwiftUI
import Firebase


struct MainTabView: View {
    
    @EnvironmentObject var userInfo : UserInfo
    @State private var loading = true
//    @State private var firstLoad = true
    
    
    var body: some View {
        
        if loading {
            
            ProgressView("Loading...")
                
                .onAppear {
                    
                    if !userInfo.setCurrentUser {
                        guard let uid = Auth.auth().currentUser?.uid else {return}
                        
                        FBAuth.fecthFBUser(uid: uid) { (result) in
                            switch result {
                            
                            case .success(let user):
                                self.userInfo.user = user
                                
                                FBItem.fetchUserItems(user: user) { (result) in
                                    
                                    switch result {
                                    
                                    case .success(let items):
                                        
                                        self.userInfo.user.items = items
                                        loading = false
                                        print(userInfo.user)
                                    case .failure(let error):
                                        print(error.localizedDescription)
                                        self.userInfo.user.items = Array(repeating: nil, count: 5)
                                        loading = false
                                        
                                       
                                    }
                                }
                                
                            case .failure(let error):
                                print(error.localizedDescription)
                            }
                        }
                        
                        userInfo.setCurrentUser = true
                    }
                }
               
            
        } else {
            
            CustomTabView()
//            PlaneTabView()
        }
     
    }
}

//MARK: - custom TabView

var tabItems = ["Home", "Profile","Users"]

struct CustomTabView  : View{
    
    @State private var selected = "Home"
    @State var centerX : CGFloat = 0
    
    @Environment(\.verticalSizeClass) var size

    init() {
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        
        VStack(spacing : 0) {
            
            TabView(selection: $selected) {
                
                HomeView()
                    .tag(tabItems[0])
                    .ignoresSafeArea(.all, edges: .top)
                
                EditView()
                    .tag(tabItems[1])
                    .ignoresSafeArea(.all, edges: .top)
                
                UsersView()
                    .tag(tabItems[2])
                    .ignoresSafeArea(.all, edges: .top)
            }
            
            HStack(spacing : 0) {
                ForEach(tabItems, id : \.self) { value in
                    
                    GeometryReader{ reader in
                        
                        CustomTabBarButton(selected: $selected, value: value, centerX: $centerX, rect: reader.frame(in: .global))
                            .onAppear {
                                if value == tabItems.first {
                                    centerX = reader.frame(in: .global).midX
                                }
                            }
                            // For Landscape Mode....
                            .onChange(of: size) { (_) in
                                if selected == value{
                                    centerX = reader.frame(in: .global).midX
                                }
                            }
               
                    }
                    .frame(width : 70, height : 50)
                    
                    if value != tabItems.last {Spacer(minLength: 0)}
                }
            }
            .padding(.horizontal,25)
            .padding(.top)
            .padding(.bottom,UIApplication.shared.windows.first?.safeAreaInsets.bottom == 0 ? 15 : UIApplication.shared.windows.first?.safeAreaInsets.bottom)
            .background(Color.white.clipShape(CustomTabShape(centerX: centerX)))
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: -5)
            .padding(.top,-15)
            .ignoresSafeArea(.all, edges: .horizontal)
            
        }
        .ignoresSafeArea(.all, edges: .bottom)
    }
}

struct  CustomTabBarButton : View {
    
    @Binding var selected : String
    var value : String
    @Binding var centerX : CGFloat
    var rect : CGRect
    
    var tabImage :  Image {
        switch value {
        case "Home" :
            return Image(systemName: "house")
        case "Profile" :
            return Image(systemName: "person.circle")
        case "Users" :
            return Image(systemName: "person.3")
            
        default :
            return Image(systemName: "house")
        }
    }
    
    var body: some View {
        Button(action: {
            
            withAnimation(.spring()) {
                selected = value
                centerX = rect.midX
            }
        }) {
            VStack {
                
               tabImage
                .resizable()
                .frame(width: 22, height: 22)
                .foregroundColor(selected == value ? Color.blue : Color.gray)
                
                Text(value)
                    .font(.caption)
                    .foregroundColor(.black)
                    .opacity(selected == value ? 1 : 0)
                
            }
            .padding(.top)
            .frame(width: 70, height: 50)
            .offset(y: selected == value ? -15 : 0)
        }
    }
}

struct CustomTabShape: Shape {
    
    var centerX : CGFloat
    
    // animating Path....
    var animatableData: CGFloat{
        
        get{return centerX}
        set{centerX = newValue}
    }
    
    func path(in rect: CGRect) -> Path {
        
        return Path{path in
            
            path.move(to: CGPoint(x: 0, y: 15))
            path.addLine(to: CGPoint(x: 0, y: rect.height))
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: rect.width, y: 15))
            
            // Curve....
            
            path.move(to: CGPoint(x: centerX - 35, y: 15))
            
            path.addQuadCurve(to: CGPoint(x: centerX + 35, y: 15), control: CGPoint(x: centerX, y: -30))
        }
    }
}
//MARK: - PLane TabView

struct PlaneTabView : View {
    
    //    init() {
    //        UITabBar.appearance().barTintColor = .gray
    //    }
    //
    
    var body: some View {
        TabView {
            
            HomeView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
            
            EditView()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Profile")
                }
            
            UsersView()
                .tabItem {
                    Image(systemName: "person.3")
                    Text("Users")
                }
            
            
            
        }
        /// selected Color
        .accentColor(Color.gray)
    }
    
}

