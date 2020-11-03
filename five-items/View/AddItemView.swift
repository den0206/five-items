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
                       
                        ImageButton(itemModel: itemModel, index: 0)
                        
                        VStack(spacing : 5) {
                            ImageButton(itemModel: itemModel, index: 1)
                            
                            ImageButton(itemModel: itemModel, index: 2)
                        }
                        
                    }
                    .frame(width: UIScreen.main.bounds.width - 10, height: 300)
                    .sheet(isPresented: $itemModel.showPicker, content: {
                        ItemImagePicker(images: $itemModel.images, errorMessage: $errorMessage, showAlert: $showAlert, index: $itemModel.imageIndex)
                    })

                    
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
//
//        if testMode {
//            guard let imageData = imageByUrl(url: getExampleImageUrl("item")) else {print("Error");return}
//            itemModel.imageData = imageData
//            print(imageData.count)
//        }
        
        FBItem.registationItemMultipleImage(index: index, name: itemModel.name, urlString: relationUrl, images: itemModel.images, description: description, userId: userInfo.user.uid) { (result) in
            
            switch result {
            case .success(let item) :
                print("Success")
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

struct ImageButton : View {
    
    @StateObject var itemModel : AddItemViewModel
    var index : Int

    
    var body: some View {
        
        
        Button(action: {
            itemModel.showPicker = true
            itemModel.imageIndex = index
        }) {
            
            if itemModel.images.count > index {
                
                Image(uiImage: UIImage(data: itemModel.images[index])!)
                    .resizable()
                    
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    
                
            } else {
                Rectangle()
                    .fill(!itemModel.disableButton(int: index) ? Color(white: 0.95) : Color(white: 0.75))
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .overlay(
                        
                        Image(systemName: "plus")
                            .foregroundColor(.gray)
                            .frame(width: 30, height: 30)
                    )
            }
           
            
            
            
        }
        .padding(3)
        .disabled(itemModel.disableButton(int: index))
    }
}


struct ItemImagePicker: UIViewControllerRepresentable {
    
    @Environment(\.presentationMode) var presentationMode
    @Binding var images: [Data]
    @Binding var errorMessage : String
    @Binding var showAlert : Bool
    @Binding var index : Int
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ItemImagePicker
        
        init(_ parent: ItemImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                let data = uiImage.jpegData(compressionQuality: 0.2)
                
                let dataToKB = Double(data!.count) / 1000.0
                print(dataToKB)
                
                if dataToKB < 1000.0 {
                    
                    if parent.images.indices.contains(parent.index) {
                        parent.images.remove(at: parent.index)
                    }
                    
                    parent.images.insert(data!, at: parent.index)

                } else {
                    self.parent.errorMessage = "画像の容量が大きいです。"
                    self.parent.showAlert = true
                    return

                }
                
                
            }
            
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ItemImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ItemImagePicker>) {

    }
}
