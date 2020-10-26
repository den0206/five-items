//
//  FBUser.swift
//  five-items
//
//  Created by 酒井ゆうき on 2020/10/21.
//

import Firebase

struct FBUserSearvice {
    
    
    static func fetchUsers(currentUser : FBUser, lastDoc : DocumentSnapshot? = nil,  completion :  @escaping(Result<([FBUser], DocumentSnapshot?, Bool), Error>) -> Void) {
        
        let limit = 10
        
        var users = [FBUser]()
        var ref : Query!
        
        if lastDoc == nil {
            ref =  firebaseReference(.Users).limit(to: limit)
        } else {
            ref = firebaseReference(.Users).start(afterDocument: lastDoc!).limit(to: limit)
        }
        
        ref.getDocuments { (snapshot, error) in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let snapshot = snapshot else {
                completion(.failure(FirestoreError.noSnapshotData))
                return
            }
            
            guard !snapshot.isEmpty else {
                completion(.failure(FirestoreError.emptySnapshot))
                return
            }
            
            snapshot.documents.forEach { (doc) in
                
                let data = doc.data()
                        
                if doc.documentID != currentUser.uid {
                    guard let user = FBUser(dic: data) else {return}
                    
                    users.append(user)
                }
            }
            
            let lastDocumet = snapshot.documents.last
            
            let reachLast = snapshot.documents.count != limit
            
            completion(.success((users, lastDocumet, reachLast)))
        }
        
        
    }
    
    //MARK: - Edit User
    
    static func editUser(currentUser : FBUser, vm : UserEditViewModel, completion :  @escaping(Result<FBUser, Error>) -> Void) {
                
        guard let user = vm.user.currentUser else {return}
                
        guard user.uid ==  currentUser.uid else { return}
        
        
        print("Edit call")
        
        
        if vm.user.imageData.count != 0 {
            
            let fileName = "Avatars/_" + currentUser.uid + ".jpeg"
            
//
            if testMode {
                guard let exampleImage = imageByUrl(url: getExampleImageUrl()) else {print("Error");return}
                vm.user.imageData = exampleImage

            }
            
            saveImageInFirestore(imageData: vm.user.imageData, filename: fileName) { (result) in
                
                switch result {
                
                case .success(let imageUrl):
                    
                    FBUserSearvice.updateUser(currentUser: currentUser, uservm: vm.user, imageUrl: imageUrl) { (resultUser) in
                        
                        switch resultUser {
                        
                        case .success(let fUser):
                            completion(.success(fUser))
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            FBUserSearvice.updateUser(currentUser: currentUser, uservm: vm.user, imageUrl: nil) { (resultUser) in
                
                switch resultUser {
                
                case .success(let fUser):
                    completion(.success(fUser))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
      
    }
    
    static func updateUser(currentUser : FBUser, uservm : UserViewModel, imageUrl : String?, completion :  @escaping(Result<FBUser, Error>) -> Void) {
        
        let uid = currentUser.uid
        var data = [kUSERID : uid,
                    kNAME : uservm.fullname,
                    kEMAIL : uservm.email] as [String : Any]
        
        if imageUrl != nil {
            data[kPROFILE_IMAGE] = imageUrl!
        } else {
            data[kPROFILE_IMAGE] = currentUser.avaterUrl?.absoluteString
        }
        
        firebaseReference(.Users).document(uid).updateData(data) { (error) in
            
            if let error = error {
                completion(.failure(error))
                return
            }
        }
        
        guard var user = FBUser(dic: data) else {return}
        
        FBItem.fetchUserItems(user: user) { (itemResult) in
            switch itemResult {
            
            case .success(let items):
                user.items = items
                completion(.success(user))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
