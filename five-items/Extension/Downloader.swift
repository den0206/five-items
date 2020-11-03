//
//  Downloader.swift
//  five-items
//
//  Created by 酒井ゆうき on 2020/10/17.
//

import Foundation
import FirebaseStorage

//MARK: - upload image firestore

/// New
func uploadMultipleImages(images : [Data], itemId : String, userId : String ,completion :  @escaping(Result<[String], Error>) -> Void) {
    
    if Reachabilty.HasConnection() {
        
        var uploadImagesCount = 0
        var imageLinksArray : [String] = []
        var nameShuffix = 0
        
        for imageData in images {
            let fileName = "ItemImages/" + "\(userId)/" + itemId + "/" + "\(nameShuffix)" + ".jpg"
            
            saveImageInFirestore(imageData: imageData, filename: fileName) { (result) in
                
                switch result {
                
                case .success(let imageLink):
                    
                    imageLinksArray.append(imageLink)
                    uploadImagesCount += 1
                    
                    if uploadImagesCount == images.count {
                        completion(.success(imageLinksArray))
                    }
                    
                case .failure(let error):
                    completion(.failure(error))
                }
            }
            
            nameShuffix += 1
        }
    } else {
        print("No Internet")
    }
}

/// Edit
func uploadMultipleImages(imageDic : [Int : Data], editItem : Item?, userId : String ,completion :  @escaping(Result<Item, Error>) -> Void) {
    
    guard var editItem = editItem else {return}
    
    var uploadImageCount = 0
    let sortedKeys = imageDic.keys.sorted()
    
    if imageDic.keys.count == 0 {
        completion(.success(editItem))
        return
    }
    
    
    for key in sortedKeys {
        let fileName = "ItemImages/" + "\(userId)/" + editItem.id + "/" + "\(key)" + ".jpg"

        let imageData = imageDic[key]

        saveImageInFirestore(imageData: imageData!, filename: fileName) { (result) in

            switch result {

            case .success(let imageLink):

                if editItem.imageLinks.indices.contains(key) {
                    editItem.imageLinks.remove(at: key)
                }

                let ImageUrl = URL(string: imageLink)

                editItem.imageLinks.insert(ImageUrl!, at: key)
                uploadImageCount += 1

                if uploadImageCount == sortedKeys.count {
                    completion(.success(editItem))
                }
            case .failure(let error):

                print(error.localizedDescription)
                completion(.failure(error))
            }
        }
    }
    
}



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
