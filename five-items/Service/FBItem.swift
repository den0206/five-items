//
//  FBItem.swift
//  five-items
//
//  Created by 酒井ゆうき on 2020/10/18.
//

import Firebase

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

