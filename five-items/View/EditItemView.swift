//
//  EditItemView.swift
//  five-items
//
//  Created by 酒井ゆうき on 2020/10/20.
//

import SwiftUI
import SDWebImageSwiftUI

struct EditItemView: View {
    
    var item : Item
    @StateObject var vm =  AddItemViewModel()
    
    @State private var errorMessage = ""
    @State private var showAlert = false

    
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        
        NavigationView {
            
            ScrollView(.vertical, showsIndicators: false, content: {
                
                VStack(spacing : 20) {

                    HStack {
                        Button(action: {vm.showPicker = true}) {
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
                                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
                            }
                    }
                    
                    Spacer()
                    
                    Group {
                        VStack(alignment: .leading) {
                            HStack {
                                TextField("アイテム名", text: $vm.name)
                                    .onAppear {
                                        self.vm.name = item.name
                                    }
                                
                                Image(systemName: "asterisk.circle.fill")
                                    .foregroundColor(.red)
                                    .font(.system(size: 22))
                            }
                            
                            
                            if !vm.validNameText.isEmpty {
                                Text(vm.validNameText).font(.caption).foregroundColor(.red)
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
//                            addItem()
                        }) {
                            Text("追加する")
                                .foregroundColor(.white)
                                .padding(.vertical,15)
                                .frame(width : 200)
                                .background(Color.green)
                                .cornerRadius(8)
                                .opacity(vm.didChangeStatus ? 1 : 0.7)
                        }
                        .disabled(!vm.didChangeStatus)
                        
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
            print(vm.editItem)
        }
    }
}


