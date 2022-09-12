//
//  SearchBar.swift
//  test-app2
//
//  Created by Yonatan Mamo on 12.09.22.
//

import Foundation
import UIKit
import SwiftUI

struct SearchBar: View {
    @Binding var searchText: String
    
    var body: some View {
        
        ZStack {
            
                Rectangle()
                   .foregroundColor(.backdrop)
                
            

             HStack {
                 Image(systemName: "magnifyingglass")
                 TextField("Search ..", text: $searchText)
                     .accentColor(.white)
                     .keyboardType(.webSearch)
             }
             .foregroundColor(.white)
             .padding(.leading, 13)
         }
         .frame(height: 40)
         .clipShape(Capsule())
         //.cornerRadius(20)
         .padding()
     }
 }
