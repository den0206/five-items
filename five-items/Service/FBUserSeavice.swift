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
    
    static func editUser(currentUID : String, vm : UserEditViewModel, completion :  @escaping(Result<FBUser, Error>) -> Void) {
        
        guard vm.user.currentUser?.uid == currentUID else { return}
        
        if vm.user.imageData.count != 0 {
            
        } else {
            
        }
        
        
    }
}
