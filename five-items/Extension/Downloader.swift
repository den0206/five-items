//
//  Downloader.swift
//  five-items
//
//  Created by 酒井ゆうき on 2020/10/17.
//

import Foundation
import FirebaseStorage

//MARK: - upload image firestore

func saveImageInFirestore(imageData : Data, filename : String,comletion :  @escaping(Result<String, Error>) -> Void) {
    
    let storage = Storage.storage()
    
    let storageRef = storage.reference().child(filename)
    var task : StorageUploadTask!

    
    task = storageRef.putData(imageData, metadata: nil, completion: { (meta, error) in
        
        task.removeAllObservers()
        
        if let error = error {
            print(error.localizedDescription)
            comletion(.failure(error))
            return
        }
        
        storageRef.downloadURL { (url, error) in
            
            guard let downloadUrl = url else { return}
            
            comletion(.success(downloadUrl.absoluteString))
        }
        
    })
    
}
