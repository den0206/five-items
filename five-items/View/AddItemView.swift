//
//  AddItemView.swift
//  five-items
//
//  Created by 酒井ゆうき on 2020/10/18.
//

import SwiftUI
import Foundation

struct AddItemView: View {
    
    @Binding var  index : Int
    
    @EnvironmentObject var userInfo : UserInfo
    @StateObject private var itemModel = AddItemViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    @State private var errorMessage = ""
    @State private var showAlert = false

    var body: some View {
        
        NavigationView {
            
            ScrollView(.vertical, showsIndicators: false, content: {
                
                VStack(spacing : 20) {
                    
                    if !itemModel.selectedImage() {
                        Text(itemModel.validImageText)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    
                    HStack {
                        Button(action: {itemModel.showPicker = true}) {
                            
                            if itemModel.imageData.count == 0 {
                                Rectangle()
                                    .fill(Color(white: 0.95))
                                    .frame(width: 120, height: 120)
                                    .cornerRadius(10)
                                    .shadow(radius: 5)
                                    .overlay(
                                        Image(systemName: "plus")
                                            .foregroundColor(.gray)
                                            .frame(width: 30, height: 30)
                                    )
                            } else {
                                Image(uiImage: UIImage(data: itemModel.imageData)!)
                                    .resizable()
                                    .frame(width: 120, height: 120)
                                    .cornerRadius(10)
                                    .shadow(radius: 5)
                            }
                        
                        }
                       
                    }
                    .padding(.bottom, 30)
                    .sheet(isPresented: $itemModel.showPicker) {
                        ImagePicker(image: $itemModel.imageData, errorMessage: $errorMessage, showAlert: $showAlert)
                            .alert(isPresented: $showAlert) {
                                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
                            }
                    }
                    
                    Group {
                        
                        HStack {
                            TextField("アイテム名", text: $itemModel.name)
                            
                            Image(systemName: "asterisk.circle.fill")
                                .foregroundColor(.red)
                                .font(.system(size: 22))
                        }
                        
                        
                        TextField("関連URL",text : $itemModel.url)
                        
                    }.frame(width: 300)
                    .autocapitalization(.none)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    /// editor extension
                    TextArea("Description", text: $itemModel.description, showPL: $itemModel.showPL)
                        .frame(width: UIScreen.main.bounds.width - 30, height: 150)
                        .onChange(of: itemModel.description) { _ in

                            if itemModel.description.isEmpty {
                                itemModel.showPL = true
                            } else {
                                itemModel.showPL = false
                            }
                        }
                    
                    VStack(spacing : 20) {
                        
                        Button(action: {
                            addItem()
                        }) {
                            Text("追加する")
                                .foregroundColor(.white)
                                .padding(.vertical,15)
                                .frame(width : 200)
                                .background(Color.green)
                                .cornerRadius(8)
                                .opacity(itemModel.isComplete ? 1 : 0.7)
                        }
                        .disabled(!itemModel.isComplete)
                        
                    }.padding()
            
                    
                }.frame(maxWidth: .infinity)
                .padding(.top,30)
            })
            .alert(isPresented: $showAlert, content: {
                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            })
            
            .navigationTitle("アイテム\(index + 1)を追加")
            .navigationBarItems(trailing: Button(action: {
                self.presentationMode.wrappedValue.dismiss()
                
            }, label: {
                Image(systemName: "xmark.circle")
                    .foregroundColor(.black)
            }))
        }
        .loading(isShowing: $itemModel.showLoading)
        
        
    }
}

extension AddItemView {
    
    func addItem() {
        
        var relationUrl : String?
        var description : String?
        
        if itemModel.url != "" {
            
            if itemModel.velidUrl(urlString: itemModel.url) {
                relationUrl = itemModel.url
            } else {
                errorMessage = "URLの書式が間違っています"
                showAlert = true
                return
            }
        }
        
        if itemModel.description != "" {
            description = itemModel.description
        }
        
        itemModel.showLoading = true

        FBItem.registrationItem(index : index,name: itemModel.name, urlString: relationUrl, imageData: itemModel.imageData, description: description, userId: userInfo.user.uid) { (result) in
            
            
            switch result {
            
            case .success(let item):
                print("success")
                itemModel.showLoading = false

                self.userInfo.user.items[index] = item
                self.presentationMode.wrappedValue.dismiss()

            case .failure(let error):
                itemModel.showLoading = false

                errorMessage = error.localizedDescription
                showAlert = true
            }
        }
    }
    

}
