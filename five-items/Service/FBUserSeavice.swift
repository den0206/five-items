//
//  FBUser.swift
//  five-items
//
//  Created by 酒井ゆうき on 2020/10/21.
//

import Firebase

struct FBUserSearvice {
    
    static func fetchUsers(currentUser : FBUser, completion :  @escaping(Result<[FBUser], Error>) -> Void) {
        
        var users = [FBUser]()
        
        firebaseReference(.Users).getDocuments { (snapshot, error) in
            
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
            
            completion(.success(users))
        }
        
        
    }
}
