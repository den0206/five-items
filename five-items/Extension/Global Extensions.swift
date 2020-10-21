//
//  Global Extensions.swift
//  five-items
//
//  Created by 酒井ゆうき on 2020/10/18.
//

import Foundation
import SwiftUI

extension String {
    var isBlank: Bool {
        return allSatisfy({ $0.isWhitespace })
    }
}

func hideKeyBord() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}

func isEmpty(_field : String) -> Bool {
    
    return _field.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
}

struct TextArea: View {
    private let placeholder: String
    @Binding var text: String
    @Binding var showPlacehoder : Bool
    
    init(_ placeholder: String, text: Binding<String>, showPL : Binding<Bool>) {
        self.placeholder = placeholder
        self._text = text
        self._showPlacehoder = showPL
    }
    
    var body: some View {
        
        ZStack(alignment: .topLeading) {
            
            TextEditor(text: $text)
                .foregroundColor(Color.black)
                .padding(EdgeInsets(top: 0, leading: 4, bottom: 7, trailing: 0))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 0.5)
                )
            
            if showPlacehoder{
                Text(placeholder)
                    .padding(EdgeInsets(top: 4, leading: 7, bottom: 7, trailing: 0))
                    .foregroundColor(.gray)
            }
            
        }
        

            
    }
   
}

