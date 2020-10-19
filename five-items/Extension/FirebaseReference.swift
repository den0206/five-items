//
//  FirebaseReference.swift
//  five-items
//
//  Created by 酒井ゆうき on 2020/10/17.
//


import Foundation
import FirebaseFirestore

enum References : String {
    case Users
    case Items

}

func firebaseReference(_ reference : References) -> CollectionReference {
    return Firestore.firestore().collection(reference.rawValue)
}


