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

//MARK: - Dummy image

func getExampleImageUrl(_ word : String = "people") -> URL {
    let iValue = Int.random(in: 1 ... 99)
    let urlString : String = "https://source.unsplash.com/random/450×450/?\(word)\(iValue)"
    
    let encodeUrlString: String = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    return URL(string: encodeUrlString)!
}


func imageByUrl(url: URL) -> Data? {
    do {
        let data = try Data(contentsOf: url)
        
        return UIImage(data: data)?.jpegData(compressionQuality: 0.3)
    } catch let error{
        print(error.localizedDescription)
    }
    
    return nil
}

func randomItemArray(count : Int) -> [Item] {
    
    var items = [Item]()
    
    for i in 0..<count {
        let id = UUID().uuidString
        let item = Item(id: id , name: "\(i)", imageUrl: getExampleImageUrl(), userId: "", index: 1)

        items.append(item)
    }
    
    return items
  
}


