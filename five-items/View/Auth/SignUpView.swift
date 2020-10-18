//
//  SignUpView.swift
//  five-items
//
//  Created by 酒井ゆうき on 2020/10/17.
//

import SwiftUI

struct SignUpView: View {
    
    @EnvironmentObject var userInfo : UserInfo

    @State private var user : UserViewModel = UserViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showPicker = false
    @State private var errorMessage = ""
    @State private var showAlert = false
    
    var body: some View {
        
        NavigationView {
            ScrollView(.vertical, showsIndicators: false, content: {
                
                if !user.selectedImage() {
                    Text(user.validImageText).font(.caption).foregroundColor(.red)
                }
                
                Button(action: {self.showPicker = true}, label: {
                    if user.imageData.count == 0 {
                        Image(systemName: "person.crop.circle")
                            .resizable()
                            .frame(width: 90, height: 90)
                            .foregroundColor(.gray)
                    } else {
                        Image(uiImage: UIImage(data: user.imageData)!)
                            .resizable()
                            .frame(width: 90, height: 90)
                            .clipShape(Circle())
                    }
                })
                .padding(.bottom, 15)
                .sheet(isPresented: $showPicker) {
                    ImagePicker(image: $user.imageData, errorMessage: $errorMessage, showAlert: $showAlert)
                        .alert(isPresented: $showAlert) {
                            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
                        }
                }
                
                Spacer()
                
                Group {
                    VStack(alignment: .leading, content: {
                        TextField("Fullname", text: $user.fullname)
                            .autocapitalization(.none)
                        
                        if !user.validNameText.isEmpty {
                            Text(user.validNameText).font(.caption).foregroundColor(.red)
                        }
                    })
                    
                    VStack(alignment: .leading, content: {
                        TextField("email Address", text: $user.email)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                        
                        if !user.validEmailText.isEmpty {
                            Text(user.validEmailText).font(.caption).foregroundColor(.red)
                        }
                    })
                    
                    VStack(alignment: .leading, content: {
                        SecureField("Pasword", text: $user.password)
                        
                        if !user.validPasswordText.isEmpty {
                            Text(user.validPasswordText).font(.caption).foregroundColor(.red)
                        }
                        
                    })
                    
                    VStack(alignment: .leading, content: {
                        SecureField("Pasword Confirmation", text: $user.confirmPassword)
                        
                        if !user.passwordMatch(_confirmPass: user.confirmPassword) {
                            Text(user.validConfirmPasswordText).font(.caption).foregroundColor(.red)
                        }
                        
                    })
                 
                }
                .frame(width: 300)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                
                VStack(spacing : 20) {
                    
                    Button(action: {
                        
                        FBAuth.createUser(email: user.email, name: user.fullname, password: user.password, imageData: user.imageData) { (result) in
                            
                            switch result {
                            
                            case .success(let user):
                                print("Success")
                                self.userInfo.user = user
                            case .failure(let error):
                                
                                errorMessage = error.localizedDescription
                                showAlert = true
                                return
      
                            }
                        }
                    }) {
                        Text("Register")
                            .foregroundColor(.white)
                            .padding(.vertical, 15)
                            .frame(width : 200)
                            .background(Color.green)
                            .cornerRadius(8)
                            .opacity(user.isSignupComplete ? 1 : 0.7)
                    }
                    .disabled(!user.isSignupComplete)
                    
                    Spacer()
                }
                .padding()
                
                
            })
            .navigationBarItems(trailing: Button(action: {
                self.presentationMode.wrappedValue.dismiss()
                
            }, label: {
                Image(systemName: "xmark.circle")
                    .foregroundColor(.black)
            }))
        }
        .alert(isPresented: $showAlert, content: {
            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        })

    }
}

//MARK: - Image Pickert
struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var image: Data
    @Binding var errorMessage : String
    @Binding var showAlert : Bool
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                let data = uiImage.jpegData(compressionQuality: 0.2)
                
                let dataToKB = Double(data!.count) / 1000.0
                print(dataToKB)
                
                if dataToKB < 1000.0 {
                    self.parent.image = data!

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
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {

    }
}


