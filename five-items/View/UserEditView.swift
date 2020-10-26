//
//  UserEditView.swift
//  five-items
//
//  Created by 酒井ゆうき on 2020/10/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct UserEditView: View {
    
    @EnvironmentObject var userInfo : UserInfo
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject var vm = UserEditViewModel()

    var body: some View {
        
        ScrollView  {
            
            HStack {
                Spacer(minLength: 0)
                
                Button(action: {self.presentationMode.wrappedValue.dismiss()}) {
                    Image(systemName: "xmark")
                        .font(.system(size: 22))
                        .foregroundColor(.black)
                }
            }
            .padding()
            
            Spacer().frame(height: 30)
            
            HStack {
                Spacer(minLength: 0)
                
                Button(action: {
                    vm.showPicker = true
                }) {
                    if !(vm.user.imageData.count == 0) {
                        Image(uiImage: UIImage(data: vm.user.imageData)!)
                            .resizable()
                            .frame(width: 90, height: 90)
                            .clipShape(Circle())
                    } else {
                        WebImage(url: userInfo.user.avaterUrl)
                            .resizable()
                            .frame(width: 90, height: 90)
                            .clipShape(Circle())
                            
                    }
               
                }
                .sheet(isPresented: $vm.showPicker) {
                    ImagePicker(image: $vm.user.imageData, errorMessage: $vm.errorMessage, showAlert: $vm.showAlert)
                }
                
                Spacer(minLength: 0)
            }
            .padding()
            
            VStack {
                Group {
                    
                    VStack(alignment: .leading) {
                        TextField("", text: $vm.user.fullname)
                            .onAppear {
                                self.vm.user.fullname = userInfo.user.name
                            }
                        
                        if !vm.user.validNameText.isEmpty {
                            Text(vm.user.validNameText).font(.caption).foregroundColor(.red)
                          }
                        
                    }
                    
                    VStack(alignment: .leading) {
                        TextField("", text : $vm.user.email)
                            .onAppear {
                                self.vm.user.email = userInfo.user.email
                            }
                        
                        if !vm.user.validEmailText.isEmpty {
                            Text(vm.user.validEmailText).font(.caption).foregroundColor(.red)
                        }
                    }
          
                    
                }
                .foregroundColor(.black)
                .font(.system(size: 22))
                .frame(width: 300)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            }
            .padding()
            
            Button(action: {
                
                vm.loading = true
    
                FBUserSearvice.editUser(currentUser: userInfo.user, vm: vm) { (result) in
                    
                    switch result {
                    
                    case .success(let user):
                        userInfo.user = user
                        
                        vm.loading = false
                        self.presentationMode.wrappedValue.dismiss()
                        
                    case .failure(let error):
                        
                        vm.loading = false
                        
                        vm.errorMessage = error.localizedDescription
                        vm.showAlert = true
                    }
                }
            }) {
                Text("Save")
                    .foregroundColor(.white)
                    .padding(.vertical)
                    .padding(.horizontal,40)
                    .background(Color.green)
                    .clipShape(Capsule())
                    .opacity(vm.user.didChangeStatus ? 1 : 0.6)
                
            }
            .disabled(!vm.user.didChangeStatus)

            
            
        }
        .onAppear {
            vm.user.currentUser = userInfo.user
        }
        .loading(isShowing: $vm.loading)
    }
}

