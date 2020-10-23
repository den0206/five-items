//
//  FBItem.swift
//  five-items
//
//  Created by 酒井ゆうき on 2020/10/18.
//

import Firebase
import SwiftUI

struct FBItem  {
    

    static func registrationItem(index: Int,name : String, urlString : String?,imageData : Data, description : String?, userId : String ,completion :  @escaping(Result<Item, Error>) -> Void) {
        
        let itemId = UUID().uuidString
        let fileName = "ItemImages/" + "\(userId)/" + "item\(index)" + ".jpg"
        
        saveImageInFirestore(imageData: imageData, filename: fileName) { (result) in
            
            switch result {
            
            case .success(let imageUrl):
                
                var data = [kITEMID : itemId,
                            kITEMNAME : name,
                            kUSERID : userId,
                            kIMAGELINK : imageUrl,
                            kINDEX : index,
                            kDATE : Timestamp(date: Date())
                            
                ] as [String : Any]
                
                if description != nil {
                    data[kDESCRIPTION] = description
                }
                
                if urlString != nil {
                    data[kRELATIONURL] = urlString
                }
                
                firebaseReference(.Users).document(userId).collection(kITEMS).document(itemId).setData(data, merge: true) { (error) in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                }
              
                guard let item = Item(dic: data) else {return}
            
                completion(.success(item))
            
            case .failure(let error):
                
                print(error.localizedDescription)
                completion(.failure(error))
            }
        }

        
         
    }

    
    
    static func editItem(vm : AddItemViewModel, user : FBUser, completion :  @escaping(Result<Item , Error>) -> Void) {
        
        guard let editItem = vm.editItem else {return}
        
        let userId = user.uid
       
        let itemId = editItem.id
        
        if vm.imageData.count != 0 {
            
            let fileName = "ItemImages/" + "\(userId)/" + "item\(editItem.index)" + ".jpg"
            
            
            saveImageInFirestore(imageData: vm.imageData, filename: fileName) { (result) in
                
                switch result {
                case .success(let imageUrl) :
                    
                    FBItem.updateItem(itemId: itemId, userId: userId, vm: vm, imageUrl: imageUrl) { (resultItem) in
                        switch resultItem {
                        
                        case .success(let item):
                            completion(.success(item))
                        case .failure(let error ):
                            completion(.failure(error))
                        }
                    }
                    
                case .failure(let error):
                    
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
                
                
            }
        } else {
            
            FBItem.updateItem(itemId: itemId, userId: userId, vm: vm, imageUrl: nil) { (resultItem) in
                switch resultItem {
                
                case .success(let item):
                    completion(.success(item))
                case .failure(let error ):
                    completion(.failure(error))
                }
            }
        }
    }
    
    static func updateItem(itemId : String, userId : String,vm : AddItemViewModel, imageUrl : String? ,completion:  @escaping(Result<Item, Error>) -> Void) {
        
        var data = [kITEMID : itemId,
                    kITEMNAME : vm.name,
                    kUSERID : userId,
                    kINDEX : vm.editItem!.index,
                    kDATE : Timestamp(date: Date())
                    
        ] as [String : Any]
        
        if imageUrl != nil {
            data[kIMAGELINK] = imageUrl!
        } else {
            data[kIMAGELINK] = vm.editItem!.imageUrl.absoluteString
        }
        
        if vm.description != "" {
            data[kDESCRIPTION] = vm.description
        }
        
        if vm.url != "" {
            data[kRELATIONURL] = vm.url
        }
        
        firebaseReference(.Users).document(userId).collection(kITEMS).document(itemId).updateData(data) { (error) in
            
            if let error = error {
                completion(.failure(error))
                return
            }
        }
        
        guard let item = Item(dic: data) else {return}
    
        completion(.success(item))
    
    }
    
    
    static func deleteItem(item : Item ,userId : String, completion :  @escaping(Result<Int , Error>) -> Void) {
        
        guard item.userId == userId else {
            completion(.failure(FirestoreError.noUser))
            return}
        let strogeRef = Storage.storage().reference()

        print("Call")
        
        firebaseReference(.Users).document(userId).collection(kITEMS).document(item.id).delete { (error) in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            /// delete image from storage
            strogeRef.child("ItemImages").child(userId).child("item\(item.index).jpg").delete { (error) in
                
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                print("Success Delete Item")
                
                completion(.success(item.index))
            }

        }
        
    }
    
    
    
    
    static func fetchUserItems(user : FBUser, completion :  @escaping(Result<[Item?], Error>) -> Void) {
        
        var items : [Item?] = Array(repeating: nil, count: 5)
        
        let ref = firebaseReference(.Users).document(user.uid).collection(kITEMS)
        
            ref.getDocuments { (snapshot, error) in
            
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
                    guard let item = Item(dic: data) else {return}
                    
                    items[item.index] = item
                    
                    
                }
                
                completion(.success(items))
        }
    }
}

extension FBItem {
    
    static func fetchAllitems(userId : String, lastDoc : DocumentSnapshot? = nil, completion :  @escaping(Result<([Item], DocumentSnapshot?), Error>) -> Void) {
        
        var items = [Item]()
        var ref : Query!
        
        var myCount = 0
        var docCount = 0
        var existCount : Int {
            docCount - myCount
        }
       
        
        if lastDoc == nil {
            ref = Firestore.firestore().collectionGroup(kITEMS).order(by: kDATE, descending: true).limit(to: 12)
            
        } else {
            print("call")
            ref = Firestore.firestore().collectionGroup(kITEMS).order(by: kDATE, descending: true).start(afterDocument: lastDoc!).limit(to: 12)
            
        }
        
      
        
        ref.getDocuments { (snapshot, error) in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let snapshot = snapshot else {
                completion(.failure(FirestoreError.noDocumentSNapshot))
                return}
            
            guard !snapshot.isEmpty else {
                completion(.failure(FirestoreError.emptySnapshot))
                return}
            
            snapshot.documents.forEach { (doc) in
                
                
                let data = doc.data()
                guard let item = Item(dic: data) else {
                    completion(.failure(FirestoreError.noUser))
                    print("BUG")
                    return
                }
                
                if item.userId != userId {
                    items.append(item)
                    docCount += 1
                } else {
                    myCount += 1
                }
            }
            
            let lastDoc = snapshot.documents.last
            
            completion(.success((items, lastDoc)))
        }
        
        
    }
    
   static func getLastItem(completion :  @escaping(Result<DocumentSnapshot?, Error>) -> Void) {
    
        Firestore.firestore().collectionGroup(kITEMS).order(by: kDATE, descending: true).limit(toLast: 1).getDocuments { (snapshot, error) in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let snapshot = snapshot else {
                completion(.failure(FirestoreError.noDocumentSNapshot))
                return
                
            }
            guard !snapshot.isEmpty else {
                completion(.failure(FirestoreError.emptySnapshot))
                return}
            
            completion(.success(snapshot.documents.last))
        }
    }
}

