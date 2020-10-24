//
//  LoginView.swift
//  five-items
//
//  Created by 酒井ゆうき on 2020/10/17.
//

import SwiftUI

struct LoginView: View {
    
    enum loginViewSheet : Identifiable {
        case signUp, resetPassword
        
        var id : Int {
            hashValue
        }
    }
    
    @State private var user = UserViewModel()
    
    @State private var sheetType : loginViewSheet?
    @State private var authError : EmailAuthError?
    @State private var showAlert = false
    @State private var loading = false
    
    var body: some View {
        
        ZStack {
 
            VStack {
                
                Group {
                    TextField("Email Address", text: $user.email)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    
                    SecureField("Password", text: $user.password)
                }
                .frame(width : 300)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                
                HStack {
                    Spacer()
                    
                    Button(action: {
                        sheetType = .resetPassword
                    }, label: {
                        Text("Reset Password")
                            .foregroundColor(.black)
                    })
                }.padding(.bottom)
                .padding(.trailing, 10)
                
                VStack(spacing : 10) {
                    
                    Button(action: {
                        
                        self.loading = true
                        
                        FBAuth.loginUser(email: user.email, password: user.password) { (result) in
                            
                            switch result {
                            case .success(_):
                                print("Success")
                                self.loading = false
                                
                            case .failure(let authError):
                                
                                self.loading = false

                                self.authError = authError
                                self.showAlert = true
                            }
                        }
                        
                    }, label: {
                        Text("Login")
                            .foregroundColor(.white)
                            .padding(.vertical, 15)
                            .frame(width : 200)
                            .background(Color.green)
                            .cornerRadius(8)
                            .opacity(user.isLoginComplete ? 1 : 0.7)
                    })
                    .disabled(!user.isLoginComplete)
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("Error"), message: Text(authError?.localizedDescription ?? "UnknownError"), dismissButton: .default(Text("OK")) {
                            /// reset
                            if authError == .incorrectPassword {
                                user.password = ""
                            } else {
                                user.email = ""
                                user.password = ""
                            }
                        })
                    }
                    
                    Button(action: {
                        sheetType = .signUp
                        
                    }, label: {
                        Text("SignUp")
                            .foregroundColor(.white)
                            .padding(.vertical, 15)
                            .frame(width : 200)
                            .background(Color.blue)
                            .cornerRadius(8)
                    })
                    
                }
                
            }
            .sheet(item: $sheetType) { (item) in
                switch item {
                case .signUp :
                    SignUpView()
                case .resetPassword :
                    Text("Reset")
                    
                }
            }
            
            if loading {
                Color.black.opacity(0.4)
                    .ignoresSafeArea(.all, edges: .top)
                
                ProgressView("Loading...")
                    .foregroundColor(.white)
            }
            
        }
        
     
       
        
        
    }
}

