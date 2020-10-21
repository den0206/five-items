//
//  EditItemView.swift
//  five-items
//
//  Created by 酒井ゆうき on 2020/10/20.
//

import SwiftUI
import SDWebImageSwiftUI

struct EditItemView: View {
    
    enum AleretType {
        case errorMessage
        case delete
    }
    
    var item : Item
    @EnvironmentObject var userInfo : UserInfo
    @StateObject var vm =  AddItemViewModel()
    
    @State private var errorMessage = ""
    @State private var showAlert = false
    @State private var alertType : AleretType = .errorMessage
    
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        
        NavigationView {
            
            ScrollView(.vertical, showsIndicators: false, content: {
                
                VStack(spacing : 20) {

                    HStack {
                        Button(action: {
                                alertType = .errorMessage
                                vm.showPicker = true
                            
                        }) {
                            if vm.imageData.count == 0 {
                                WebImage(url: vm.editItem?.imageUrl)
                                    .resizable()
                                    .placeholder {
                                        Rectangle()
                                            .fill(Color(white: 0.95))
                                            .frame(width: 120, height: 120)
                                            .cornerRadius(10)
                                            .shadow(radius: 5)
                                            .overlay(ProgressView()
                                            .foregroundColor(.white))
                                    }
                                    .frame(width: 120, height: 120)
                                    .cornerRadius(10)
                                    .shadow(radius: 5)

                            } else {
                                Image(uiImage: UIImage(data: vm.imageData)!)
                                    .resizable()
                                    .frame(width: 120, height: 120)
                                    .cornerRadius(10)
                                    .shadow(radius: 5)
                            }
                        }
                    }
                    .padding(.bottom, 30)
                    .sheet(isPresented: $vm.showPicker) {
                        ImagePicker(image: $vm.imageData, errorMessage: $errorMessage, showAlert: $showAlert)
                            .alert(isPresented: $showAlert) {
                                return Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
                                
                            }
                    }
                    
                    Spacer()
                    
                    Group {
                        VStack(alignment: .leading) {
                            
                            if !vm.validNameText.isEmpty {
                                Text(vm.validNameText).font(.caption).foregroundColor(.red)
                            }
                            
                            HStack {
                                
                                TextField("アイテム名", text: $vm.name)
                                    .onAppear {
                                        self.vm.name = item.name
                                    }
                                
                                Image(systemName: "asterisk.circle.fill")
                                    .foregroundColor(.red)
                                    .font(.system(size: 22))
                            }
                            
                        }
                        
                        TextField("関連URL",text : $vm.url)
                            .onAppear {
                                self.vm.url = item.relationUrl?.absoluteString ?? ""
                            }
                    }.frame(width: 300)
                    .autocapitalization(.none)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextArea("Description", text: $vm.description, showPL: $vm.showPL)
                        .frame(width: UIScreen.main.bounds.width - 30, height: 150)
                        .onChange(of: vm.description) { _ in

                            if vm.description.isEmpty {
                                vm.showPL = true
                            } else {
                                vm.showPL = false
                            }
                        }
                        .onAppear {
                            self.vm.description = item.description ?? ""
                        }
                    
                    VStack(spacing : 20) {
                        
                        Button(action: {
                        
                            editItem()
                        }) {
                            Text("更新する")
                                .foregroundColor(.white)
                                .padding(.vertical,15)
                                .frame(width : 200)
                                .background(Color.green)
                                .cornerRadius(8)
                                .opacity(vm.didChangeStatus && !isEmpty(_field: vm.name) ? 1 : 0.7 )
                        }
                        .disabled(!vm.didChangeStatus || isEmpty(_field: vm.name))
                        
                        Button(action: {
                            self.alertType = .delete
                            self.showAlert = true
                        }) {
                            Text("削除する")
                                .foregroundColor(.white)
                                .padding(.vertical,15)
                                .frame(width: 200)
                                .background(Color.red)
                                .cornerRadius(8)
                        }
                        .alert(isPresented: $showAlert) {
                            switch alertType {
                            
                            case .errorMessage:
                                return  Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
                                
                            case .delete:
                                return Alert(title: Text("Delete"), message: Text("\(item.name) を削除しても宜しいでしょうか？"), primaryButton: .cancel(Text("Cancel")), secondaryButton: .destructive(Text("Delete"), action: {
                                    /// delete   Action
                                    
                                    deleteItem()

                                }))
                            }
                        }
                        
                    }.padding()
            
                    
                    
                }
                
            })
            .navigationBarItems(trailing: Button(action: {
                self.presentationMode.wrappedValue.dismiss()
                
            }, label: {
                Image(systemName: "xmark.circle")
                    .foregroundColor(.black)
            }))
            
        }.onAppear {
            vm.editItem = item
        }
    }
}

extension EditItemView {
    
    func editItem() {
        
        if vm.url != "" {
            
            if vm.velidUrl(urlString: vm.url) {
                _ = vm.url
            } else {
                errorMessage = "URLの書式が間違っています"
                showAlert = true
                return
            }
        }
        
        
        FBItem.editItem(vm: vm, user: userInfo.user) { (result) in
            
            switch result {
            
            case .success(let item):
                userInfo.user.items[item.index] = item
                self.presentationMode.wrappedValue.dismiss()

            case .failure(let error):
                errorMessage = error.localizedDescription
                showAlert = true
            }
        }
  
    }
    
    func deleteItem() {
        
        FBItem.deleteItem(item: item, userId: userInfo.user.uid) { (result) in
            
            switch result {
            
            case .success(let index):
                userInfo.user.items[index] = nil
                self.presentationMode.wrappedValue.dismiss()
                
            case .failure(let error):
                self.alertType = .errorMessage
                self.errorMessage = error.localizedDescription
                self.showAlert = true
            }
        }
    }
}


