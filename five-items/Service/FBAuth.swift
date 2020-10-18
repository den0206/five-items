//
//  FBAuth.swift
//  five-items
//
//  Created by 酒井ゆうき on 2020/10/17.
//

import Firebase

struct FBAuth {
    
    static func fecthFBUser(uid : String, completion :  @escaping(Result<FBUser, Error>) -> Void) {
        let ref = firebaseReference(.Users).document(uid)
        
        ref.getDocument { (snapshot, error) in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let snapshot = snapshot else {
                completion(.failure(FirestoreError.noDocumentSNapshot))
                return
            }
            
            guard let data = snapshot.data() else {
                completion(.failure(FirestoreError.noSnapshotData))
                return
            }
            
            guard let user = FBUser(dic: data) else {
                completion(.failure(FirestoreError.noUser))
                return
            }
            
            completion(.success(user))
            
        }
        
    }
    
    static func createUser(email : String, name : String, password : String,imageData : Data, completion :  @escaping(Result<FBUser, Error>) -> Void) {
        
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            /// check User
            
            guard let _ = result?.user else {
                completion(.failure(error!))
                return
            }
            
            guard let uid = result?.user.uid else {return}
            
            let filename =  "Avatars/_" + uid + ".jpeg"
            
            /// via upload image
            saveImageInFirestore(imageData: imageData, filename: filename) { (result) in
                
                switch result {
                
                case .success(let imageUrl):
                    
                    let data = [kUSERID : uid,
                                kNAME : name,
                                kEMAIL : email,
                                kPROFILE_IMAGE : imageUrl]
                    
                    firebaseReference(.Users).document(uid).setData(data) { (error) in
                        
                        if let error = error {
                            completion(.failure(error))
                            return
                        }
                    }
                    guard let user = FBUser(dic: data) else {return}
                    
                    completion(.success(user))
                    
                case .failure(let error):
                    
                    completion(.failure(error))
                    return
                }
            }
        }
    }
    
    static func loginUser(email : String, password : String, completion :  @escaping(Result<Bool, EmailAuthError>) -> Void) {
        
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            
            var newError : NSError
            
            if let error = error {
                newError = error as NSError
                var authError : EmailAuthError?
                
                switch newError.code {
                case 17009:
                    authError = .incorrectPassword
                case 17008 :
                    authError = .invalidEmail
                case 17011 :
                    authError = .accountDoesnotExist
                default:
                    authError = .unknownError
                }
                
                completion(.failure(authError!))
            } else {
                completion(.success(true))
            }
        }
        
       
    }
    
    static func logOut(completion :  @escaping(Result<Bool, Error>) -> Void) {
     
        do {
            try Auth.auth().signOut()
            completion(.success(true))
        } catch let error {
            
            completion(.failure(error))
        }
        
        
    }
}


enum EmailAuthError : Error {
    case incorrectPassword
    case invalidEmail
    case accountDoesnotExist
    case unknownError
    case couldNotCreate
    case extraDataNotCreated
    
    var errorDescription : String? {
        
        switch self {
        case .incorrectPassword:
            return NSLocalizedString("In Correct Password", comment: "")
        case .invalidEmail:
            return NSLocalizedString("Not a valid email", comment: "")
        case .accountDoesnotExist:
            return NSLocalizedString("Account Does Not exist", comment: "")
        case .unknownError:
            return NSLocalizedString("Unknown Error", comment: "")
        case .couldNotCreate:
            return NSLocalizedString("Could not Create User", comment: "")
        case .extraDataNotCreated:
            return NSLocalizedString("could not save User na,e", comment: "")
            
        }
    }
}


enum FirestoreError : Error {
    case noAuthResult
    case noCurrentUser
    case noDocumentSNapshot
    case noSnapshotData
    case noUser
    case emptySnapshot
}

extension FirestoreError : LocalizedError {
    
    var errorDescription : String? {
        switch self {
        
        case .noAuthResult:
            return NSLocalizedString("No AUth", comment: "")
        case .noCurrentUser:
            return NSLocalizedString("No CurrentUser", comment: "")
        case .noDocumentSNapshot:
            return NSLocalizedString("No Document Snapshot", comment: "")
        case .noSnapshotData:
            return NSLocalizedString("No Snapshot", comment: "")
        case .noUser:
            return NSLocalizedString("No User", comment: "")
        case .emptySnapshot:
            return NSLocalizedString("emptySnapshot", comment: "")

        }
    }
}

