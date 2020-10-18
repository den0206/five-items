//
//  five_itemsApp.swift
//  five-items
//
//  Created by 酒井ゆうき on 2020/10/17.
//

import SwiftUI
import Firebase

public var testMode = true

@main
struct five_itemsApp: App {
    
    var userInfo : UserInfo = UserInfo()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView().environmentObject(userInfo)
        }
    }
}
