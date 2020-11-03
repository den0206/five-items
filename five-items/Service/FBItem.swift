//
//  FBItem.swift
//  five-items
//
//  Created by 酒井ゆうき on 2020/10/18.
//

import Firebase
import SwiftUI


struct FBItem  {
    
    static func registationItemMultipleImage(index: Int,name : String, urlString : String?,images : [Data], description : String?, userId : String ,completion :  @escaping(Result<Item, Error>) -> Void) {
        
        let itemId = UUID().uuidString
        
        uploadMultipleImages(images: images, itemId: itemId, userId: userId) { (result) in
            switch result {
            
            case .success(let imageLinks):
                
                var data = [kITEMID : itemId,
                            kITEMNAME : name,
                            kUSERID : userId,
                            kIMAGELINKARRAY : imageLinks,
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
    
   static func editItemWithMultipleImage(vm : AddItemViewModel, user : FBUser, completion : @escaping(Result<Item, Error>) -> Void) {
        
        guard let editItem = vm.editItem else {return}
        
        let userId = user.uid
       
        let itemId = editItem.id
        
    if !vm.changeImageDictionary.isEmpty {
            
            uploadMultipleImages(imageDic: vm.changeImageDictionary, editItem: editItem, userId: userId) { (result) in

                switch result {

                case .success(let item):

                    FBItem.updateItem(itemId: itemId, userId: userId, vm: vm, imageLinks: item.imageLinks) { (result) in
                        switch result {

                        case .success(let completeItem):
                            completion(.success(completeItem))
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
            
        } else {
            FBItem.updateItem(itemId: itemId, userId: userId, vm: vm, imageLinks: nil) { (resultItem) in
                switch resultItem {

                case .success(let item):
                    completion(.success(item))
                case .failure(let error ):
                    completion(.failure(error))
                }
            }
        }
    }

    
    
    static func updateItem(itemId : String, userId : String,vm : AddItemViewModel, imageLinks : [URL]? ,completion:  @escaping(Result<Item, Error>) -> Void) {
        
        var data = [kITEMID : itemId,
                    kITEMNAME : vm.name,
                    kUSERID : userId,
                    kINDEX : vm.editItem!.index,
                    kDATE : Timestamp(date: Date())
                    
        ] as [String : Any]
        
        if imageLinks != nil {
            data[kIMAGELINKARRAY] = imageLinks!.map({$0.absoluteString})
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
        
        if imageLinks == nil {
            data[kIMAGELINKARRAY] = vm.editItem?.imageLinks.map({$0.absoluteString})
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
            
            strogeRef.child("ItemImages").child(userId).child(item.id).listAll { (result, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                for ref in result.items {
                    
                    ref.delete { (error) in
                        if let error = error {
                            completion(.failure(error))
                            return
                        }
                        
                        print("Success Delete Item")
                        
                        completion(.success(item.index))
                        
                    }
                }
            }
            
//            /// delete image from storage
//            strogeRef.child("ItemImages").child(userId).child("item\(item.index).jpg").delete { (error) in
//
//                if let error = error {
//                    completion(.failure(error))
//                    return
//                }
//
//                print("Success Delete Item")
//
//                completion(.success(item.index))
//            }

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
    
    static func fetchAllitems(userId : String, lastDoc : DocumentSnapshot? = nil, completion :  @escaping(Result<([Item], DocumentSnapshot?, Int), Error>) -> Void) {
        
        var items = [Item]()
        var ref : Query!
        
        
     
        if lastDoc == nil {
            ref = Firestore.firestore().collectionGroup(kITEMS).order(by: kDATE, descending: true).limit(to: 12)
            
        } else {
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
                } 
            }
            
            let lastDoc = snapshot.documents.last
            let docCount = snapshot.documents.count
            completion(.success((items, lastDoc, docCount)))
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

