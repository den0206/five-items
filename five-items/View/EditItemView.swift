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
    
    @Binding var item : Item
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
                       
                        EditImageButton(itemModel: vm, index: 0)
                        
                        VStack(spacing : 5) {
                            EditImageButton(itemModel: vm, index: 1)
                            
                            EditImageButton(itemModel: vm, index: 2)
                        }
                        
                    }
                    .frame(width: UIScreen.main.bounds.width - 10, height: 300)
                    .sheet(isPresented: $vm.showPicker, content: {
                        EditItemImagePicker(images: $vm.changeImageDictionary, errorMessage: $errorMessage, showAlert: $showAlert, index: $vm.imageIndex)
                    })


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
        .loading(isShowing: $vm.showLoading)
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
        
        vm.showLoading = true
        
        FBItem.editItemWithMultipleImage(vm: vm, user: userInfo.user) { (result) in
            
            switch result {
            
            case .success(let item):
                userInfo.user.items[item.index] = item
                vm.showLoading = false
                self.presentationMode.wrappedValue.dismiss()
                
            case .failure(let error):
                vm.showLoading = false
                
                errorMessage = error.localizedDescription
                showAlert = true
            }
        }
 
    }
    
    func deleteItem() {
        
        vm.showLoading = true
        
        FBItem.deleteItem(item: item, userId: userInfo.user.uid) { (result) in
            
            switch result {
            
            case .success(let index):
                
                vm.showLoading = false

                userInfo.user.items[index] = nil
                self.presentationMode.wrappedValue.dismiss()
                
            case .failure(let error):
                
                vm.showLoading = false

                self.alertType = .errorMessage
                self.errorMessage = error.localizedDescription
                self.showAlert = true
            }
        }
    }
}

struct EditImageButton : View {
    
    @StateObject var itemModel : AddItemViewModel
    var index : Int

    
    var body: some View {
    
        Button(action: {
            itemModel.showPicker = true
            itemModel.imageIndex = index
        }) {
            
            if itemModel.changeImageDictionary[index] != nil {
                
                Image(uiImage: UIImage(data: itemModel.changeImageDictionary[index]!)!)
                    .resizable()
                    
                    .cornerRadius(10)
                    .shadow(radius: 5)
                
            } else if itemModel.editItem != nil {
                
                if (itemModel.editItem?.imageLinks.count)! > index {
                    WebImage(url: itemModel.editItem?.imageLinks[index])
                        .resizable()
                        .placeholder {
                            Rectangle()
                                .fill(Color(white: 0.95))
                                .overlay(
                                    ProgressView()
                                        .foregroundColor(.black)
                                )
                        }
                        .cornerRadius(10)
                        .shadow(radius: 5)
                } else {
                    
                    Rectangle()
                        .fill(!itemModel.editDisableButton(int: index) ? Color(white: 0.95) : Color(white: 0.75))
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .overlay(
                            
                            Image(systemName: "plus")
                                .foregroundColor(.gray)
                                .frame(width: 30, height: 30)
                        )
                
               
                }
                
                
            } else {
                
                    Rectangle()
                        .fill(!itemModel.editDisableButton(int: index) ? Color(white: 0.95) : Color(white: 0.75))
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
        .disabled(itemModel.editDisableButton(int: index))
    }
}

struct EditItemImagePicker: UIViewControllerRepresentable {
    
    @Environment(\.presentationMode) var presentationMode
    @Binding var images: [Int : Data]
    @Binding var errorMessage : String
    @Binding var showAlert : Bool
    @Binding var index : Int
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: EditItemImagePicker
        
        init(_ parent: EditItemImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                let data = uiImage.jpegData(compressionQuality: 0.2)
                
                let dataToKB = Double(data!.count) / 1000.0
                print(dataToKB)
                
                if dataToKB < 1000.0 {
                    
                    parent.images[parent.index] = data
                    

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
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<EditItemImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<EditItemImagePicker>) {

    }
}
